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
          |> put_flash(
            :error,
            "Gagal memperbarui laporan. Silakan periksa kesalahan pada formulir."
          )
          |> assign(form: to_form(changeset))

        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8 min-h-screen bg-slate-50/50">
      <div class="mb-8">
        <.link
          navigate={~p"/admin/laporan"}
          class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-blue-600 transition-colors mb-4"
        >
          <.icon name="hero-arrow-left" class="w-4 h-4" /> Kembali ke Daftar Laporan
        </.link>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-3 gap-8 items-start">
        <div class="xl:col-span-2 space-y-6">
          <div class="bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100">
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
              <span class="inline-flex items-center px-3 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-bold uppercase tracking-wider w-fit">
                {@laporan.kategori}
              </span>
              <.status_badge status={@laporan.status} />
            </div>

            <h1 class="text-3xl font-extrabold text-slate-900 mb-8 leading-tight">
              {@laporan.judul_laporan}
            </h1>

            <div class="mb-8">
              <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-3">
                Deskripsi Masalah
              </h3>
              <p class="text-slate-700 text-base leading-relaxed whitespace-pre-line">
                {@laporan.deskripsi}
              </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
              <div class="bg-slate-50 p-5 rounded-2xl border border-slate-100">
                <span class="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">
                  Lokasi Kejadian
                </span>
                <span class="block font-bold text-slate-800 text-base">{@laporan.lokasi}</span>
              </div>
              <div class="bg-slate-50 p-5 rounded-2xl border border-slate-100">
                <span class="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">
                  Tanggal Laporan
                </span>
                <span class="block font-bold text-slate-800 text-base">
                  {Calendar.strftime(@laporan.inserted_at, "%d %B %Y, %H:%M WIB")}
                </span>
              </div>
            </div>

            <div class="mb-8 border-t border-slate-100 pt-8">
              <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">
                Informasi Pelapor
              </h3>
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
                <div>
                  <p class="text-[11px] font-semibold text-slate-400 uppercase mb-0.5">Nama</p>
                  <p class="text-sm font-bold text-slate-800">{@laporan.nama}</p>
                </div>
                <div>
                  <p class="text-[11px] font-semibold text-slate-400 uppercase mb-0.5">NIM/NIP</p>
                  <p class="text-sm font-bold text-slate-800">{@laporan.nim_nip}</p>
                </div>
                <div>
                  <p class="text-[11px] font-semibold text-slate-400 uppercase mb-0.5">Kontak</p>
                  <p class="text-sm font-bold text-blue-600">{@laporan.no_hp || "-"}</p>
                </div>
                <div>
                  <p class="text-[11px] font-semibold text-slate-400 uppercase mb-0.5">Unit</p>
                  <p class="text-sm font-bold text-slate-800">{@laporan.fakultas_unit_kerja}</p>
                </div>
              </div>
            </div>

            <%= if @laporan.lampiran do %>
              <div class="border-t border-slate-100 pt-8">
                <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">
                  Berkas Lampiran
                </h3>

                <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 p-4 rounded-2xl border border-slate-200 bg-white shadow-sm mb-4">
                  <div class="flex items-center gap-3 overflow-hidden">
                    <div class="p-2.5 bg-blue-50 text-blue-600 rounded-xl shrink-0">
                      <.icon name="hero-document" class="w-6 h-6" />
                    </div>
                    <span class="text-sm font-semibold text-slate-700 truncate w-full max-w-[200px] sm:max-w-md">
                      {@laporan.lampiran}
                    </span>
                  </div>
                  <a
                    href={~p"/laporan/lampiran/#{@laporan.lampiran}"}
                    target="_blank"
                    class="shrink-0 flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold px-5 py-2.5 rounded-xl transition-colors w-full sm:w-auto"
                  >
                    <.icon name="hero-arrow-down-tray" class="w-4 h-4" /> Unduh File
                  </a>
                </div>

                <%= if String.ends_with?(String.downcase(@laporan.lampiran), [".jpg", ".jpeg", ".png", ".gif", ".webp"]) do %>
                  <div class="rounded-2xl overflow-hidden border border-slate-200 bg-slate-100">
                    <img
                      src={~p"/laporan/lampiran/#{@laporan.lampiran}"}
                      alt="Lampiran Laporan"
                      class="w-full max-h-[600px] object-contain"
                    />
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>

        <div class="xl:col-span-1">
          <div class="bg-white p-6 sm:p-8 rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-slate-100 sticky top-8">
            <h2 class="text-xl font-extrabold text-slate-900 mb-6 flex items-center gap-2">
              <.icon name="hero-shield-check" class="w-6 h-6 text-blue-600" /> Tindakan Admin
            </h2>

            <.form
              for={@form}
              id="laporan-response-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-6"
            >
              <div class="flex flex-col gap-2">
                <label class="text-sm font-bold text-slate-700">Ubah Status Laporan</label>
                <select
                  name={@form[:status].name}
                  class="w-full px-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 text-sm font-semibold focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all outline-none cursor-pointer"
                >
                  {Phoenix.HTML.Form.options_for_select(
                    [
                      {"Menunggu", "Menunggu"},
                      {"Diproses", "Diproses"},
                      {"Di Respon", "Di Respon"},
                      {"Selesai", "Selesai"},
                      {"Ditolak", "Ditolak"}
                    ],
                    @form[:status].value
                  )}
                </select>
              </div>

              <div class="flex flex-col gap-2">
                <label class="text-sm font-bold text-slate-700">Tanggapan / Solusi Admin</label>
                <textarea
                  name={@form[:tanggapan_admin].name}
                  rows="6"
                  placeholder="Ketik tanggapan atau instruksi solusi di sini..."
                  class="w-full px-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all outline-none resize-none"
                ><%= @form[:tanggapan_admin].value %></textarea>
              </div>

              <div class="pt-2">
                <button
                  type="submit"
                  class="w-full flex items-center justify-center gap-2 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white text-base font-bold py-4 px-6 rounded-xl shadow-lg hover:shadow-xl hover:-translate-y-0.5 active:scale-95 transition-all duration-300"
                >
                  <.icon name="hero-check" class="w-5 h-5" /> Simpan Perubahan
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
      "px-4 py-1.5 rounded-full text-xs font-bold tracking-widest uppercase flex items-center gap-2 shadow-sm border",
      @status == "Menunggu" && "text-amber-700 bg-amber-50 border-amber-200",
      @status == "Diproses" && "text-blue-700 bg-blue-50 border-blue-200",
      @status == "Di Respon" && "text-violet-700 bg-violet-50 border-violet-200",
      @status == "Selesai" && "text-emerald-700 bg-emerald-50 border-emerald-200",
      @status == "Ditolak" && "text-rose-700 bg-rose-50 border-rose-200"
    ]}>
      <span class={[
        "w-2 h-2 rounded-full",
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
