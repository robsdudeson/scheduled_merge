defmodule ScheduledMerge.Github.Pull do
  @moduledoc """
  Functions to mange pulls from GitHub
  """

  require Logger

  import Inject, only: [i: 1]

  alias ScheduledMerge.Github.Client, as: Github
  alias ScheduledMerge.Github.Label

  def merge_todays_pulls(date),
    do:
      i(GitHub).fetch_pulls()
      |> present_pulls(date)
      |> merge_pulls()

  def merge_pulls(pulls) do
    pulls
    |> Enum.reduce([], fn pull, errors ->
      pull
      |> i(Github).merge_pull()
      |> case do
        :ok ->
          errors

        {:error, reason} ->
          message = "Failed to merge pull: '##{pull["number"]}' - #{reason}"
          Logger.error(message)
          comment_error(pull, message)
          label_error(pull)
          [{pull["number"], :pull_merge_error}] ++ errors
      end
    end)
  end

  def present_pulls(pulls, date), do: Enum.filter(pulls, &present?(&1, date))

  defp comment_error(pull, message) do
    pull
    |> i(Github).comment_issue(message)
    |> case do
      :ok ->
        :ok

      {:error, _reason} ->
        Logger.error("Failed to add error comment to pull '##{pull["number"]}'")
    end
  end

  defp label_error(pull) do
    pull
    |> i(Github).label_issue(i(Label).error_label()["name"])
    |> case do
      :ok ->
        :ok

      {:error, _reason} ->
        Logger.error("Failed to add error label to pull '##{pull["number"]}'")
    end
  end

  defp present?(%{"labels" => []}, _date), do: false

  defp present?(%{"labels" => labels}, date),
    do: Enum.any?(labels, fn label -> Label.present_merge_label?(label, date) end)
end
