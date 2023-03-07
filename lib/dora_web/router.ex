defmodule DoraWeb.Router do
  use DoraWeb, :router

  import DoraWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DoraWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", DoraWeb do
    pipe_through :browser

    live_session :current_user,
      on_mount: [{DoraWeb.UserAuth, :mount_current_user}] do
      live "/", PlaygroundLive
    end

    live_session :authenticated, on_mount: [{DoraWeb.UserAuth, :ensure_authenticated}] do
      live "/api_management", ApiManagementLive
    end

    scope "/api" do
      pipe_through :api

      get "/events/:type", EventController, :index
      get "/projections/:type", ProjectionController, :index
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dora, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DoraWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", DoraWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", DoraWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
