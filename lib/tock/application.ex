defmodule Tock.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args), do: Tock.Supervisor.start_link()
end
