defmodule ScheduledMerge.Github.Client do
  require Logger

  def fetch_pulls do
    "/pulls"
    |> resource_url()
    |> HTTPoison.get!(headers())
    |> case do
      %{status_code: 200, body: body} ->
        Jason.decode!(body)
    end
  end

  def merge_pull(%{"number" => number}) do
    "/pulls/#{number}/merge"
    |> resource_url()
    |> HTTPoison.put!(headers())
    |> case do
      %{status_code: 200} -> :ok
    end
  end

  def comment_issue(%{"number" => number}, comment) do
    body =
      Jason.encode!(%{
        body: comment
      })

    "/issues/#{number}/comments"
    |> resource_url()
    |> HTTPoison.post!(body, headers())
    |> case do
      %{status_code: 201} -> :ok
    end
  end

  def label_issue(%{"number" => number}, label) do
    body =
      %{"labels" => [label]}
      |> Jason.encode!()

    "/issues/#{number}/labels"
    |> resource_url()
    |> HTTPoison.post!(body, headers())
    |> case do
      %{status_code: 200} -> :ok
    end
  end

  def create_label(label) do
    body = Jason.encode!(label)

    "/labels"
    |> resource_url()
    |> HTTPoison.post!(body, headers())
    |> case do
      %{status_code: 200, body: body} -> Jason.decode!(body)
    end
  end

  def fetch_labels do
    "/labels"
    |> resource_url()
    |> HTTPoison.get!(headers())
    |> case do
      %{status_code: 200, body: body} -> Jason.decode!(body)
    end
  end

  def fetch_label(name) do
    "/labels/#{name}"
    |> resource_url()
    |> HTTPoison.get!(headers())
    |> case do
      %{status_code: 200, body: body} -> Jason.decode!(body)
      %{status_code: 404} -> nil
    end
  end

  @doc """
  will call GitHub to attempt to delete the label
  """
  @spec delete_label(map) :: :ok | {:error, list(tuple())}
  def delete_label(%{"name" => label_name}) do
    "/labels/#{label_name}"
    |> resource_url()
    |> HTTPoison.delete!(headers())
    |> case do
      %{status_code: 204} ->
        :ok

      response ->
        message = "there was an error deleting the label"
        Logger.error("#{message}:#{label_name}", response)
        {:error, {label_name, message}}
    end
  end

  defp headers,
    do: [{"accept", "application/vnd.github+json"}, {"authorization", "Bearer #{api_token()}"}]

  defp resource_url(resource) do
    "#{api_url()}/repos/#{org()}/#{repo()}/#{resource}"
  end

  defp org do
    Application.get_env(:scheduled_merge, :github)[:org]
  end

  defp repo do
    Application.get_env(:scheduled_merge, :github)[:repo]
  end

  defp api_url do
    Application.get_env(:scheduled_merge, :github)[:api_url]
  end

  defp api_token do
    Application.get_env(:scheduled_merge, :github)[:api_token]
  end
end
