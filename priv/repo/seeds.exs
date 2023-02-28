# script for populating the database. You can run it as:
#
#   mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#   Blog.Repo.insert!(%Blog.Someschema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Dora.Accounts

admin_address =
  System.get_env("ADMIN_ETH_ADDRESS") ||
    raise """
    Please configure ADMIN_ETH_ADDRESS=0xsome_address
    as the admin address with access to Dora.
    """

Accounts.create_user(admin_address)
