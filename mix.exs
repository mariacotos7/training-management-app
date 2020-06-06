defmodule TrainingManagement.MixProject do
  use Mix.Project

  def project do
    [
      app: :trainingManagement,
      version: "0.1.0",
      elixir: "~> 1.10.3",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TrainingManagement.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
       {:poison, "~> 3.0", override: true},
            {:rethinkdb, "~> 0.4"},
            {:plug, "~> 1.6"},
            {:cowboy, "~> 2.4"},
            {:plug_cowboy, "~> 2.0"},
            {:timex, "~> 3.0"},
            {:jsonapi, "~> 0.3.0"},
            {:joken, "~> 1.1", override: true}
    ]
  end
end