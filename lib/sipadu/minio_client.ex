defmodule Sipadu.MinioClient do
  @moduledoc """
  A simple client for interacting with MinIO using AWS Signature V4.
  """
  require Logger

  def config do
    cfg = Application.get_env(:sipadu, Sipadu.Minio) || []

    endpoint = cfg[:endpoint] || get_env_from_file("MINIO_ENDPOINT") || System.get_env("MINIO_ENDPOINT")
    access_key = cfg[:access_key] || get_env_from_file("MINIO_ACCESS_KEY") || System.get_env("MINIO_ACCESS_KEY")
    secret_key = cfg[:secret_key] || get_env_from_file("MINIO_SECRET_KEY") || System.get_env("MINIO_SECRET_KEY")
    bucket = cfg[:bucket] || get_env_from_file("MINIO_BUCKET") || System.get_env("MINIO_BUCKET")

    [
      endpoint: endpoint,
      access_key: access_key,
      secret_key: secret_key,
      bucket: bucket
    ]
  end

  defp get_env_from_file(name) do
    env_path = Path.expand(".env", File.cwd!())
    if File.exists?(env_path) do
      env_path
      |> File.read!()
      |> String.split("\n")
      |> Enum.find_value(fn line ->
        case Regex.run(~r/^\s*#{name}\s*=\s*"?([^"\n]*)"?\s*$/, line) do
          [_, value] -> String.trim(value)
          _ -> nil
        end
      end)
    end
  end

  @doc """
  Uploads a file to the configured MinIO bucket.
  """
  def upload_file(filename, file_binary, content_type) do
    cfg = config()
    IO.inspect(cfg, label: "MINIO CONFIG")
    endpoint = cfg[:endpoint]
    bucket = cfg[:bucket]
    access_key = cfg[:access_key]
    secret_key = cfg[:secret_key]

    url = "#{String.trim_trailing(endpoint, "/")}/#{bucket}/#{filename}"
    IO.inspect(url, label: "MINIO UPLOAD URL")
    headers = sign_request("PUT", url, file_binary, content_type, access_key, secret_key)

    case Req.put(url, headers: headers, body: file_binary) do
      {:ok, %{status: status}} when status in 200..299 ->
        {:ok, filename}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to upload to MinIO: #{status} - #{inspect(body)}")
        {:error, "MinIO upload failed with status #{status}"}

      {:error, reason} ->
        Logger.error("Failed to upload to MinIO: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Retrieves a file from the configured MinIO bucket.
  """
  def get_file(filename) do
    cfg = config()
    endpoint = cfg[:endpoint]
    bucket = cfg[:bucket]
    access_key = cfg[:access_key]
    secret_key = cfg[:secret_key]

    url = "#{String.trim_trailing(endpoint, "/")}/#{bucket}/#{filename}"
    headers = sign_request("GET", url, "", "", access_key, secret_key)

    case Req.get(url, headers: headers) do
      {:ok, %{status: 200, body: body} = res} ->
        content_type = Req.Response.get_header(res, "content-type") |> List.first() || "application/octet-stream"
        {:ok, body, content_type}

      {:ok, %{status: status}} ->
        {:error, "File not found or access denied, status: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Generates AWS Signature V4 headers for a request.
  """
  def sign_request(method, url_str, body, content_type, access_key, secret_key) do
    uri = URI.parse(url_str)
    host = if uri.port && uri.port != 80 && uri.port != 443, do: "#{uri.host}:#{uri.port}", else: uri.host
    path = uri.path

    now = DateTime.utc_now()
    amz_date = Calendar.strftime(now, "%Y%m%dT%H%M%SZ")
    datestamp = Calendar.strftime(now, "%Y%m%d")

    payload_hash = :crypto.hash(:sha256, body) |> Base.encode16(case: :lower)

    headers_map = %{
      "host" => host,
      "x-amz-date" => amz_date,
      "x-amz-content-sha256" => payload_hash
    }

    headers_map = if content_type != "", do: Map.put(headers_map, "content-type", content_type), else: headers_map

    sorted_header_keys = Map.keys(headers_map) |> Enum.sort()
    canonical_headers = Enum.map(sorted_header_keys, fn k -> "#{k}:#{Map.get(headers_map, k)}\n" end) |> Enum.join()
    signed_headers = Enum.join(sorted_header_keys, ";")

    canonical_uri = path
    canonical_query = ""
    canonical_request = "#{method}\n#{canonical_uri}\n#{canonical_query}\n#{canonical_headers}\n#{signed_headers}\n#{payload_hash}"
    canonical_request_hash = :crypto.hash(:sha256, canonical_request) |> Base.encode16(case: :lower)

    region = "us-east-1"
    service = "s3"
    credential_scope = "#{datestamp}/#{region}/#{service}/aws4_request"
    string_to_sign = "AWS4-HMAC-SHA256\n#{amz_date}\n#{credential_scope}\n#{canonical_request_hash}"

    signing_key = get_signature_key(secret_key, datestamp, region, service)
    signature = :crypto.mac(:hmac, :sha256, signing_key, string_to_sign) |> Base.encode16(case: :lower)

    authorization_header = "AWS4-HMAC-SHA256 Credential=#{access_key}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

    headers = [
      {"host", host},
      {"x-amz-date", amz_date},
      {"x-amz-content-sha256", payload_hash},
      {"authorization", authorization_header}
    ]

    if content_type != "", do: [{"content-type", content_type} | headers], else: headers
  end

  defp get_signature_key(key, date_stamp, region_name, service_name) do
    k_date = :crypto.mac(:hmac, :sha256, "AWS4" <> key, date_stamp)
    k_region = :crypto.mac(:hmac, :sha256, k_date, region_name)
    k_service = :crypto.mac(:hmac, :sha256, k_region, service_name)
    :crypto.mac(:hmac, :sha256, k_service, "aws4_request")
  end
end
