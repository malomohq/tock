defmodule Tock.MixProject do
  use Mix.Project

  def project do
    [
      app: :tock,
      version: "1.0.2",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: { Tock.Application, [] }
    ]
  end

  defp deps do
    [
      { :ex_doc, ">= 0.0.0", only: :dev, runtime: false },
      { :dialyxir, "~> 1.0", only: :dev, runtime: false }
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "./_build/#{Mix.env()}"
    ]
  end

  defp package do
    %{
      description: "Mock remote function calls made by Task.Supervisor",
      maintainers: ["Anthony Smith"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/malomohq/tock",
        "Made by Malomo - Post-purchase experiences that customers love": "https://gomalomo.com"
      }
    }
  end
end
