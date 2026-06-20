defmodule SipaduWeb.Admin.DashboardLive do
  use SipaduWeb, :live_view

  alias Sipadu.Accounts
  alias Sipadu.Pengaduan
  alias Sipadu.Surveys

  @impl true
  def mount(_params, _session, socket) do
    status_counts = Pengaduan.get_laporan_status_counts()

    total_laporan = Enum.reduce(status_counts, 0, fn {_, count}, acc -> acc + count end)
    menunggu = Map.get(status_counts, "Menunggu", 0)
    diproses = Map.get(status_counts, "Diproses", 0)
    di_respon = Map.get(status_counts, "Di Respon", 0)
    selesai = Map.get(status_counts, "Selesai", 0)
    ditolak = Map.get(status_counts, "Ditolak", 0)

    total_users = Accounts.count_users()
    total_evaluasi = Surveys.count_evaluasi()

    avg_ratings =
      Surveys.average_ratings() ||
        %{
          kemudahan_pengajuan: 0.0,
          kecepatan_respon: 0.0,
          kecepatan_penanganan: 0.0,
          kualitas_layanan: 0.0
        }

    recent_laporan =
      Pengaduan.list_laporan()
      |> Enum.take(5)

    socket =
      socket
      |> assign(page_title: "Dashboard Admin")
      |> assign(total_laporan: total_laporan)
      |> assign(menunggu: menunggu)
      |> assign(diproses: diproses)
      |> assign(di_respon: di_respon)
      |> assign(selesai: selesai)
      |> assign(ditolak: ditolak)
      |> assign(total_users: total_users)
      |> assign(total_evaluasi: total_evaluasi)
      |> assign(avg_ratings: avg_ratings)
      |> assign(recent_laporan: recent_laporan)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8 max-w-7xl mx-auto pb-12">
      <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 bg-white p-8 rounded-3xl shadow-[0_2px_20px_rgb(0,0,0,0.04)] border border-slate-100">
        <div>
          <h1 class="text-3xl font-extrabold text-slate-900 tracking-tight">
            Halo, {@current_user.name}! 👋
          </h1>
          <p class="text-base text-slate-500 mt-1.5">
            Pantau dan kelola aktivitas laporan pengaduan UPA TIK hari ini.
          </p>
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
        <.stat_card
          title="Total Laporan"
          value={@total_laporan}
          icon="hero-document-text"
          theme="indigo"
        />
        <.stat_card title="Menunggu" value={@menunggu} icon="hero-clock" theme="amber" />
        <.stat_card title="Diproses" value={@diproses} icon="hero-arrow-path" theme="blue" />
        <.stat_card
          title="Di Respon"
          value={@di_respon}
          icon="hero-chat-bubble-left-right"
          theme="violet"
        />
        <.stat_card title="Selesai" value={@selesai} icon="hero-check-circle" theme="emerald" />
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-2 flex flex-col bg-white rounded-3xl shadow-[0_2px_20px_rgb(0,0,0,0.04)] border border-slate-100 overflow-hidden">
          <div class="px-8 py-6 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
            <h2 class="text-xl font-extrabold text-slate-800">Pengaduan Terbaru</h2>
            <.link
              navigate={~p"/admin/laporan"}
              class="text-sm font-bold text-blue-600 hover:text-blue-800 transition-colors flex items-center gap-1"
            >
              Lihat Semua <.icon name="hero-arrow-right" class="w-4 h-4" />
            </.link>
          </div>
          <div class="flex-1 divide-y divide-slate-100">
            <%= if @recent_laporan == [] do %>
              <div class="p-12 text-center flex flex-col items-center justify-center">
                <div class="bg-slate-50 p-4 rounded-full mb-4">
                  <.icon name="hero-inbox" class="w-8 h-8 text-slate-400" />
                </div>
                <p class="text-slate-500 font-medium">Belum ada pengaduan masuk saat ini.</p>
              </div>
            <% else %>
              <%= for lap <- @recent_laporan do %>
                <div class="p-6 px-8 flex flex-col sm:flex-row sm:items-center justify-between gap-5 hover:bg-slate-50/80 transition-colors duration-200">
                  <div class="space-y-1.5 flex-1">
                    <p class="font-bold text-slate-800 text-lg line-clamp-1">{lap.judul_laporan}</p>
                    <div class="flex flex-wrap items-center gap-x-3 gap-y-2 text-sm text-slate-500 font-medium">
                      <div class="flex items-center gap-1.5">
                        <.icon name="hero-user" class="w-4 h-4 text-slate-400" />
                        {lap.nama}
                      </div>
                      <span class="text-slate-300">&bull;</span>
                      <div class="flex items-center gap-1.5 bg-slate-100 px-2.5 py-0.5 rounded-md text-slate-600 text-xs uppercase tracking-wider font-bold">
                        {lap.kategori}
                      </div>
                    </div>
                  </div>
                  <div class="flex items-center gap-4">
                    <.status_badge status={lap.status} />
                    <.link
                      navigate={~p"/admin/laporan/#{lap.id}"}
                      class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all"
                    >
                      <.icon name="hero-chevron-right" class="w-5 h-5" />
                    </.link>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>

        <div class="space-y-8 flex flex-col">
          <div class="bg-white p-8 rounded-3xl shadow-[0_2px_20px_rgb(0,0,0,0.04)] border border-slate-100 flex-1">
            <div class="flex items-center gap-3 mb-8">
              <div class="p-2 bg-amber-100 text-amber-600 rounded-lg">
                <.icon name="hero-star" class="w-6 h-6" />
              </div>
              <h2 class="text-xl font-extrabold text-slate-800">Evaluasi Layanan</h2>
            </div>

            <div class="space-y-6">
              <.rating_progress label="Kemudahan Pengajuan" value={@avg_ratings.kemudahan_pengajuan} />
              <.rating_progress label="Kecepatan Respon" value={@avg_ratings.kecepatan_respon} />
              <.rating_progress
                label="Kecepatan Penanganan"
                value={@avg_ratings.kecepatan_penanganan}
              />
              <.rating_progress label="Kualitas Layanan" value={@avg_ratings.kualitas_layanan} />
            </div>

            <div class="mt-8 pt-6 border-t border-slate-100 flex items-center justify-between">
              <span class="text-sm font-semibold text-slate-500">Total Evaluasi Masuk</span>
              <span class="text-lg font-black text-slate-900 bg-slate-100 px-3 py-1 rounded-lg">
                {@total_evaluasi}
              </span>
            </div>
          </div>

          <div class="bg-gradient-to-br from-slate-800 to-slate-900 p-8 rounded-3xl shadow-lg relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 opacity-10 group-hover:scale-110 group-hover:rotate-12 transition-transform duration-700">
              <.icon name="hero-server-stack" class="w-48 h-48 text-white" />
            </div>
            <div class="relative z-10">
              <h3 class="font-bold text-xl text-white mb-6">Statistik Sistem</h3>
              <div class="grid grid-cols-2 gap-4">
                <div class="bg-white/10 backdrop-blur-md p-4 rounded-2xl border border-white/10">
                  <span class="block text-3xl font-black text-white mb-1">{@total_users}</span>
                  <span class="text-sm font-medium text-slate-300">Pengguna Aktif</span>
                </div>
                <div class="bg-white/10 backdrop-blur-md p-4 rounded-2xl border border-white/10">
                  <span class="block text-3xl font-black text-white mb-1">{@ditolak}</span>
                  <span class="text-sm font-medium text-slate-300">Laporan Ditolak</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-white p-5 xl:p-6 rounded-3xl shadow-[0_2px_15px_rgb(0,0,0,0.03)] border border-slate-100 flex flex-col gap-4 hover:shadow-lg transition-all duration-300 hover:-translate-y-1">
      <div class={[
        "p-3.5 rounded-2xl flex items-center justify-center shadow-inner w-fit",
        @theme == "indigo" && "bg-indigo-50 text-indigo-600 border border-indigo-100",
        @theme == "amber" && "bg-amber-50 text-amber-600 border border-amber-100",
        @theme == "blue" && "bg-blue-50 text-blue-600 border border-blue-100",
        @theme == "violet" && "bg-violet-50 text-violet-600 border border-violet-100",
        @theme == "emerald" && "bg-emerald-50 text-emerald-600 border border-emerald-100"
      ]}>
        <.icon name={@icon} class="w-7 h-7" />
      </div>
      <div class="space-y-0.5">
        <span class="block text-3xl font-black text-slate-800">{@value}</span>
        <span class="block text-xs font-bold text-slate-500 uppercase tracking-wider">{@title}</span>
      </div>
    </div>
    """
  end

  defp rating_progress(assigns) do
    val =
      case assigns.value do
        nil -> 0.0
        %Decimal{} = dec -> Decimal.to_float(dec) |> Float.round(1)
        v when is_float(v) -> Float.round(v, 1)
        v when is_integer(v) -> v * 1.0
        _ -> 0.0
      end

    percent = val / 5.0 * 100
    assigns = assign(assigns, :val, val) |> assign(:percent, percent)

    ~H"""
    <div class="space-y-2">
      <div class="flex justify-between items-center text-sm">
        <span class="font-bold text-slate-600">{@label}</span>
        <div class="flex items-center gap-1.5">
          <span class="font-black text-slate-800">{@val}</span>
          <span class="text-slate-400 font-medium">/ 5.0</span>
        </div>
      </div>
      <div class="w-full bg-slate-100 h-2.5 rounded-full overflow-hidden shadow-inner">
        <div
          class="bg-gradient-to-r from-amber-400 to-amber-500 h-full rounded-full transition-all duration-700 ease-out"
          style={"width: #{@percent}%"}
        >
        </div>
      </div>
    </div>
    """
  end

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "px-3 py-1.5 rounded-full text-xs font-bold tracking-wide shadow-sm flex items-center gap-1.5",
      @status == "Menunggu" && "text-amber-700 bg-amber-50 border border-amber-200",
      @status == "Diproses" && "text-blue-700 bg-blue-50 border border-blue-200",
      @status == "Di Respon" && "text-violet-700 bg-violet-50 border border-violet-200",
      @status == "Selesai" && "text-emerald-700 bg-emerald-50 border border-emerald-200",
      @status == "Ditolak" && "text-rose-700 bg-rose-50 border border-rose-200"
    ]}>
      <span class={[
        "w-1.5 h-1.5 rounded-full",
        @status == "Menunggu" && "bg-amber-500",
        @status == "Diproses" && "bg-blue-500",
        @status == "Di Respon" && "bg-violet-500",
        @status == "Selesai" && "bg-emerald-500",
        @status == "Ditolak" && "bg-rose-500"
      ]}>
      </span>
      {@status}
    </span>
    """
  end
end
