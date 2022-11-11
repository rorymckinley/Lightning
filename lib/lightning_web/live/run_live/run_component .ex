defmodule LightningWeb.RunLive.RunComponent do
  @moduledoc """
  Run component for WorkOrder list module
  """
  use LightningWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <li>
      <span class="my-4 flex">
        &vdash;
        <span class="mx-2 flex">
          <%= case @run.exit_code do %>
            <% val when val > 0-> %>
              <Heroicons.x_circle
                solid
                class="mr-1.5 h-5 w-5 flex-shrink-0 text-red-500 dark:text-red-400"
              />
            <% val when val == 0 -> %>
              <Heroicons.check_circle
                solid
                class="mr-1.5 h-5 w-5 flex-shrink-0 text-green-500 dark:text-green-400"
              />
            <% _ -> %>
          <% end %>
          <%= @run.job.name %>
        </span>
      </span>
    </li>
    """
  end
end
