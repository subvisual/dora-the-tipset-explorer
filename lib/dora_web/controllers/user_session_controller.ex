defmodule DoraWeb.UserSessionController do
  use DoraWeb, :controller

  alias Dora.Accounts
  alias DoraWeb.UserAuth

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"public_address" => eth_address, "signature" => signature} = params, info) do
    user = Accounts.verify_message_signature(eth_address, signature)

    if user do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, params)
    else
      conn
      |> put_flash(:error, "Invalid wallet")
      |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
