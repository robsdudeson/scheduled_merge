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

  def merge_pull(%{"number" => number}, org, repo, url_base, token) do
    headers = [
      {"accept", "application/vnd.github+json"},
      {"authorization", "Bearer #{token}"}
    ]

    "#{url_base}/repos/#{org}/#{repo}/pulls/#{number}/merge"
    |> HTTPoison.put!(headers)
    |> case do
      %{status_code: 200} -> :ok
    end
  end

  def delete_label(%{"name" => label_name}, org, repo, url_base, token) do
    headers = [
      {"accept", "application/vnd.github+json"},
      {"authorization", "Bearer #{token}"}
    ]

    "#{url_base}/repos/#{org}/#{repo}/labels/#{label_name}"
    |> HTTPoison.delete!(headers)
    |> case do
      %{status_code: 204} -> :ok
    end
  end
end
