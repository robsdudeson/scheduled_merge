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

  def comment_issue(%{"number" => number}, comment, org, repo, url_base, token) do
    headers = [
      {"accept", "application/vnd.github+json"},
      {"authorization", "Bearer #{token}"}
    ]

    body =
      Jason.encode!(%{
        body: comment
      })

    "#{url_base}/repos/#{org}/#{repo}/issues/#{number}/comments"
    |> HTTPoison.post!(body, headers)
    |> case do
      %{status_code: 201} -> :ok
    end
  end

  def label_issue(%{"number" => number}, label, org, repo, url_base, token) do
    headers = [
      {"accept", "application/vnd.github+json"},
      {"authorization", "Bearer #{token}"}
    ]

    body =
      %{"labels" => [label]}
      |> Jason.encode!()

    "#{url_base}/repos/#{org}/#{repo}/issues/#{number}/labels"
    |> HTTPoison.post!(body, headers)
    |> case do
      %{status_code: 200} -> :ok
    end
  end

  def fetch_labels(org, repo, url_base, token) do
    headers = [
      {"accept", "application/vnd.github+json"},
      {"authorization", "Bearer #{token}"}
    ]

    "#{url_base}/repos/#{org}/#{repo}/labels"
    |> HTTPoison.get!(headers)
    |> case do
      %{status_code: 200, body: body} -> Jason.decode!(body)
    end
  end

  def fetch_label(name, org, repo, url_base, token) do
    headers = [
      {"accept", "application/vnd.github+json"},
      {"authorization", "Bearer #{token}"}
    ]

    "#{url_base}/repos/#{org}/#{repo}/labels/#{name}"
    |> HTTPoison.get!(headers)
    |> case do
      %{status_code: 200, body: body} -> Jason.decode!(body)
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
