defmodule SipaduWeb.Admin.UserLive.Index do
  use SipaduWeb, :live_view

  alias Sipadu.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    socket =
      socket
      |> assign(page_title: "Manajemen User")
      |> stream(:user_list, users)

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_role", %{"id" => id}, socket) do
    user = Accounts.get_user(String.to_integer(id))
    current_admin = socket.assigns.current_user

    if user.id == current_admin.id do
      {:noreply, put_flash(socket, :error, "Anda tidak dapat mengubah role akun Anda sendiri.")}
    else
      new_role = if user.role == "admin", do: "user", else: "admin"

      case Accounts.update_user_role(user, new_role) do
        {:ok, updated_user} ->
          socket =
            socket
            |> put_flash(:info, "Role pengguna #{updated_user.name} berhasil diubah menjadi #{updated_user.role}.")
            |> stream_insert(:user_list, updated_user)

          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Gagal memperbarui role pengguna.")}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="relative overflow-hidden flex flex-col justify-center bg-gradient-to-r from-blue-600 to-indigo-700 p-8 rounded-3xl shadow-lg border border-blue-500 mb-8">
        <div class="absolute -right-10 -top-10 opacity-10 pointer-events-none">
          <.icon name="hero-users" class="w-64 h-64 text-white" />
        </div>
        <div class="relative z-10">
          <h1 class="text-3xl font-extrabold text-white tracking-tight">Manajemen User</h1>
          <p class="text-base text-blue-100 mt-1.5 font-medium">
            Kelola hak akses pengguna platform SIPADU.
          </p>
        </div>
      </div>

      <!-- User List Card -->
      <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-100 text-xs font-bold text-slate-500 uppercase tracking-wider">
                <th class="px-6 py-4">Foto</th>
                <th class="px-6 py-4">Nama & Email</th>
                <th class="px-6 py-4">NIM / NIP</th>
                <th class="px-6 py-4">Fakultas / Unit Kerja</th>
                <th class="px-6 py-4 text-center">Role</th>
                <th class="px-6 py-4 text-right">Tindakan</th>
              </tr>
            </thead>
            <tbody id="user-table" phx-update="stream" class="divide-y divide-slate-150">
              <tr :for={{id, user} <- @streams.user_list} id={id} class="hover:bg-blue-50/50 transition-colors duration-200 group">
                <td class="px-6 py-4 whitespace-nowrap">
                  <img src={user.image} class="w-10 h-10 rounded-full border border-slate-200 group-hover:border-blue-300 group-hover:shadow-md transition-all duration-300" alt="Avatar" />
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-semibold text-slate-900 group-hover:text-blue-700 transition-colors">{user.name}</div>
                  <div class="text-xs text-slate-500">{user.email}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-700">
                  {user.nim_nip || "-"}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                  {user.fakultas_unit_kerja || "-"}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <span class={[
                    "px-2.5 py-1 rounded-full text-xs font-semibold uppercase tracking-wider border",
                    user.role == "admin" && "text-indigo-800 bg-indigo-100 border-indigo-200",
                    user.role != "admin" && "text-slate-800 bg-slate-100 border-slate-200"
                  ]}>
                    {user.role}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm">
                  <%= if user.id != @current_user.id do %>
                    <button
                      phx-click="toggle_role"
                      phx-value-id={user.id}
                      class={[
                        "inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all duration-300 border shadow-sm active:scale-95",
                        user.role == "admin" && "text-rose-600 bg-rose-50 border-rose-100 hover:bg-rose-100",
                        user.role != "admin" && "text-indigo-600 bg-indigo-50 border-indigo-100 hover:bg-indigo-100"
                      ]}
                    >
                      <.icon name={if user.role == "admin", do: "hero-user-minus", else: "hero-user-plus"} class="w-4 h-4" />
                      {if user.role == "admin", do: "Demote to User", else: "Promote to Admin"}
                    </button>
                  <% else %>
                    <span class="text-xs text-slate-400 italic">Akun Anda</span>
                  <% end %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end
end
