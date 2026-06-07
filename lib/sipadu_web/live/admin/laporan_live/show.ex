defmodule SipaduWeb.Admin.LaporanLive.Show do
  use SipaduWeb, :live_view

  alias Sipadu.Pengaduan

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    laporan = Pengaduan.get_laporan!(id)
    changeset = Pengaduan.change_laporan(laporan)

    socket =
      socket
      |> assign(page_title: "Detail Laporan ##{laporan.id}")
      |> assign(laporan: laporan)
      |> assign(form: to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"laporan" => laporan_params}, socket) do
    changeset =
      socket.assigns.laporan
      |> Pengaduan.change_laporan(laporan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"laporan" => laporan_params}, socket) do
    case Pengaduan.admin_update_laporan(socket.assigns.laporan, laporan_params) do
      {:ok, updated_laporan} ->
        socket =
          socket
          |> put_flash(:info, "Status dan tanggapan laporan berhasil diperbarui.")
          |> assign(laporan: updated_laporan)
          |> assign(form: to_form(Pengaduan.change_laporan(updated_laporan)))

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> put_flash(:error, "Gagal memperbarui laporan. Silakan periksa kesalahan pada formulir.")
          |> assign(form: to_form(changeset))

        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <!-- Header -->
      <div class="flex items-center gap-4">
        <.link navigate={~p"/admin/laporan"} class="btn btn-ghost p-2 rounded-xl border border-slate-200 bg-white shadow-sm">
          <.icon name="hero-arrow-left" class="w-5 h-5 text-slate-600" />
        </.link>
        <div>
          <span class="text-xs font-semibold text-slate-500 uppercase tracking-wider">KEMBALI KE DAFTAR</span>
          <h1 class="text-2xl font-bold text-slate-900">Detail Laporan #{@laporan.id}</h1>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Detail Info Laporan (2 cols) -->
        <div class="lg:col-span-2 space-y-6">
          <!-- Main Report Card -->
          <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 space-y-6">
            <div class="flex items-center justify-between flex-wrap gap-4 border-b border-slate-100 pb-4">
              <div>
                <span class="text-xs font-medium text-indigo-650 bg-indigo-50 border border-indigo-100 rounded-md px-2.5 py-1">
                  {@laporan.kategori}
                </span>
                <h2 class="text-xl font-bold text-slate-850 mt-2">{@laporan.judul_laporan}</h2>
              </div>
              <.status_badge status={@laporan.status} />
            </div>

            <!-- Description -->
            <div class="space-y-2">
              <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Deskripsi Masalah</span>
              <p class="text-slate-700 whitespace-pre-line text-sm leading-relaxed">{@laporan.deskripsi}</p>
            </div>

            <!-- Metadata Info Grid -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 bg-slate-50 p-4 rounded-xl border border-slate-100 text-sm">
              <div class="space-y-1">
                <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Lokasi Kejadian</span>
                <span class="block font-semibold text-slate-800">{@laporan.lokasi}</span>
              </div>
              <div class="space-y-1">
                <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Tanggal Laporan</span>
                <span class="block font-semibold text-slate-800">
                  {Calendar.strftime(@laporan.inserted_at, "%d %B %Y, %H:%M WIB")}
                </span>
              </div>
            </div>

            <!-- Attachment File -->
            <%= if @laporan.lampiran do %>
              <div class="space-y-3">
                <span class="text-xs font-bold text-slate-400 uppercase tracking-wider block">Berkas Lampiran</span>
                <div class="flex items-center justify-between bg-indigo-50/50 p-4 rounded-xl border border-indigo-150">
                  <div class="flex items-center gap-3">
                    <.icon name="hero-document" class="w-8 h-8 text-indigo-500" />
                    <div class="min-w-0">
                      <span class="block text-sm font-semibold text-slate-800 truncate">{@laporan.lampiran}</span>
                    </div>
                  </div>
                  <a
                    href={~p"/laporan/lampiran/#{@laporan.lampiran}"}
                    target="_blank"
                    class="btn btn-primary btn-sm flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700"
                  >
                    <.icon name="hero-arrow-down-tray" class="w-4 h-4" />
                    Buka / Unduh File
                  </a>
                </div>

                <!-- If attachment is an image, display a preview -->
                <%= if String.ends_with?(String.downcase(@laporan.lampiran), [".jpg", ".jpeg", ".png", ".gif", ".webp"]) do %>
                  <div class="mt-4 border border-slate-100 rounded-xl overflow-hidden shadow-sm">
                    <img src={~p"/laporan/lampiran/#{@laporan.lampiran}"} class="max-h-96 w-full object-contain bg-slate-50" />
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <!-- Reporter Info Card -->
          <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 space-y-4">
            <h3 class="text-lg font-bold text-slate-900 border-b border-slate-100 pb-3">Informasi Pelapor</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
              <div class="space-y-1">
                <span class="text-xs text-slate-400 font-medium">Nama Pelapor</span>
                <span class="block font-semibold text-slate-800">{@laporan.nama}</span>
              </div>
              <div class="space-y-1">
                <span class="text-xs text-slate-400 font-medium">NIM / NIP</span>
                <span class="block font-semibold text-slate-800">{@laporan.nim_nip}</span>
              </div>
              <div class="space-y-1">
                <span class="text-xs text-slate-400 font-medium">No. WhatsApp / HP</span>
                <span class="block font-semibold text-slate-850">
                  {@laporan.no_hp || "-"}
                </span>
              </div>
              <div class="space-y-1">
                <span class="text-xs text-slate-400 font-medium">Fakultas / Unit Kerja</span>
                <span class="block font-semibold text-slate-805">{@laporan.fakultas_unit_kerja}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Form Tindakan Admin (1 col) -->
        <div class="space-y-6">
          <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 space-y-6">
            <h3 class="text-lg font-bold text-slate-900 border-b border-slate-100 pb-3">Tindakan Admin</h3>

            <.form for={@form} id="laporan-response-form" phx-change="validate" phx-submit="save" class="space-y-4">
              <div class="space-y-1">
                <.input
                  field={@form[:status]}
                  type="select"
                  label="Ubah Status Laporan"
                  options={[
                    {"Menunggu", "Menunggu"},
                    {"Diproses", "Diproses"},
                    {"Selesai", "Selesai"},
                    {"Ditolak", "Ditolak"}
                  ]}
                  class="w-full text-sm rounded-xl"
                />
              </div>

              <div class="space-y-1">
                <.input
                  field={@form[:tanggapan_admin]}
                  type="textarea"
                  label="Tanggapan / Solusi Admin"
                  placeholder="Tulis balasan atau tindak lanjut atas pengaduan ini..."
                  rows="6"
                  class="w-full text-sm rounded-xl focus:ring-indigo-500 focus:border-indigo-500"
                />
              </div>

              <div class="pt-4">
                <button
                  type="submit"
                  class="w-full btn btn-primary flex items-center justify-center gap-2 py-3 px-4 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-sm font-semibold shadow-md transition"
                >
                  <.icon name="hero-check" class="w-5 h-5" />
                  Simpan Perubahan
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "px-3 py-1 rounded-full text-xs font-semibold tracking-wider border shadow-sm",
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
