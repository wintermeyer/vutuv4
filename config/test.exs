import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :vutuv, Vutuv.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "vutuv_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# Configure the legacy database connection for tests
# Note: Legacy repo should NOT use sandbox mode as it's read-only
config :vutuv, Vutuv.Legacy.Repo,
  username: "vutuv4",
  password: "vutuv4",
  hostname: "localhost",
  database: "vutuv1_dev",
  pool_size: 5

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vutuv, VutuvWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/8bqbr8VVUdu3o4pqIwkkpFz95aONCNXPUOyMKLdlETYEO3UQAYWlFh1YYAGSCu6",
  server: false

# In test we don't send emails
config :vutuv, Vutuv.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
