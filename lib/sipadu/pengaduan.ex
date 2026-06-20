defmodule Sipadu.Pengaduan do
  @moduledoc """
  Modul konteks untuk mengelola laporan pengaduan (Laporan).
  """

  import Ecto.Query, warn: false
  alias Sipadu.Repo
  alias Sipadu.Pengaduan.Laporan

  @doc """
  Mengembalikan daftar semua laporan pengaduan.
  """
  def list_laporan do
    Laporan
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Mengembalikan daftar laporan pengaduan yang difilter berdasarkan user_id.
  """
  def list_laporan_by_user(user_id) do
    Laporan
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Mengambil data satu laporan pengaduan berdasarkan ID.
  """
  def get_laporan!(id), do: Repo.get!(Laporan, id)

  @doc """
  Membuat laporan pengaduan baru.
  """
  def create_laporan(attrs \\ %{}) do
    %Laporan{}
    |> Laporan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Memperbarui data laporan pengaduan.
  """
  def update_laporan(%Laporan{} = laporan, attrs) do
    laporan
    |> Laporan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Mengembalikan `%Ecto.Changeset{}` untuk melacak perubahan laporan pengaduan.
  """
  def change_laporan(%Laporan{} = laporan, attrs \\ %{}) do
    Laporan.changeset(laporan, attrs)
  end

  # === Kategori Permasalahan ===
  alias Sipadu.Pengaduan.KategoriPermasalahan

  @doc """
  Mengembalikan semua kategori permasalahan.
  """
  def list_kategori do
    KategoriPermasalahan
    |> order_by(asc: :nama)
    |> Repo.all()
  end

  @doc """
  Mengembalikan semua kategori permasalahan yang aktif.
  """
  def list_kategori_aktif do
    KategoriPermasalahan
    |> where(aktif: true)
    |> order_by(asc: :nama)
    |> Repo.all()
  end

  @doc """
  Mengambil kategori permasalahan berdasarkan ID.
  """
  def get_kategori!(id), do: Repo.get!(KategoriPermasalahan, id)

  @doc """
  Membuat kategori permasalahan baru.
  """
  def create_kategori(attrs \\ %{}) do
    %KategoriPermasalahan{}
    |> KategoriPermasalahan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Memperbarui kategori permasalahan.
  """
  def update_kategori(%KategoriPermasalahan{} = kategori, attrs) do
    kategori
    |> KategoriPermasalahan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Menghapus kategori permasalahan.
  """
  def delete_kategori(%KategoriPermasalahan{} = kategori) do
    Repo.delete(kategori)
  end

  @doc """
  Mengembalikan `%Ecto.Changeset{}` untuk melacak perubahan kategori permasalahan.
  """
  def change_kategori(%KategoriPermasalahan{} = kategori, attrs \\ %{}) do
    KategoriPermasalahan.changeset(kategori, attrs)
  end

  # === Statistik untuk Dashboard ===

  @doc """
  Menghitung jumlah total laporan.
  """
  def count_laporan, do: Repo.aggregate(Laporan, :count)

  @doc """
  Menghitung jumlah laporan berdasarkan status.
  """
  def count_laporan_by_status(status) do
    Laporan
    |> where(status: ^status)
    |> Repo.aggregate(:count)
  end

  @doc """
  Menghitung jumlah laporan yang dikelompokkan berdasarkan status dalam 1 query.
  """
  def get_laporan_status_counts do
    Laporan
    |> group_by([l], l.status)
    |> select([l], {l.status, count(l.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end

  @doc """
  Mengambil daftar laporan yang sering dilaporkan (berdasarkan judul) dan sudah selesai untuk dijadikan FAQ.
  """
  def get_popular_faq(limit \\ 5) do
    Laporan
    |> where(status: "Selesai")
    |> where([l], not is_nil(l.tanggapan_admin) and l.tanggapan_admin != "")
    |> group_by([l], l.judul_laporan)
    |> select([l], %{
      id: min(l.id),
      q: l.judul_laporan,
      a: max(l.tanggapan_admin),
      count: count(l.id)
    })
    |> order_by([l], desc: count(l.id), desc: min(l.id))
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Mengembalikan daftar laporan yang sudah diselesaikan berdasarkan kategori (untuk halaman knowledge base / topik bantuan).
  """
  def list_resolved_laporan_by_kategori(kategori) do
    Laporan
    |> where(status: "Selesai")
    |> where(kategori: ^kategori)
    |> where([l], not is_nil(l.tanggapan_admin) and l.tanggapan_admin != "")
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Fungsi khusus admin untuk memperbarui laporan (misal mengubah status & tanggapan).
  """
  def admin_update_laporan(%Laporan{} = laporan, attrs) do
    attrs = ensure_di_respon_status(laporan, attrs)

    laporan
    |> Laporan.changeset(attrs)
    |> Repo.update()
  end

  defp ensure_di_respon_status(%Laporan{status: current_status}, attrs) do
    has_response =
      attrs["tanggapan_admin"] not in [nil, ""] || attrs[:tanggapan_admin] not in [nil, ""]

    selected_status = attrs["status"] || attrs[:status] || current_status

    if has_response && selected_status in ["Menunggu", "Diproses"] do
      Map.put(attrs, "status", "Di Respon")
    else
      attrs
    end
  end
end
