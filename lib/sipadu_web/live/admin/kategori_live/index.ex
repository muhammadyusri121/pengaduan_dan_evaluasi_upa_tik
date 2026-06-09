defmodule SipaduWeb.Admin.KategoriLive.Index do
  use SipaduWeb, :live_view

  alias Sipadu.Pengaduan
  alias Sipadu.Pengaduan.KategoriPermasalahan

  @impl true
  def mount(_params, _session, socket) do
    kategori_list = Pengaduan.list_kategori()
    changeset = Pengaduan.change_kategori(%KategoriPermasalahan{})

    socket =
      socket
      |> assign(page_title: "Kelola Kategori Laporan")
      |> assign(editing_kategori: nil)
      # Tambahan: State untuk Pop-up Hapus
      |> assign(kategori_to_delete: nil)
      |> assign(form: to_form(changeset))
      |> stream(:kategori_list, kategori_list)

    {:ok, socket}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    kategori = Pengaduan.get_kategori!(String.to_integer(id))
    changeset = Pengaduan.change_kategori(kategori)

    socket =
      socket
      |> assign(editing_kategori: kategori)
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    changeset = Pengaduan.change_kategori(%KategoriPermasalahan{})

    socket =
      socket
      |> assign(editing_kategori: nil)
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"kategori_permasalahan" => params}, socket) do
    changeset =
      case socket.assigns.editing_kategori do
        nil -> %KategoriPermasalahan{}
        kategori -> kategori
      end
      |> Pengaduan.change_kategori(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"kategori_permasalahan" => params}, socket) do
    save_kategori(socket, socket.assigns.editing_kategori, params)
  end

  # --- EVENT BARU UNTUK POP UP HAPUS ---

  @impl true
  def handle_event("request_delete", %{"id" => id}, socket) do
    # Buka pop-up dengan menyimpan data kategori yang mau dihapus
    kategori = Pengaduan.get_kategori!(String.to_integer(id))
    {:noreply, assign(socket, kategori_to_delete: kategori)}
  end

  @impl true
  def handle_event("cancel_delete", _params, socket) do
    # Tutup pop-up
    {:noreply, assign(socket, kategori_to_delete: nil)}
  end

  @impl true
  def handle_event("confirm_delete", _params, socket) do
    # Eksekusi hapus setelah dikonfirmasi di Pop-up
    kategori = socket.assigns.kategori_to_delete

    case Pengaduan.delete_kategori(kategori) do
      {:ok, deleted} ->
        socket =
          socket
          |> put_flash(:info, "Kategori #{deleted.nama} berhasil dihapus.")
          |> stream_delete(:kategori_list, deleted)
          # Tutup pop up
          |> assign(kategori_to_delete: nil)

        {:noreply, socket}

      {:error, _changeset} ->
        socket =
          socket
          |> put_flash(
            :error,
            "Gagal menghapus kategori. Kategori mungkin sedang digunakan oleh laporan lain."
          )
          # Tutup pop up
          |> assign(kategori_to_delete: nil)

        {:noreply, socket}
    end
  end

  # -------------------------------------

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    kategori = Pengaduan.get_kategori!(String.to_integer(id))
    new_status = !kategori.aktif

    case Pengaduan.update_kategori(kategori, %{aktif: new_status}) do
      {:ok, updated} ->
        status_text = if updated.aktif, do: "diaktifkan", else: "dinonaktifkan"

        socket =
          socket
          |> put_flash(:info, "Kategori #{updated.nama} berhasil #{status_text}.")
          |> stream_insert(:kategori_list, updated)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Gagal mengubah status kategori.")}
    end
  end

  defp save_kategori(socket, nil, params) do
    case Pengaduan.create_kategori(params) do
      {:ok, kategori} ->
        changeset = Pengaduan.change_kategori(%KategoriPermasalahan{})

        socket =
          socket
          |> put_flash(:info, "Kategori #{kategori.nama} berhasil ditambahkan.")
          |> assign(form: to_form(changeset))
          |> stream_insert(:kategori_list, kategori, at: 0)

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_kategori(socket, %KategoriPermasalahan{} = editing, params) do
    case Pengaduan.update_kategori(editing, params) do
      {:ok, kategori} ->
        changeset = Pengaduan.change_kategori(%KategoriPermasalahan{})

        socket =
          socket
          |> put_flash(:info, "Kategori #{kategori.nama} berhasil diperbarui.")
          |> assign(editing_kategori: nil)
          |> assign(form: to_form(changeset))
          |> stream_insert(:kategori_list, kategori)

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto pb-12 space-y-8 relative">
      <div class="mb-8">
        <h1 class="text-3xl font-extrabold text-slate-900 tracking-tight">Kategori Permasalahan</h1>
        <p class="text-base text-slate-500 mt-1.5">
          Kelola jenis kategori permasalahan yang dapat dipilih oleh pengguna saat membuat laporan.
        </p>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-3 gap-8 items-start">
        <div class="xl:col-span-1 bg-white p-7 rounded-[2rem] shadow-[0_2px_20px_rgb(0,0,0,0.04)] border border-slate-100 sticky top-24">
          <div class="flex items-center gap-3 mb-6">
            <div class={[
              "p-2 rounded-xl text-white shadow-md",
              (@editing_kategori && "bg-amber-500") || "bg-blue-600"
            ]}>
              <.icon
                name={if @editing_kategori, do: "hero-pencil-square", else: "hero-plus-circle"}
                class="w-5 h-5"
              />
            </div>
            <h2 class="text-xl font-extrabold text-slate-900">
              {if @editing_kategori, do: "Edit Kategori", else: "Tambah Kategori Baru"}
            </h2>
          </div>

          <.form
            for={@form}
            id="kategori-form"
            phx-change="validate"
            phx-submit="save"
            class="space-y-5"
          >
            <div class="flex flex-col gap-1.5">
              <label class="text-xs font-extrabold text-slate-500 uppercase tracking-widest ml-1">
                Nama Kategori
              </label>
              <input
                type="text"
                name={@form[:nama].name}
                value={@form[:nama].value}
                placeholder="Contoh: Layanan Jaringan"
                class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 text-sm font-semibold focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all outline-none"
              />
              <%= if @form[:nama].errors != [] do %>
                <span class="text-xs font-bold text-rose-500 ml-1">Nama wajib diisi.</span>
              <% end %>
            </div>

            <div class="flex flex-col gap-1.5">
              <label class="text-xs font-extrabold text-slate-500 uppercase tracking-widest ml-1">
                Deskripsi
              </label>
              <textarea
                name={@form[:deskripsi].name}
                rows="4"
                placeholder="Deskripsi singkat jenis permasalahan..."
                class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 text-sm focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all outline-none resize-none"
              ><%= @form[:deskripsi].value %></textarea>
            </div>

            <div class="flex items-center gap-3 p-3 bg-slate-50 rounded-xl border border-slate-200">
              <input type="hidden" name={@form[:aktif].name} value="false" />
              <input
                type="checkbox"
                id="aktif-checkbox"
                name={@form[:aktif].name}
                value="true"
                checked={@form[:aktif].value}
                class="w-5 h-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
              />
              <label
                for="aktif-checkbox"
                class="text-sm font-bold text-slate-700 cursor-pointer select-none"
              >
                Status Kategori Aktif
              </label>
            </div>

            <div class="flex flex-col gap-3 pt-4 border-t border-slate-100">
              <button
                type="submit"
                class={[
                  "w-full flex items-center justify-center gap-2 text-white text-sm font-bold py-3.5 px-4 rounded-xl shadow-md hover:shadow-lg transition-all active:scale-95",
                  (@editing_kategori && "bg-amber-500 hover:bg-amber-600") ||
                    "bg-blue-600 hover:bg-blue-700"
                ]}
              >
                <.icon name="hero-check" class="w-5 h-5" />
                {if @editing_kategori, do: "Simpan Perubahan", else: "Tambah Kategori"}
              </button>

              <%= if @editing_kategori do %>
                <button
                  type="button"
                  phx-click="cancel"
                  class="w-full text-slate-600 hover:text-slate-900 bg-slate-100 hover:bg-slate-200 text-sm font-bold py-3.5 px-4 rounded-xl transition-colors"
                >
                  Batal Edit
                </button>
              <% end %>
            </div>
          </.form>
        </div>

        <div class="xl:col-span-2 bg-white rounded-[2rem] shadow-[0_2px_20px_rgb(0,0,0,0.04)] border border-slate-100 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-slate-50/80 border-b border-slate-100 text-[11px] font-extrabold text-slate-500 uppercase tracking-widest">
                  <th class="px-8 py-5">Nama & Deskripsi</th>
                  <th class="px-8 py-5 text-center">Status</th>
                  <th class="px-8 py-5 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody id="kategori-table" phx-update="stream" class="divide-y divide-slate-100">
                <tr
                  :for={{id, kat} <- @streams.kategori_list}
                  id={id}
                  class="hover:bg-slate-50/80 transition-colors group"
                >
                  <td class="px-8 py-5">
                    <span class="block text-sm font-extrabold text-slate-800 mb-0.5">{kat.nama}</span>
                    <span class="block text-xs font-medium text-slate-500 truncate max-w-xs md:max-w-md">
                      {kat.deskripsi || "Tidak ada deskripsi."}
                    </span>
                  </td>

                  <td class="px-8 py-5 whitespace-nowrap text-center">
                    <button
                      phx-click="toggle_status"
                      phx-value-id={kat.id}
                      class={[
                        "px-3 py-1.5 rounded-full text-xs font-bold tracking-wide transition-all shadow-sm flex items-center justify-center gap-1.5 w-fit mx-auto active:scale-95 border",
                        kat.aktif &&
                          "text-emerald-700 bg-emerald-50 border-emerald-200 hover:bg-emerald-100 hover:border-emerald-300",
                        !kat.aktif &&
                          "text-rose-700 bg-rose-50 border-rose-200 hover:bg-rose-100 hover:border-rose-300"
                      ]}
                      title="Klik untuk mengubah status"
                    >
                      <span class={[
                        "w-1.5 h-1.5 rounded-full",
                        kat.aktif && "bg-emerald-500",
                        !kat.aktif && "bg-rose-500"
                      ]}>
                      </span>
                      {if kat.aktif, do: "Aktif", else: "Non-aktif"}
                    </button>
                  </td>

                  <td class="px-8 py-5 whitespace-nowrap text-right">
                    <div class="flex items-center justify-end gap-2">
                      <button
                        phx-click="edit"
                        phx-value-id={kat.id}
                        class="p-2 text-slate-400 hover:text-amber-500 hover:bg-amber-50 rounded-xl transition-all shadow-sm border border-transparent hover:border-amber-200"
                        title="Edit"
                      >
                        <.icon name="hero-pencil-square" class="w-5 h-5" />
                      </button>

                      <button
                        phx-click="request_delete"
                        phx-value-id={kat.id}
                        class="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-all shadow-sm border border-transparent hover:border-rose-200"
                        title="Hapus"
                      >
                        <.icon name="hero-trash" class="w-5 h-5" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <%= if @kategori_to_delete do %>
        <div class="relative z-[100]" aria-labelledby="modal-title" role="dialog" aria-modal="true">
          <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm transition-opacity"></div>

          <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
            <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
              <div class="relative transform overflow-hidden rounded-3xl bg-white text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-lg border border-slate-100 animate-in fade-in zoom-in-95 duration-200">
                <div class="bg-white px-6 pb-6 pt-8 sm:p-8">
                  <div class="sm:flex sm:items-start gap-5">
                    <div class="mx-auto flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-full bg-rose-100 sm:mx-0 sm:h-14 sm:w-14">
                      <.icon name="hero-exclamation-triangle-solid" class="h-7 w-7 text-rose-600" />
                    </div>

                    <div class="mt-4 text-center sm:ml-4 sm:mt-0 sm:text-left flex-1">
                      <h3 class="text-xl font-extrabold leading-6 text-slate-900" id="modal-title">
                        Hapus Kategori
                      </h3>
                      <div class="mt-3">
                        <p class="text-sm text-slate-500 leading-relaxed">
                          Apakah Anda yakin ingin menghapus kategori <br />
                          <span class="font-extrabold text-slate-800 text-base block mt-1 py-2 px-3 bg-slate-50 border border-slate-200 rounded-lg">
                            "{@kategori_to_delete.nama}"
                          </span>
                        </p>
                        <p class="text-xs text-rose-500 font-bold mt-3">
                          *Tindakan ini tidak dapat dibatalkan.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="bg-slate-50 px-6 py-5 sm:flex sm:flex-row-reverse gap-3 border-t border-slate-100">
                  <button
                    type="button"
                    phx-click="confirm_delete"
                    class="inline-flex w-full justify-center items-center gap-2 rounded-xl bg-rose-600 px-6 py-3 text-sm font-bold text-white shadow-md hover:bg-rose-700 sm:w-auto transition-all active:scale-95"
                  >
                    <.icon name="hero-trash" class="w-4 h-4" /> Ya, Hapus
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_delete"
                    class="mt-3 inline-flex w-full justify-center rounded-xl bg-white px-6 py-3 text-sm font-bold text-slate-700 shadow-sm ring-1 ring-inset ring-slate-200 hover:bg-slate-50 sm:mt-0 sm:w-auto transition-colors"
                  >
                    Batal
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
