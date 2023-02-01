defmodule DoraWeb.HomeView do
  use DoraWeb, :view

  def render("index.json", _assigns) do
    %{data: "Swiper, no swiping. Swiper, no swiping. Swiper, no swiping!"}
  end
end
