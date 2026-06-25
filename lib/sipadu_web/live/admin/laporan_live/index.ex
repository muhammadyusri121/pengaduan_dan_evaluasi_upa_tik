defmodule SipaduWeb.Admin.LaporanLive.Index do
  use SipaduWeb, :live_view

  alias Sipadu.Pengaduan

  @impl true
  def mount(_params, _session, socket) do
    laporan_list = Pengaduan.list_laporan()

    socket =
      socket
      |> assign(page_title: "Daftar Laporan Pengaduan")
      |> assign(selected_status: "Semua")
      |> assign(laporan_empty?: laporan_list == [])
      |> stream(:laporan_list, laporan_list)

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    all_laporan = Pengaduan.list_laporan()

    filtered_laporan =
      if status == "Semua" do
        all_laporan
      else
        Enum.filter(all_laporan, fn lap -> lap.status == status end)
      end

    socket =
      socket
      |> assign(selected_status: status)
      |> assign(laporan_empty?: filtered_laporan == [])
      |> stream(:laporan_list, filtered_laporan, reset: true)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto pb-12">
      <!-- Header & Filters -->
      <div class="relative overflow-hidden flex flex-col md:flex-row md:items-center justify-between gap-6 bg-gradient-to-r from-blue-600 to-indigo-700 p-8 rounded-3xl shadow-lg border border-blue-500 mb-8">
        <div class="absolute -right-10 -top-10 opacity-10 pointer-events-none">
          <.icon name="hero-document-magnifying-glass" class="w-64 h-64 text-white" />
        </div>
        <div class="relative z-10">
          <h1 class="text-3xl font-extrabold text-white tracking-tight">Daftar Pengaduan</h1>
          <p class="text-base text-blue-100 mt-1.5 font-medium">
            Kelola, pantau, dan tanggapi semua laporan yang masuk ke sistem.
          </p>
        </div>

        <div class="relative z-10 hidden xl:block">
          <div class="bg-white/10 backdrop-blur-md p-4 rounded-2xl border border-white/10 flex items-center gap-3">
            <.icon name="hero-information-circle" class="w-6 h-6 text-blue-200" />
            <p class="text-sm text-blue-50">
              Klik pada baris mana saja untuk melihat detail laporan.
            </p>
          </div>
        </div>
      </div>
      
    <!-- Filter Tabs / Segmented Control -->
      <div class="mb-8">
        <div class="inline-flex bg-slate-100/80 p-1.5 rounded-2xl border border-slate-200/60 overflow-x-auto max-w-full hide-scrollbar">
          <%= for status <- ["Semua", "Menunggu", "Diproses", "Di Respon", "Selesai", "Ditolak"] do %>
            <button
              phx-click="filter"
              phx-value-status={status}
              class={[
                "px-5 py-2.5 rounded-xl text-sm font-bold transition-all duration-300 whitespace-nowrap",
                @selected_status == status &&
                  "bg-white text-blue-700 shadow-[0_2px_10px_rgb(0,0,0,0.06)] border border-slate-100",
                @selected_status != status &&
                  "text-slate-500 hover:text-slate-700 hover:bg-slate-200/50"
              ]}
            >
              {status}
            </button>
          <% end %>
        </div>
      </div>
      
    <!-- Laporan Table Card -->
      <div class="bg-white rounded-3xl shadow-[0_2px_20px_rgb(0,0,0,0.04)] border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse min-w-[800px]">
            <thead>
              <tr class="bg-slate-50/80 border-b border-slate-100 text-[11px] font-extrabold text-slate-500 uppercase tracking-widest">
                <th class="px-8 py-5">Tanggal Masuk</th>
                <th class="px-8 py-5">Info Pelapor</th>
                <th class="px-8 py-5">Kategori & Judul</th>
                <th class="px-8 py-5 text-center">Status</th>
                <th class="px-8 py-5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody id="laporan-table" phx-update="stream" class="divide-y divide-slate-100">
              <!-- Empty State Row -->
              <tr id="empty-row" class="hidden only:table-row">
                <td colspan="5" class="px-8 py-20 text-center">
                  <div class="flex flex-col items-center justify-center max-w-sm mx-auto">
                    <div class="bg-slate-50 p-5 rounded-full mb-5">
                      <.icon name="hero-inbox" class="w-10 h-10 text-slate-400" />
                    </div>
                    <h3 class="text-lg font-bold text-slate-800 mb-1">Tidak ada data</h3>
                    <p class="text-sm text-slate-500">
                      Saat ini tidak ada laporan pengaduan dengan status <span class="font-bold text-slate-700">"{@selected_status}"</span>.
                    </p>
                  </div>
                </td>
              </tr>
              
    <!-- Data Rows -->
              <tr
                :for={{id, lap} <- @streams.laporan_list}
                id={id}
                phx-click={JS.navigate(~p"/admin/laporan/#{lap.id}")}
                class="hover:bg-blue-50/50 transition-colors duration-200 group cursor-pointer relative"
              >
                <td class="px-8 py-6 whitespace-nowrap">
                  <div class="flex items-center gap-3">
                    <div class="p-2.5 rounded-xl bg-blue-50 text-blue-600 group-hover:scale-110 group-hover:bg-blue-600 group-hover:text-white transition-all duration-300 shadow-sm">
                      <.icon name="hero-calendar" class="w-5 h-5" />
                    </div>
                    <div>
                      <div class="text-sm font-extrabold text-slate-900 mb-0.5 group-hover:text-blue-700 transition-colors">
                        {Calendar.strftime(lap.inserted_at, "%d %b %Y")}
                      </div>
                      <div class="text-xs font-bold text-slate-500">
                        {Calendar.strftime(lap.inserted_at, "%H:%M")} WIB
                      </div>
                    </div>
                  </div>
                </td>
                <td class="px-8 py-6 whitespace-nowrap">
                  <div class="text-sm font-extrabold text-slate-900 mb-0.5">{lap.nama}</div>
                  <div class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider mb-1.5">
                    {lap.nim_nip}
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="inline-flex items-center gap-1 text-[11px] font-bold text-slate-500 bg-slate-50 border border-slate-200 px-2 py-0.5 rounded-md truncate max-w-[120px]">
                      <.icon name="hero-building-office" class="w-3 h-3" />
                      {lap.fakultas_unit_kerja || "-"}
                    </span>
                    <span class="inline-flex items-center gap-1 text-[11px] font-bold text-slate-500 bg-slate-50 border border-slate-200 px-2 py-0.5 rounded-md truncate max-w-[120px]">
                      <.icon name="hero-device-phone-mobile" class="w-3 h-3" />
                      {lap.no_hp || "-"}
                    </span>
                  </div>
                </td>
                <td class="px-8 py-6">
                  <span class="inline-block bg-slate-100 text-slate-600 text-[10px] font-extrabold uppercase tracking-widest px-2.5 py-1 rounded-md mb-2 border border-slate-200/60 shadow-sm group-hover:bg-white group-hover:border-slate-300 transition-colors">
                    {lap.kategori}
                  </span>
                  <p class="text-[15px] font-bold text-slate-800 leading-snug line-clamp-2 max-w-sm group-hover:text-blue-700 transition-colors">
                    {lap.judul_laporan}
                  </p>
                </td>
                <td class="px-8 py-6 whitespace-nowrap text-center">
                  <.status_badge status={lap.status} />
                </td>
                <td class="px-8 py-6 whitespace-nowrap text-right">
                  <div class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-100/50 rounded-xl transition-all inline-flex items-center justify-center">
                    <.icon
                      name="hero-arrow-right"
                      class="w-5 h-5 group-hover:translate-x-1 transition-transform"
                    />
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

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "px-3 py-1.5 rounded-full text-xs font-bold tracking-wide shadow-sm flex items-center justify-center gap-1.5 w-fit mx-auto",
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
