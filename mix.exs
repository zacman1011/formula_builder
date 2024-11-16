defmodule FormulaBuilder.MixProject do
  use Mix.Project

  def project do
    [
      app: :formula_builder,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "FormulaBuilder",
      source_url: "https://github.com/zacman1011/formula_builder",
      homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: [
        main: "FormulaBuilder", # The main page in the docs
        #logo: "path/to/logo.png",
        extras: ["README.md"]
      ],
      test_coverage: [
        summary: [threshold: 90],
        ignore_modules: []
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal, git: "git@github.com:zacman1011/decimal.git", branch: "neq"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
