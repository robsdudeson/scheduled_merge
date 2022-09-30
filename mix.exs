defmodule ScheduledMerge.MixProject do
  use Mix.Project

  def project do
    [
      app: :scheduled_merge,
      compilers: Mix.compilers(),
      deps: deps(),
      description: "merges github pull requests based on labels",
      elixir: "~> 1.13",
      elixirc_options: [
        warnings_as_errors: elixirc_warnings_as_errors?(Mix.env())
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      start_permanent: Mix.env() == :prod,
      source_url: github_url(),
      version: "0.0.1"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dotenvy, "~> 0.6.0"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.4"},
      {:sobelow, "~> 0.8", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp elixirc_warnings_as_errors?(env) when env in [:dev, :test], do: false
  defp elixirc_warnings_as_errors?(_), do: true

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Github" => github_url()},
      maintainers: ["Robby Thompson"],
      name: "scheduled_merge"
    ]
  end

  defp github_url, do: "https://github.com/robsdudeson/scheduled_merge"
end
