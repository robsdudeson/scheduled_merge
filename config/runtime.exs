import Config
import Dotenvy

source!([".env", ".env.local", System.get_env()])

github_org = env!("GITHUB_REPOSITORY_OWNER")
github_repo = env!("GITHUB_REPOSITORY")
github_api_url = env!("GITHUB_API_URL")
github_api_token = env!("GITHUB_TOKEN")

config :scheduled_merge,
  github: [
    org: github_org,
    repo: github_repo,
    api_url: github_api_url,
    api_token: github_api_token
  ]
