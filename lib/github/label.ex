defmodule ScheduledMerge.Github.Label do
  @moduledoc """
  Collection of functions to manage labels in github
  """
  require Logger

  import Inject, only: [i: 1]

  alias ScheduledMerge.Github.Client, as: Github

  def delete_past_labels(date) do
    i(Github).fetch_labels()
    |> past_labels(date)
    |> delete_labels()
  end

  @doc """
  given a list of labels, attempt to delete them
  """
  @spec delete_labels(list(map())) :: [] | list({String.t(), :label_delete_error})
  def delete_labels(labels) do
    labels
    |> Enum.reduce([], fn label, errors ->
      label
      |> i(Github).delete_label()
      |> case do
        :ok ->
          errors

        _ ->
          Logger.error("Failed to delete label: '#{label["name"]}'")
          [{label["name"], :label_delete_error}] ++ errors
      end
    end)
  end

  def merge_label(date) do
    date = Date.to_iso8601(date)
    %{"name" => "merge-#{date}", "color" => default_merge_color()}
  end

  def error_label() do
    default_error_label()[:name]
    |> i(Github).fetch_label()
    |> case do
      {:error, :not_found} ->
        # we're failing on error here since we _need_ the label to exist
        {:ok, error_label} = i(Github).create_label(default_error_label())
        error_label

      {:ok, error_label} ->
        error_label
    end
  end

  # TODO: robsdudeson - fix the interface for labels (update tests)
  def past_labels(labels, date), do: Enum.filter(labels, &past_merge_label?(&1, date))

  def past_merge_label?(%{"name" => "merge-failed"}, _date), do: false

  def past_merge_label?(%{"name" => "merge-" <> iso_date}, date) do
    :lt ==
      iso_date
      |> Date.from_iso8601!()
      |> Date.compare(date)
  end

  def past_merge_label?(_, _), do: false

  def present_merge_label?(%{"name" => "merge-" <> iso_date}, date) do
    :eq ==
      iso_date
      |> Date.from_iso8601!()
      |> Date.compare(date)
  end

  def present_merge_label?(_, _), do: false

  @doc false
  def default_merge_color,
    do: Application.get_env(:scheduled_merge, :labels)[:default_merge_label][:color]

  defp default_error_label,
    do: Application.get_env(:scheduled_merge, :labels)[:default_error_label]
end
