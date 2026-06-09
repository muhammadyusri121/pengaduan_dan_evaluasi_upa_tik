defmodule SipaduWeb.Admin.DashboardLive do
  use SipaduWeb, :live_view

  alias Sipadu.Accounts
  alias Sipadu.Pengaduan
  alias Sipadu.Surveys

  @impl true
  def mount(_params, _session, socket) do
    total_laporan = Pengaduan.count_laporan()
    menunggu = Pengaduan.count_laporan_by_status("Menunggu")
    diproses = Pengaduan.count_laporan_by_status("Diproses")
    selesai = Pengaduan.count_laporan_by_status("Selesai")
    ditolak = Pengaduan.count_laporan_by_status("Ditolak")
    
    total_users = Accounts.count_users()
    total_evaluasi = Surveys.count_evaluasi()
    avg_ratings = Surveys.average_ratings() || %{
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
    <div class="space-y-8">
      <!-- Welcome Header -->
      <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
        <div>
          <h1 class="text-2xl font-bold text-slate-900">Halo, {@current_user.name}!</h1>
          <p class="text-sm text-slate-500 mt-1">Selamat datang kembali di Portal Admin SIPADU UPA TIK.</p>
        </div>
        <div class="flex items-center gap-2 text-xs font-semibold text-slate-500 bg-slate-50 px-3 py-1.5 rounded-lg border border-slate-100 w-fit">
          <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
          Sistem Online
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <.stat_card title="Total Pengaduan" value={@total_laporan} icon="hero-document-text" color="text-indigo-600 bg-indigo-50 border-indigo-100" />
        <.stat_card title="Menunggu Tindakan" value={@menunggu} icon="hero-clock" color="text-amber-600 bg-amber-50 border-amber-100" />
        <.stat_card title="Sedang Diproses" value={@diproses} icon="hero-arrow-path" color="text-blue-600 bg-blue-50 border-blue-100" />
        <.stat_card title="Laporan Selesai" value={@selesai} icon="hero-check-circle" color="text-emerald-600 bg-emerald-50 border-emerald-100" />
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Recent Laporan -->
        <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div class="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
            <h2 class="text-lg font-bold text-slate-900">Pengaduan Terbaru</h2>
            <.link navigate={~p"/admin/laporan"} class="text-sm font-semibold text-indigo-600 hover:text-indigo-700 transition">
              Lihat semua Laporan &rarr;
            </.link>
          </div>
          <div class="divide-y divide-slate-150">
            <%= if @recent_laporan == [] do %>
              <div class="p-6 text-center text-slate-400">Belum ada pengaduan masuk.</div>
            <% else %>
              <%= for lap <- @recent_laporan do %>
                <div class="p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50 transition">
                  <div class="space-y-1">
                    <p class="font-semibold text-slate-900">{lap.judul_laporan}</p>
                    <div class="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-slate-500">
                      <span>{lap.nama}</span>
                      <span class="text-slate-300">&bull;</span>
                      <span>{lap.kategori}</span>
                    </div>
                  </div>
                  <div class="flex items-center gap-3">
                    <.status_badge status={lap.status} />
                    <.link navigate={~p"/admin/laporan/#{lap.id}"} class="btn btn-ghost btn-sm">
                      Detail
                    </.link>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>

        <!-- Surveys Ratings & System Info -->
        <div class="space-y-8">
          <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 space-y-6">
            <h2 class="text-lg font-bold text-slate-900">Rata-rata Rating Evaluasi</h2>
            <div class="space-y-4">
              <.rating_progress label="Kemudahan Pengajuan" value={@avg_ratings.kemudahan_pengajuan} />
              <.rating_progress label="Kecepatan Respon" value={@avg_ratings.kecepatan_respon} />
              <.rating_progress label="Kecepatan Penanganan" value={@avg_ratings.kecepatan_penanganan} />
              <.rating_progress label="Kualitas Layanan" value={@avg_ratings.kualitas_layanan} />
            </div>
            <div class="pt-4 border-t border-slate-100 flex items-center justify-between text-sm">
              <span class="text-slate-500">Total Evaluasi Masuk:</span>
              <span class="font-bold text-slate-900">{@total_evaluasi}</span>
            </div>
          </div>

          <div class="bg-indigo-900 text-indigo-100 p-6 rounded-2xl shadow-md space-y-4 relative overflow-hidden">
            <div class="absolute -right-10 -bottom-10 opacity-10">
              <.icon name="hero-shield-check" class="w-40 h-40" />
            </div>
            <h3 class="font-bold text-lg text-white">Statistik Sistem</h3>
            <div class="grid grid-cols-2 gap-4 text-center">
              <div class="bg-indigo-950/40 p-3 rounded-xl">
                <span class="block text-2xl font-extrabold text-white">{@total_users}</span>
                <span class="text-xs text-indigo-300">Total Pengguna</span>
              </div>
              <div class="bg-indigo-950/40 p-3 rounded-xl">
                <span class="block text-2xl font-extrabold text-white">{@ditolak}</span>
                <span class="text-xs text-indigo-300">Laporan Ditolak</span>
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
    <div class={["bg-white p-6 rounded-2xl shadow-sm border flex items-center justify-between", @color]}>
      <div class="space-y-1">
        <span class="block text-sm font-semibold text-slate-500">{@title}</span>
        <span class="block text-3xl font-extrabold text-slate-900">{@value}</span>
      </div>
      <div class="p-3 rounded-xl bg-white/70 shadow-sm border border-slate-100/50">
        <.icon name={@icon} class="w-6 h-6" />
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

    percent = (val / 5.0) * 100
    assigns = assign(assigns, :val, val) |> assign(:percent, percent)

    ~H"""
    <div class="space-y-1.5">
      <div class="flex justify-between text-sm">
        <span class="font-medium text-slate-650">{@label}</span>
        <span class="font-bold text-slate-905">{@val} / 5.0</span>
      </div>
      <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
        <div class="bg-indigo-600 h-full rounded-full transition-all duration-500" style={"width: #{@percent}%"}></div>
      </div>
    </div>
    """
  end

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "px-2.5 py-1 rounded-full text-xs font-semibold tracking-wider",
      @status == "Menunggu" && "text-amber-800 bg-amber-100 border border-amber-200",
      @status == "Diproses" && "text-blue-800 bg-blue-100 border border-blue-200",
      @status == "Selesai" && "text-emerald-800 bg-emerald-100 border border-emerald-200",
      @status == "Ditolak" && "text-rose-800 bg-rose-100 border border-rose-200"
    ]}>
      {@status}
    </span>
    """
  end
end
