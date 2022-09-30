defmodule ScheduledMerge.Support.Fixtures do
  @moduledoc """
  collection of data fixtures for tests
  """
  alias ScheduledMerge.Github.Label

  def label_fixture(name) do
    %{"name" => name, "color" => Label.default_merge_color()}
  end

  def pull_fixture(labels \\ []) do
    %{"labels" => labels}
  end
end
