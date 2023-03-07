defmodule DoraWeb.ApiManagementLive do
  use DoraWeb, :live_view

  alias Dora.Accounts.UserToken
  alias Dora.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       tokens: Accounts.list_user_api_tokens(socket.assigns.current_user),
       new_token: nil
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="pb-16">
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
            "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900"
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
  def handle_event("create", _params, socket) do
    token = Accounts.generate_user_api_token(socket.assigns.current_user)

    {:noreply,
     assign(socket,
       tokens: Accounts.list_user_api_tokens(socket.assigns.current_user),
       new_token: Base.encode16(token)
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

  defp token_valid_until(token) do
    valid_days = UserToken.days_api_token_valid()

    token.inserted_at
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.add(valid_days, :day)
    |> Calendar.strftime("%d/%m/%y")
  end
end
