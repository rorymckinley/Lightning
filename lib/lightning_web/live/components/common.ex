defmodule LightningWeb.Components.Common do
  @moduledoc """
  Common Components
  """
  use LightningWeb, :component

  def button(assigns) do
    base_classes = ~w[
      inline-flex
      justify-center
      py-2
      px-4
      border
      border-transparent
      shadow-sm
      text-sm
      font-medium
      rounded-md
      text-white
      focus:outline-none
      focus:ring-2
      focus:ring-offset-2
      focus:ring-indigo-500
    ]

    active_classes = ~w[
      bg-indigo-600
      hover:bg-indigo-700
    ] ++ base_classes

    inactive_classes = ~w[
      bg-indigo-300
    ] ++ base_classes

    class =
      if assigns[:disabled] do
        inactive_classes
      else
        active_classes
      end

    extra = assigns_to_attributes(assigns, [:disabled, :text])

    assigns =
      Phoenix.LiveView.assign_new(assigns, :disabled, fn -> false end)
      |> assign(:class, class)
      |> assign(:extra, extra)

    ~H"""
    <button type="button" class={@class} disabled={@disabled} {@extra}>
      <%= if assigns[:inner_block], do: render_slot(@inner_block), else: @text %>
    </button>
    """
  end

  def item_bar(assigns) do
    assigns = assign(assigns, Map.merge(%{id: nil}, assigns))

    ~H"""
    <div
      class="w-full rounded-md drop-shadow-sm
           outline-2 outline-blue-300
           hover:outline hover:drop-shadow-none
        bg-white flex mb-4"
      id={@id}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end