defmodule FormulaBuilder.MixProject do
  use Mix.Project

  def project do
    [
      app: :formula_builder,
      version: "0.1.0",
      elixir: "~> 1.13",
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
      ]
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
      {:decimal, "~> 2.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
