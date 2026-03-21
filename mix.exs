defmodule HL7v2.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/Balneario-de-Cofrentes/hl7v2"

  def project do
    [
      app: :hl7v2,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      name: "HL7v2",
      description:
        "Pure Elixir HL7 v2.x toolkit — schema-driven parsing, typed segments, message builder, MLLP transport",
      package: package(),
      docs: docs(),
      source_url: @source_url,
      preferred_cli_env: [
        test: :test,
        "test.all": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ssl]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ranch, "~> 2.1"},
      {:telemetry, "~> 1.0"},

      # Dev/test only
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:stream_data, "~> 1.0", only: [:test, :dev]}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/hl7v2",
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE"
      ],
      source_ref: System.get_env("SOURCE_REF") || "v#{@version}"
    ]
  end
end
