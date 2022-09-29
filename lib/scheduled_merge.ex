defmodule ScheduledMerge do
  @moduledoc """
  Documentation for `ScheduledMerge`.
  """

  alias ScheduledMerge.Github.Client, as: Github

  alias ScheduledMerge.Github.Pull
  alias ScheduledMerge.Github.Label

  # TODO: config handling
  @github_token_default "redacted"
  @github_api_url_default "https://api.github.com"
  @org_default "robsdudeson"
  @repo_default "scheduled_merge"

  @doc """
  run the scheduled merge tool
  ## Examples

      iex> ScheduledMerge.run()
      {:ok, "ok"}

  """
  def run(
        org \\ @org_default,
        repo \\ @repo_default,
        api_url \\ @github_api_url_default,
        api_token \\ @github_token_default,
        date \\ nil
      ) do
    date = date || Date.utc_today()
    error_label = fetch_or_create_error_label(org, repo, api_url, api_token)

    merge_errors =
      org
      |> Github.fetch_pulls(repo, api_url, api_token)
      |> Pull.present_pulls(date)
      |> merge_pulls(error_label, org, repo, api_url, api_token)

    label_errors =
      org
      |> Github.fetch_labels(repo, api_url, api_token)
      |> Label.past_labels(date)
      |> clean_labels(org, repo, api_url, api_token)

    (merge_errors ++ label_errors)
    |> case do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp clean_labels([], _, _, _, _), do: :ok

  defp clean_labels(labels, org, repo, api_url, api_token) do
    labels
    |> Enum.reduce([], fn label, errors ->
      label
      |> Github.delete_label(org, repo, api_url, api_token)
      |> case do
        :ok -> errors
        _ -> [{label["name"], :label_delete_error}] ++ errors
      end
    end)
  end

  defp merge_pulls(pulls, error_label, org, repo, api_url, api_token) do
    pulls
    |> Enum.reduce([], fn pull, errors ->
      pull
      |> Github.merge_pull(org, repo, api_url, api_token)
      |> case do
        :ok ->
          errors

        _ ->
          :ok = Github.label_issue(pull, error_label, org, repo, api_url, api_token)

          :ok =
            Github.comment_issue(
              pull,
              "there was an error merging this with scheduled_merge",
              org,
              repo,
              api_url,
              api_token
            )

          [{pull["number"], :merge_error}] ++ errors
      end
    end)
  end

  defp fetch_or_create_error_label(org, repo, api_url, api_token) do
    error_label_name = Label.error_label_name()

    error_label_name
    |> Github.fetch_label(org, repo, api_url, api_token)
    |> case do
      %{"name" => ^error_label_name} = label -> label
      _ -> :ok = Github.create_label(error_label_name, org, repo, api_url, api_token)
    end
  end
end
