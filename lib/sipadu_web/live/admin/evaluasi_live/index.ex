defmodule SipaduWeb.Admin.EvaluasiLive.Index do
  use SipaduWeb, :live_view

  alias Sipadu.Surveys

  @impl true
  def mount(_params, _session, socket) do
    evaluasi_list = Surveys.list_evaluasi_layanan()
    total_evaluasi = Surveys.count_evaluasi()

    avg_ratings =
      Surveys.average_ratings() ||
        %{
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
    <div class="max-w-7xl mx-auto pb-12 space-y-8">
      <div class="relative overflow-hidden flex flex-col justify-center bg-gradient-to-r from-blue-600 to-indigo-700 p-8 rounded-3xl shadow-lg border border-blue-500 mb-8">
        <div class="absolute -right-10 -top-10 opacity-10 pointer-events-none">
          <.icon name="hero-star" class="w-64 h-64 text-white" />
        </div>
        <div class="relative z-10">
          <h1 class="text-3xl font-extrabold text-white tracking-tight">Rekap Evaluasi Layanan</h1>
          <p class="text-base text-blue-100 mt-1.5 font-medium">
            Pantau tingkat kepuasan dan kualitas pelayanan UPA TIK secara berkala.
          </p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <.rating_summary_card
          label="Kemudahan Pengajuan"
          value={@avg_ratings.kemudahan_pengajuan}
          icon="hero-paper-airplane"
          theme="indigo"
        />
        <.rating_summary_card
          label="Kecepatan Respon"
          value={@avg_ratings.kecepatan_respon}
          icon="hero-bolt"
          theme="amber"
        />
        <.rating_summary_card
          label="Kecepatan Penanganan"
          value={@avg_ratings.kecepatan_penanganan}
          icon="hero-wrench-screwdriver"
          theme="blue"
        />
        <.rating_summary_card
          label="Kualitas Layanan"
          value={@avg_ratings.kualitas_layanan}
          icon="hero-hand-thumb-up"
          theme="emerald"
        />
      </div>

      <div class="bg-white rounded-[2rem] shadow-[0_2px_20px_rgb(0,0,0,0.04)] border border-slate-100 overflow-hidden">
        <div class="px-8 py-6 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
          <div class="flex items-center gap-3">
            <div class="p-2 rounded-xl bg-blue-50 text-blue-600 shadow-sm">
              <.icon name="hero-chat-bubble-bottom-center-text" class="w-5 h-5" />
            </div>
            <h2 class="text-xl font-extrabold text-slate-900">Daftar Penilaian Pengguna</h2>
          </div>
          <span class="text-xs font-extrabold text-slate-600 bg-white px-3 py-1.5 rounded-full border border-slate-200 shadow-sm flex items-center gap-2 tracking-wide">
            <span class="w-2 h-2 rounded-full bg-blue-500"></span> Total Evaluasi: {@total_evaluasi}
          </span>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse min-w-[1000px]">
            <thead>
              <tr class="bg-slate-50/80 border-b border-slate-100 text-[11px] font-extrabold text-slate-500 uppercase tracking-widest">
                <th class="px-8 py-5">Identitas Pelapor</th>
                <th class="px-8 py-5">Layanan</th>
                <th class="px-8 py-5 text-center">Indikator Penilaian</th>
                <th class="px-8 py-5 w-[30%]">Saran & Masukan</th>
              </tr>
            </thead>
            <tbody id="evaluasi-table" phx-update="stream" class="divide-y divide-slate-100">
              <tr id="empty-row" class="hidden only:table-row">
                <td colspan="4" class="px-8 py-20 text-center">
                  <div class="flex flex-col items-center justify-center max-w-sm mx-auto">
                    <div class="bg-slate-50 p-5 rounded-full mb-5">
                      <.icon name="hero-document-magnifying-glass" class="w-10 h-10 text-slate-400" />
                    </div>
                    <h3 class="text-lg font-bold text-slate-800 mb-1">Belum ada evaluasi</h3>
                    <p class="text-sm text-slate-500">
                      Saat ini belum ada data evaluasi layanan yang dikirimkan oleh pengguna.
                    </p>
                  </div>
                </td>
              </tr>

              <tr
                :for={{id, ev} <- @streams.evaluasi_list}
                id={id}
                class="hover:bg-slate-50/80 transition-colors group align-top"
              >
                <td class="px-8 py-6 whitespace-nowrap">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-400 shrink-0">
                      <.icon name="hero-user" class="w-5 h-5" />
                    </div>
                    <div>
                      <div class="text-sm font-extrabold text-slate-900 mb-0.5">{ev.nama}</div>
                      <div class="text-xs font-bold text-slate-500">{ev.jabatan}</div>
                      <div class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider mt-0.5">
                        {ev.nim_nip}
                      </div>
                    </div>
                  </div>
                </td>

                <td class="px-8 py-6">
                  <span class="inline-block bg-blue-50 text-blue-700 text-xs font-bold uppercase tracking-wider px-2.5 py-1 rounded-md border border-blue-100/50">
                    {ev.layanan_yang_diminta}
                  </span>
                </td>

                <td class="px-8 py-6">
                  <div class="grid grid-cols-2 gap-x-4 gap-y-2 w-fit mx-auto">
                    <div class="flex flex-col items-center">
                      <span class="text-[9px] font-extrabold text-slate-400 uppercase tracking-widest mb-1">
                        Kemudahan
                      </span>
                      <.stars rating={ev.kemudahan_pengajuan} />
                    </div>
                    <div class="flex flex-col items-center">
                      <span class="text-[9px] font-extrabold text-slate-400 uppercase tracking-widest mb-1">
                        Respon
                      </span>
                      <.stars rating={ev.kecepatan_respon} />
                    </div>
                    <div class="flex flex-col items-center">
                      <span class="text-[9px] font-extrabold text-slate-400 uppercase tracking-widest mb-1">
                        Penanganan
                      </span>
                      <.stars rating={ev.kecepatan_penanganan} />
                    </div>
                    <div class="flex flex-col items-center">
                      <span class="text-[9px] font-extrabold text-slate-400 uppercase tracking-widest mb-1">
                        Kualitas
                      </span>
                      <.stars rating={ev.kualitas_layanan} />
                    </div>
                  </div>
                </td>

                <td class="px-8 py-6">
                  <div class="text-sm text-slate-600 bg-white p-3 rounded-xl border border-slate-100 shadow-sm whitespace-pre-line leading-relaxed group-hover:bg-slate-50 transition-colors">
                    <%= if is_nil(ev.masukan) or ev.masukan == "" do %>
                      <span class="italic text-slate-400">Tidak ada saran tertulis.</span>
                    <% else %>
                      {ev.masukan}
                    <% end %>
                  </div>
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
    <div class="bg-white p-6 rounded-3xl shadow-[0_2px_15px_rgb(0,0,0,0.03)] border border-slate-100 flex items-start justify-between hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1.5 transition-all duration-300 group cursor-default relative overflow-hidden">
      <div class="absolute inset-0 bg-gradient-to-br from-white to-slate-50/50 -z-10 opacity-0 group-hover:opacity-100 transition-opacity">
      </div>
      <div class="space-y-3 relative z-10">
        <span class="block text-[11px] font-extrabold text-slate-400 uppercase tracking-widest group-hover:text-blue-600 transition-colors">
          {@label}
        </span>

        <div class="flex items-end gap-1.5">
          <span class="text-4xl font-black text-slate-800 leading-none">{@val}</span>
          <span class="text-sm font-bold text-slate-400 mb-1">/ 5.0</span>
        </div>

        <.stars_display rating={@val} />
      </div>

      <div class={[
        "p-3.5 rounded-2xl flex items-center justify-center shadow-inner group-hover:scale-110 transition-transform duration-300 relative z-10",
        @theme == "indigo" && "bg-indigo-50 text-indigo-600 border border-indigo-100",
        @theme == "amber" && "bg-amber-50 text-amber-600 border border-amber-100",
        @theme == "blue" && "bg-blue-50 text-blue-600 border border-blue-100",
        @theme == "emerald" && "bg-emerald-50 text-emerald-600 border border-emerald-100"
      ]}>
        <.icon name={@icon} class="w-7 h-7" />
      </div>
    </div>
    """
  end

  defp stars(assigns) do
    ~H"""
    <div
      class="inline-flex gap-0.5 bg-slate-50 px-1.5 py-1 rounded-md border border-slate-100"
      title={"Rating: #{@rating} / 5"}
    >
      <%= for i <- 1..5 do %>
        <.icon
          name="hero-star-solid"
          class={[
            "w-3.5 h-3.5 transition-colors",
            if(i <= @rating, do: "text-amber-400", else: "text-slate-200")
          ]}
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
    <div class="flex gap-1 bg-amber-50/50 w-fit px-2 py-1 rounded-lg border border-amber-100/50">
      <%= for i <- 1..5 do %>
        <.icon
          name="hero-star-solid"
          class={["w-4 h-4", if(i <= @val_int, do: "text-amber-500", else: "text-slate-200")]}
        />
      <% end %>
    </div>
    """
  end
end
