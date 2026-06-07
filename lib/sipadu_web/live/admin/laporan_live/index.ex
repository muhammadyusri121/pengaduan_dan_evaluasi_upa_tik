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
    <div class="space-y-6">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 class="text-2xl font-bold text-slate-900">Laporan Pengaduan</h1>
          <p class="text-sm text-slate-500 mt-1">Kelola dan tanggapi seluruh laporan pengaduan pengguna.</p>
        </div>
        
        <!-- Filter Tabs/Buttons -->
        <div class="flex flex-wrap gap-2">
          <%= for status <- ["Semua", "Menunggu", "Diproses", "Selesai", "Ditolak"] do %>
            <button
              phx-click="filter"
              phx-value-status={status}
              class={[
                "px-4 py-2 rounded-xl text-xs font-semibold tracking-wider transition-all duration-200 border",
                @selected_status == status && "bg-indigo-600 text-white border-indigo-600 shadow-sm",
                @selected_status != status && "bg-white text-slate-600 border-slate-200 hover:bg-slate-50 hover:border-slate-350"
              ]}
            >
              {status}
            </button>
          <% end %>
        </div>
      </div>

      <!-- Laporan List Table -->
      <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-100 text-xs font-bold text-slate-500 uppercase tracking-wider">
                <th class="px-6 py-4">Tanggal Masuk</th>
                <th class="px-6 py-4">Pelapor</th>
                <th class="px-6 py-4">Kategori & Judul</th>
                <th class="px-6 py-4 text-center">Status</th>
                <th class="px-6 py-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody id="laporan-table" phx-update="stream" class="divide-y divide-slate-150">
              <tr id="empty-row" class="hidden only:table-row">
                <td colspan="5" class="px-6 py-12 text-center text-slate-400">
                  Tidak ada laporan pengaduan dengan status "{@selected_status}".
                </td>
              </tr>
              <tr :for={{id, lap} <- @streams.laporan_list} id={id} class="hover:bg-slate-50/50 transition">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                  {Calendar.strftime(lap.inserted_at, "%d %b %Y, %H:%M")}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-semibold text-slate-900">{lap.nama}</div>
                  <div class="text-xs text-slate-500">{lap.nim_nip}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="text-xs font-medium text-indigo-650 bg-indigo-50 border border-indigo-100 rounded-md px-2 py-0.5 w-fit">
                    {lap.kategori}
                  </div>
                  <div class="text-sm font-bold text-slate-850 mt-1">{lap.judul_laporan}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <.status_badge status={lap.status} />
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm">
                  <.link
                    navigate={~p"/admin/laporan/#{lap.id}"}
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-indigo-600 hover:bg-indigo-50 transition"
                  >
                    <.icon name="hero-eye" class="w-4 h-4" />
                    Detail & Tanggapi
                  </.link>
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
      "px-2.5 py-1 rounded-full text-xs font-semibold tracking-wider border",
      @status == "Menunggu" && "text-amber-800 bg-amber-100 border-amber-200",
      @status == "Diproses" && "text-blue-800 bg-blue-100 border-blue-200",
      @status == "Selesai" && "text-emerald-800 bg-emerald-100 border-emerald-200",
      @status == "Ditolak" && "text-rose-800 bg-rose-100 border-rose-200"
    ]}>
      {@status}
    </span>
    """
  end
end
