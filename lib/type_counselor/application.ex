defmodule TypeCounselor.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {TypeCounselor.Server, []}
    ]

    opts = [strategy: :one_for_one, name: TypeCounselor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
