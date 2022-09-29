defmodule ScheduledMerge.Github.Label do
  def merge_label(date) do
    date = Date.to_iso8601(date)
    %{"name" => "merge-#{date}", "color" => default_merge_color()}
  end

  def past_labels(labels, date), do: Enum.filter(labels, &past_merge_label?(&1, date))

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
