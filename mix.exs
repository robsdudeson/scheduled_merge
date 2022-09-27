defmodule ScheduledMerge.MixProject do
  use Mix.Project

  def project do
    [
      app: :scheduled_merge,
      deps: deps(),
      description: "merges github pull requests based on labels",
      elixir: "~> 1.13",
      package: package(),
      start_permanent: Mix.env() == :prod,
      source_url: github_url(),
      version: "0.0.1"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

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
