defmodule DoraWeb.ApiManagementLive do
  use DoraWeb, :live_view

  alias Dora.Settings
  alias Dora.Accounts.UserToken
  alias Dora.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       tokens: Accounts.list_user_api_tokens(socket.assigns.current_user),
       new_token: nil,
       setting: Settings.get_or_create_setting()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="pb-16">
      <h1 class="font-bold text-4xl">API Settings</h1>
      <div class="py-8">
        <form phx-submit="save-settings">
          <.input
            type="checkbox"
            label="Protected API"
            name="protected_api"
            value={@setting.protected_api}
          />

          <div class={[
            "mt-4 sm:w-96 z-50 rounded-lg p-3 shadow-md shadow-zinc-900/5 ring-1",
            @setting.protected_api && "bg-sky-50 text-sky-800 ring-sky-500 fill-cyan-900",
            !@setting.protected_api &&
              "bg-yellow-50 p-3 text-yellow-900 shadow-md ring-yellow-500 fill-yellow-900"
          ]}>
            <p class="flex items-center gap-1.5 text-[0.8125rem] font-semibold leading-6">
              <Heroicons.shield_check :if={@setting.protected_api} mini class="h-4 w-4" />
              <Heroicons.shield_exclamation :if={!@setting.protected_api} mini class="h-4 w-4" />
              <%= protected_notice_title(@setting.protected_api) %>
            </p>
            <p class="mt-1 text-[0.8125rem] leading-5">
              <%= protected_notice_description(@setting.protected_api) %>
            </p>
          </div>

          <.button type="submit" class="mt-4 flex items-center gap-2">
            Save <Heroicons.check class="h-5 w-5" />
          </.button>
        </form>
      </div>

      <h1 class="font-bold text-4xl">Your API tokens</h1>
      <.table id="tokens" rows={@tokens}>
        <:col :let={api_token} label="Token Hash">
          <%= Base.encode64(api_token.token) %>
        </:col>
        <:col :let={api_token} label="Inserted At">
          <%= Calendar.strftime(api_token.inserted_at, "%d/%m/%y") %>
        </:col>
        <:col :let={api_token} label="Valid Until">
          <%= token_valid_until(api_token) %>
        </:col>
        <:action :let={api_token}>
          <.button phx-click="delete" phx-value-token={Base.encode64(api_token.token)} type="button">
            <Heroicons.trash class="h-4 w-4" />
          </.button>
        </:action>
      </.table>

      <div class={[
        "flex items-start gap-4 pb-8 border-t mt-4 pt-4",
        @new_token && "justify-between",
        is_nil(@new_token) && "justify-end"
      ]}>
        <%= if @new_token do %>
          <div class={[
            "w-3/4 rounded-lg p-3 shadow-md shadow-zinc-900/5 ring-1 truncate",
            "bg-sky-50 text-sky-800 ring-sky-500 fill-cyan-900"
          ]}>
            <p class="text-[0.8125rem] font-semibold leading-6">
              This is your new token to be used for Dora API requests.
            </p>
            <p class="text-[0.8125rem] leading-5">
              Please store it somewhere safe, as you won't be able to see it again!
            </p>
            <div class="flex items-center gap-2 mt-4">
              <div type="button" role="button" title="Copy!">
                <Heroicons.clipboard_document_list
                  phx-click={JS.dispatch("dora:clipcopy", to: "#new-token-value")}
                  mini
                  class="h-8 w-8"
                />
              </div>
              <span id="new-token-value" class="text-base font-bold leading-5 truncate">
                <%= @new_token %>
              </span>
            </div>
          </div>
        <% end %>

        <.button
          phx-click="create"
          type="button"
          class="flex items-center gap-2 text-zinc-700 bg-zinc-100 hover:bg-zinc-100 active:text-green-500 enabled:hover:bg-zinc-200/80 enabled:active:text-zinc-900/70"
        >
          Create Token <Heroicons.key class="h-5 w-5" />
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("save-settings", params, socket) do
    {:ok, setting} = Settings.update_setting(params)

    {:noreply, assign(socket, setting: setting)}
  end

  @impl true
  def handle_event("create", _params, socket) do
    token = Accounts.generate_user_api_token(socket.assigns.current_user)

    {:noreply,
     assign(socket,
       tokens: Accounts.list_user_api_tokens(socket.assigns.current_user),
       new_token: token
     )}
  end

  @impl true
  def handle_event("delete", %{"token" => token}, socket) do
    token
    |> Base.decode64!()
    |> Accounts.delete_user_api_token()

    {:noreply,
     assign(socket,
       tokens: Accounts.list_user_api_tokens(socket.assigns.current_user)
     )}
  end

  defp protected_notice_title(false), do: "Your Dora API is not Protected!"
  defp protected_notice_title(true), do: "Your Dora API is Protected!"

  defp protected_notice_description(false),
    do: "This means that anyone can make requests to it without any authentication."

  defp protected_notice_description(true),
    do: "This means that requests need a token, using the `Bearer` in Authorization header."

  defp token_valid_until(token) do
    valid_days = UserToken.days_api_token_valid()

    token.inserted_at
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.add(valid_days, :day)
    |> Calendar.strftime("%d/%m/%y")
  end
end
