defmodule ScheduledMerge.Github.Client do
  def fetch_pulls(org, repo, url_base, token) do
    headers = [
      {"accept", "application/vnd.github+json"},
      {"authorization", "Bearer #{token}"}
    ]

    "#{url_base}/repos/#{org}/#{repo}/pulls"
    |> HTTPoison.get!(headers)
    |> case do
      %{status_code: 200, body: body} ->
        Jason.decode!(body)
    end
  end
end
