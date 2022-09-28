defmodule ScheduledMerge do
  @moduledoc """
  Documentation for `ScheduledMerge`.
  """

  alias ScheduledMerge.Github.Client, as: Github

  alias ScheduledMerge.Github.Pull
  alias ScheduledMerge.Github.Label

  @github_token_default ""
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

    # get all pulls
    pulls = Github.fetch_pulls(org, repo, api_url, api_token)

    # filter pulls to merge
    Pull.present_pulls(pulls, date) |> IO.inspect(label: "todays_pulls")

    # filter past_pulls to clean up
    past_pulls =
      Pull.past_pulls(pulls, date)
      |> IO.inspect(label: "past_pulls")

    # filter list of labels to clean up
    _past_labels =
      past_labels(past_pulls, date)
      |> IO.inspect(label: "past_labels")

    # TODO: attempt to clean up pulls with past label
    # TODO: aggregate results
    # TODO: attempt to merge todays_pulls
    # TODO: aggregate results
    # TODO: return tuple with results
    {:ok, "ok"}
  end

  defp past_labels(pulls, date) do
    pulls
    |> Enum.map(fn %{"labels" => labels} -> labels end)
    |> List.flatten()
    |> Enum.filter(&Label.past_merge_label?(&1, date))
  end
end
