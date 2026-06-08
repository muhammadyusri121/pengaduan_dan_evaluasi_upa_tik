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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    kategori = Pengaduan.get_kategori!(String.to_integer(id))

    case Pengaduan.delete_kategori(kategori) do
      {:ok, deleted} ->
        socket =
          socket
          |> put_flash(:info, "Kategori #{deleted.nama} berhasil dihapus.")
          |> stream_delete(:kategori_list, deleted)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus kategori. Kategori mungkin sedang digunakan oleh laporan lain.")}
    end
  end

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
    <div class="space-y-6">
      <div>
        <h1 class="text-2xl font-bold text-slate-900">Kategori Permasalahan</h1>
        <p class="text-sm text-slate-500 mt-1">Kelola jenis kategori permasalahan yang dapat dipilih oleh pengguna saat membuat laporan.</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Form Kategori (1 col) -->
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 h-fit space-y-4">
          <h2 class="text-lg font-bold text-slate-900 border-b border-slate-100 pb-3">
            {if @editing_kategori, do: "Edit Kategori", else: "Tambah Kategori Baru"}
          </h2>

          <.form for={@form} id="kategori-form" phx-change="validate" phx-submit="save" class="space-y-4">
            <div class="space-y-1">
              <.input
                field={@form[:nama]}
                type="text"
                label="Nama Kategori"
                placeholder="Contoh: Layanan Jaringan"
                class="w-full text-sm rounded-xl focus:ring-indigo-500 focus:border-indigo-500"
              />
            </div>

            <div class="space-y-1">
              <.input
                field={@form[:deskripsi]}
                type="textarea"
                label="Deskripsi Kategori"
                placeholder="Deskripsi singkat mengenai jenis permasalahan..."
                rows="4"
                class="w-full text-sm rounded-xl focus:ring-indigo-500 focus:border-indigo-500"
              />
            </div>

            <div class="flex items-center gap-2">
              <.input field={@form[:aktif]} type="checkbox" label="Kategori Aktif" />
            </div>

            <div class="flex gap-2 pt-2">
              <button
                type="submit"
                class="flex-1 btn btn-primary py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-sm transition"
              >
                {if @editing_kategori, do: "Update Kategori", else: "Tambah Kategori"}
              </button>
              
              <%= if @editing_kategori do %>
                <button
                  type="button"
                  phx-click="cancel"
                  class="btn btn-ghost px-3 py-2.5 border border-slate-200 hover:bg-slate-50 text-slate-700 rounded-xl text-xs font-semibold"
                >
                  Batal
                </button>
              <% end %>
            </div>
          </.form>
        </div>

        <!-- Tabel Kategori (2 cols) -->
        <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-slate-50 border-b border-slate-100 text-xs font-bold text-slate-500 uppercase tracking-wider">
                  <th class="px-6 py-4">Nama Kategori</th>
                  <th class="px-6 py-4">Deskripsi</th>
                  <th class="px-6 py-4 text-center">Status</th>
                  <th class="px-6 py-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody id="kategori-table" phx-update="stream" class="divide-y divide-slate-150">
                <tr :for={{id, kat} <- @streams.kategori_list} id={id} class="hover:bg-slate-50/50 transition">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="font-semibold text-slate-900">{kat.nama}</span>
                  </td>
                  <td class="px-6 py-4 text-sm text-slate-500 max-w-xs truncate">
                    {kat.deskripsi || "-"}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-center">
                    <button
                      phx-click="toggle_status"
                      phx-value-id={kat.id}
                      class={[
                        "px-2.5 py-1 rounded-full text-xs font-semibold border transition shadow-sm",
                        kat.aktif && "text-emerald-800 bg-emerald-100 border-emerald-200 hover:bg-emerald-200",
                        !kat.aktif && "text-rose-800 bg-rose-100 border-rose-200 hover:bg-rose-200"
                      ]}
                    >
                      {if kat.aktif, do: "Aktif", else: "Non-aktif"}
                    </button>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm">
                    <div class="flex justify-end gap-2">
                      <button
                        phx-click="edit"
                        phx-value-id={kat.id}
                        class="p-1 text-indigo-650 hover:bg-indigo-50 rounded"
                        title="Edit Kategori"
                      >
                        <.icon name="hero-pencil-square" class="w-4 h-4" />
                      </button>
                      <button
                        phx-click="delete"
                        phx-value-id={kat.id}
                        data-confirm="Apakah Anda yakin ingin menghapus kategori ini?"
                        class="p-1 text-rose-600 hover:bg-rose-50 rounded"
                        title="Hapus Kategori"
                      >
                        <.icon name="hero-trash" class="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
