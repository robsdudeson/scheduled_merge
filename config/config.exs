import Config

config :scheduled_merge,
  github: [
    org: System.get_env("GITHUB_REPOSITORY_OWNER"),
    repo: System.get_env("GITHUB_REPOSITORY"),
    api_url: System.get_env("GITHUB_API_URL"),
    api_token: System.get_env("GITHUB_TOKEN")
  ]

import_config "#{config_env()}.exs"
