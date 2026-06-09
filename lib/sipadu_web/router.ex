defmodule SipaduWeb.Router do
  use SipaduWeb, :router
  import SipaduWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SipaduWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :require_auth do
    plug :require_authenticated_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SipaduWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", AuthController, :login
  end

  scope "/", SipaduWeb do
    pipe_through [:browser, :require_auth]

    get "/survei", SurveiController, :index
    post "/survei", SurveiController, :create

    # Laporan / Pengaduan Routes
    get "/laporan", LaporanController, :index
    get "/laporan/baru", LaporanController, :new
    post "/laporan", LaporanController, :create
    get "/laporan/lampiran/:filename", LaporanController, :show_file
  end

  live_session :admin,
    on_mount: [{SipaduWeb.UserAuth, :ensure_admin}],
    layout: {SipaduWeb.Layouts, :admin} do

    scope "/admin", SipaduWeb.Admin do
      pipe_through [:browser]

      live "/", DashboardLive
      live "/laporan", LaporanLive.Index
      live "/laporan/:id", LaporanLive.Show
      live "/users", UserLive.Index
      live "/kategori", KategoriLive.Index
      live "/evaluasi", EvaluasiLive.Index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SipaduWeb do
  #   pipe_through :api
  # end

  scope "/auth", SipaduWeb do
    pipe_through :browser

    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sipadu, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SipaduWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
