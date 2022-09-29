defmodule ScheduledMerge.Github.Label do
  @default_merge_color "FFFFFF"

  @default_error_label %{
    "name" => "merge-error",
    "description" => "indicates when scheduled merge does not work",
    "color" => "FF0000"
  }

  def default_merge_color do
    @default_merge_color
  end

  def default_error_label do
    @default_error_label
  end

  def error_label_name do
    @default_error_label["name"]
  end

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
end
