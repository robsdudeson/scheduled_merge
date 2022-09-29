defmodule ScheduledMerge.Github.PullTest do
  use ExUnit.Case

  import ScheduledMerge.Support.Fixtures

  alias ScheduledMerge.Github.Pull

  # doctest Pull

  describe "present_pulls/2" do
    test "returns pulls labeled in the past" do
      label = label_fixture("merge-2022-01-01")

      pulls = [pull_fixture([label])]
      date = Date.from_iso8601!("2022-01-02")

      assert Pull.present_pulls(pulls, date) == []
    end

    test "does not returns pulls labeled in the future" do
      label = label_fixture("merge-2022-01-02")

      pulls = [pull_fixture([label])]
      date = Date.from_iso8601!("2022-01-01")

      assert Pull.present_pulls(pulls, date) == []
    end

    test "does not returns pulls labeled in the present" do
      label = label_fixture("merge-2022-01-01")

      pulls = [pull_fixture([label])]
      date = Date.from_iso8601!("2022-01-01")

      assert Pull.present_pulls(pulls, date) == pulls
    end
  end
end
