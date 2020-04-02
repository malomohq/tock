defmodule Tock.MixProject do
  use Mix.Project

  def project do
    [
      app: :tock,
      version: "0.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
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
end
