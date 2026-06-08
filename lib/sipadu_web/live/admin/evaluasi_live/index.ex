defmodule SipaduWeb.Admin.EvaluasiLive.Index do
  use SipaduWeb, :live_view

  alias Sipadu.Surveys

  @impl true
  def mount(_params, _session, socket) do
    evaluasi_list = Surveys.list_evaluasi_layanan()
    total_evaluasi = Surveys.count_evaluasi()
    avg_ratings = Surveys.average_ratings() || %{
      kemudahan_pengajuan: 0.0,
      kecepatan_respon: 0.0,
      kecepatan_penanganan: 0.0,
      kualitas_layanan: 0.0
    }

    socket =
      socket
      |> assign(page_title: "Rekap Evaluasi Layanan")
      |> assign(total_evaluasi: total_evaluasi)
      |> assign(avg_ratings: avg_ratings)
      |> stream(:evaluasi_list, evaluasi_list)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <h1 class="text-2xl font-bold text-slate-900">Rekap Evaluasi Layanan</h1>
        <p class="text-sm text-slate-500 mt-1">Pantau survei kepuasan dan kualitas layanan UPA TIK dari para pengguna.</p>
      </div>

      <!-- Ratings Summary Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <.rating_summary_card label="Kemudahan Pengajuan" value={@avg_ratings.kemudahan_pengajuan} icon="hero-paper-airplane" />
        <.rating_summary_card label="Kecepatan Respon" value={@avg_ratings.kecepatan_respon} icon="hero-bolt" />
        <.rating_summary_card label="Kecepatan Penanganan" value={@avg_ratings.kecepatan_penanganan} icon="hero-wrench-screwdriver" />
        <.rating_summary_card label="Kualitas Layanan" value={@avg_ratings.kualitas_layanan} icon="hero-hand-thumb-up" />
      </div>

      <!-- Evaluasi List Table -->
      <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
          <h2 class="text-lg font-bold text-slate-900">Daftar Penilaian Pengguna</h2>
          <span class="text-xs font-semibold text-slate-500 bg-slate-100 px-2.5 py-1 rounded-full">
            Total Evaluasi: {@total_evaluasi}
          </span>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-100 text-xs font-bold text-slate-500 uppercase tracking-wider">
                <th class="px-6 py-4">Pelapor</th>
                <th class="px-6 py-4">Layanan</th>
                <th class="px-6 py-4 text-center">Kemudahan</th>
                <th class="px-6 py-4 text-center">Respon</th>
                <th class="px-6 py-4 text-center">Penanganan</th>
                <th class="px-6 py-4 text-center">Kualitas</th>
                <th class="px-6 py-4">Saran / Masukan</th>
              </tr>
            </thead>
            <tbody id="evaluasi-table" phx-update="stream" class="divide-y divide-slate-150">
              <tr id="empty-row" class="hidden only:table-row">
                <td colspan="7" class="px-6 py-12 text-center text-slate-400">
                  Belum ada evaluasi layanan yang dikirimkan oleh pengguna.
                </td>
              </tr>
              <tr :for={{id, ev} <- @streams.evaluasi_list} id={id} class="hover:bg-slate-50/50 transition align-top">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-semibold text-slate-900">{ev.nama}</div>
                  <div class="text-xs text-slate-500">{ev.jabatan}</div>
                  <div class="text-xs text-slate-400">{ev.nim_nip}</div>
                </td>
                <td class="px-6 py-4 text-sm font-medium text-slate-800">
                  {ev.layanan_yang_diminta}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <.stars rating={ev.kemudahan_pengajuan} />
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <.stars rating={ev.kecepatan_respon} />
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <.stars rating={ev.kecepatan_penanganan} />
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <.stars rating={ev.kualitas_layanan} />
                </td>
                <td class="px-6 py-4 text-sm text-slate-600 max-w-sm whitespace-pre-line leading-relaxed">
                  {ev.masukan || "-"}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp rating_summary_card(assigns) do
    val =
      case assigns.value do
        nil -> 0.0
        %Decimal{} = dec -> Decimal.to_float(dec) |> Float.round(1)
        v when is_float(v) -> Float.round(v, 1)
        v when is_integer(v) -> v * 1.0
        _ -> 0.0
      end

    assigns = assign(assigns, :val, val)

    ~H"""
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
      <div class="space-y-2">
        <span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">{@label}</span>
        <div class="flex items-center gap-1.5">
          <span class="text-3xl font-extrabold text-slate-900">{@val}</span>
          <span class="text-sm font-semibold text-slate-400">/ 5.0</span>
        </div>
        <.stars_display rating={@val} />
      </div>
      <div class="p-3 rounded-xl bg-indigo-50 border border-indigo-100 text-indigo-650">
        <.icon name={@icon} class="w-6 h-6" />
      </div>
    </div>
    """
  end

  defp stars(assigns) do
    ~H"""
    <div class="inline-flex gap-0.5" title={"Rating: #{@rating} / 5"}>
      <%= for i <- 1..5 do %>
        <.icon
          name="hero-star-solid"
          class={["w-4 h-4", if(i <= @rating, do: "text-amber-400", else: "text-slate-200")]}
        />
      <% end %>
    </div>
    """
  end

  defp stars_display(assigns) do
    rating_val =
      case assigns.rating do
        %Decimal{} = dec -> Decimal.to_float(dec) |> round()
        r when is_float(r) -> round(r)
        r when is_integer(r) -> r
        _ -> 0
      end

    assigns = assign(assigns, :val_int, rating_val)

    ~H"""
    <div class="flex gap-0.5">
      <%= for i <- 1..5 do %>
        <.icon
          name="hero-star-solid"
          class={["w-3.5 h-3.5", if(i <= @val_int, do: "text-amber-455", else: "text-slate-250")]}
        />
      <% end %>
    </div>
    """
  end
end
