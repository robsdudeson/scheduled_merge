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

        _ ->
          Logger.error("Failed to merge pull: '##{pull["number"]}'")
          [{pull["number"], :pull_merge_error}] ++ errors
      end
    end)
  end

  def present_pulls(pulls, date), do: Enum.filter(pulls, &present?(&1, date))

  defp present?(%{"labels" => []}, _date), do: false

  defp present?(%{"labels" => labels}, date),
    do: Enum.any?(labels, fn label -> Label.present_merge_label?(label, date) end)
end
