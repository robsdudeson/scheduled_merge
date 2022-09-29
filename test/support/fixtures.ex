defmodule ScheduledMerge.Support.Fixtures do
  alias ScheduledMerge.Github.Label

  def label_fixture(name) do
    %{"name" => name, "color" => Label.default_merge_color()}
  end
end
