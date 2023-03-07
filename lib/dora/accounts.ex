defmodule Dora.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Dora.Repo

  alias Dora.Accounts.{User, UserToken}

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_eth_address(nil), do: nil
  def get_user_by_eth_address(eth_address), do: Repo.get_by(User, eth_address: eth_address)

  ## API Management

  def list_user_api_tokens(user) do
    Repo.all(UserToken.user_and_contexts_query(user, ["api"]))
  end

  def generate_user_api_token(user) do
    {token, user_token} = UserToken.build_api_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_api_token(token) do
    {:ok, query} = UserToken.verify_api_token_query(token)
    Repo.one(query)
  end

  def delete_user_api_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "api"))
    :ok
  end

  ## Session

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  def generate_account_nonce do
    :crypto.strong_rand_bytes(10)
    |> Base.encode16()
  end

  def update_user_nonce(eth_address) do
    user = get_user_by_eth_address(eth_address)

    attrs = %{
      "eth_address" => eth_address,
      "nonce" => generate_account_nonce()
    }

    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def create_user(eth_address) do
    attrs = %{
      "eth_address" => eth_address,
      "nonce" => generate_account_nonce()
    }

    case get_user_by_eth_address(eth_address) do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  def find_user_by_public_address(eth_address) do
    Repo.get_by(User, eth_address: eth_address)
  end

  def verify_message_signature(eth_address, signature) do
    with user = %User{} <- find_user_by_public_address(eth_address) do
      message = "You are signing this message to sign in with Dora. Nonce: #{user.nonce}"

      signing_address = ExWeb3EcRecover.recover_personal_signature(message, signature)

      if String.downcase(signing_address) == String.downcase(eth_address) do
        update_user_nonce(eth_address)
        user
      end
    end
  end
end
