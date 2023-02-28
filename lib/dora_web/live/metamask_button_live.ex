defmodule DoraWeb.MetamaskButtonLive do
  use DoraWeb, :live_view

  alias Dora.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       connected: false,
       current_wallet_address: nil,
       signature: nil,
       verify_signature: false
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <span title="Metamask" id="metamask-button" phx-hook="Metamask">
      <%= if @connected do %>
        <.form
          for={%{}}
          action={~p"/users/log_in"}
          as={:user}
          phx-submit="verify-current-wallet"
          phx-trigger-action={@verify_signature}
        >
          <.input type="hidden" name="public_address" value={@current_wallet_address} />
          <.input type="hidden" name="signature" value={@signature} />
          <.button type="submit" class={button_css()}>
            <span class="w-6"><.metamask_icon /></span> Sign in
          </.button>
        </.form>
      <% else %>
        <.button class={button_css()} phx-click="connect-metamask">
          <span class="w-6"><.metamask_icon /></span> Connect
        </.button>
      <% end %>
    </span>
    """
  end

  @impl true
  def handle_event("account-check", params, socket) do
    {:noreply,
     assign(socket,
       connected: params["connected"],
       current_wallet_address: params["current_wallet_address"]
     )}
  end

  @impl true
  def handle_event("connect-metamask", _params, socket) do
    {:noreply, push_event(socket, "connect-metamask", %{})}
  end

  @impl true
  def handle_event("wallet-connected", params, socket) do
    {:noreply,
     assign(socket,
       connected: not is_nil(params["public_address"]),
       current_wallet_address: params["public_address"]
     )}
  end

  @impl true
  def handle_event("verify-current-wallet", _params, socket) do
    nonce =
      case Accounts.get_user_by_eth_address(socket.assigns.current_wallet_address) do
        nil -> Accounts.generate_account_nonce()
        user -> user.nonce
      end

    {:noreply, push_event(socket, "get-current-wallet", %{nonce: nonce})}
  end

  @impl true
  def handle_event("verify-signature", params, socket) do
    {:noreply,
     assign(socket,
       signature: params["signature"],
       verify_signature: true
     )}
  end

  defp button_css do
    "w-full flex items-center gap-2 justify-center py-2 px-4 text-brand bg-zinc-100 hover:bg-zinc-200/80 active:text-zinc-900/70"
  end
end
