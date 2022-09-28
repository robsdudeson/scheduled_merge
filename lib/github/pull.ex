defmodule ScheduledMerge.Github.Pull do
  alias ScheduledMerge.Github.Label

  def past?(%{"labels" => labels}, date) do
    Enum.any?(labels, fn label -> Label.past_merge_label?(label, date) end)
  end

  def past?(_, _), do: false

  def past_pulls(pulls, date) do
    Enum.filter(pulls, &past?(&1, date))
  end

  def present?(%{"labels" => labels}, date) do
    Enum.any?(labels, fn label -> Label.present_merge_label?(label, date) end)
  end

  def present_pulls(pulls, date) do
    Enum.filter(pulls, &present?(&1, date))
  end
end
