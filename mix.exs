defmodule SecretMessagesBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :secret_messages_bot,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix_env == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :gen_stage, :kcl, :parse_trans, :poison,
        :websocket_client],
      # mod: {SecretMessagesBot.Application, []}
      mod: {SecretMessagesBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:alchemy, git: "https://github.com/BenAlbin/alchemy.git"},
      {:distillery, "~> 1.5", runtime: false}
    ]
  end
end
