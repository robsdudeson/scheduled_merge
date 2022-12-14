defmodule ScheduledMerge do
  @moduledoc """
  Documentation for `ScheduledMerge`.
  """
  import Inject, only: [i: 1]

  alias ScheduledMerge.Github.Label
  alias ScheduledMerge.Github.Pull

  @doc """
  run the scheduled merge tool

  opts
    - date: a date used as the 'present' date.  Defaults to `Date.utc_today()`
  """
  def run(opts \\ []) do
    date = date_from_opts(opts)

    label_errors = i(Label).delete_past_labels(date)
    merge_errors = i(Pull).merge_todays_pulls(date)

    (label_errors ++ merge_errors)
    |> case do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp date_from_opts(opts) do
    opts
    |> List.keyfind(:date, 0, nil)
    |> case do
      nil -> Date.utc_today()
      string -> Date.from_iso8601!(string)
    end
  end
end
