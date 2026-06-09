defmodule SipaduWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use SipaduWeb, :html

  # Embed all files in layouts/* within this module.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_scope, :map, default: nil, doc: "the current scope"
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="w-full relative">
      <div class="mx-auto">
        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Komponen untuk link navigasi di sidebar admin.
  """
  def admin_nav_links(assigns) do
    ~H"""
    <div class="space-y-1.5">
      <.admin_link navigate={~p"/admin"} icon="hero-chart-bar-square" label="Dashboard" />
      <.admin_link navigate={~p"/admin/laporan"} icon="hero-document-text" label="Laporan Pengaduan" />
      <.admin_link navigate={~p"/admin/kategori"} icon="hero-tag" label="Kategori Laporan" />
      <.admin_link navigate={~p"/admin/evaluasi"} icon="hero-star" label="Rekap Evaluasi" />
      <.admin_link navigate={~p"/admin/users"} icon="hero-users" label="Manajemen User" />

      <div class="pt-5 mt-5 border-t border-slate-100/80">
        <p class="px-4 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest mb-3">
          Sistem
        </p>
        <.admin_link navigate={~p"/"} icon="hero-globe-alt" label="Kembali ke Portal Publik" />
      </div>
    </div>
    """
  end

  attr :navigate, :string, required: true
  attr :icon, :string, required: true
  attr :label, :string, required: true

  def admin_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class="group flex items-center gap-3 px-4 py-3.5 rounded-2xl text-sm font-bold transition-all duration-300 text-slate-500 hover:bg-blue-50 hover:text-blue-700 hover:shadow-sm border border-transparent hover:border-blue-100"
    >
      <.icon name={@icon} class="w-5 h-5 text-slate-400 transition-colors group-hover:text-blue-600" />
      {@label}
    </.link>
    """
  end
end
