defmodule Snaktrip.Mixfile do
  use Mix.Project

  def project do
    [app: :snaktrip,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:cowboy, :plug, :gproc, :logger],
      mod: {SnaktripApp, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:gproc, "~> 0.6.1"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      {:poolboy, "~> 1.5"},
      {:rethinkdb, "~> 0.4.0"},
      {:secure_random, "~> 0.5"},
      {:inflex, "~> 1.7.0" }
    ]
  end
end
