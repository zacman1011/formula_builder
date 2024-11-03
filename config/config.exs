import Config

config :formula_builder, FormulaBuilder.Functions,
  functions: %{}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if config_env() == :test do
  import_config "#{config_env()}.exs"
end
