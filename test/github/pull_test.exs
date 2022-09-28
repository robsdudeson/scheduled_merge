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

  describe "past_pulls/2" do
    test "returns pulls labeled in the past" do
      label = label_fixture("merge-2022-01-01")

      pulls = [pull_fixture([label])]
      date = Date.from_iso8601!("2022-01-02")

      assert Pull.past_pulls(pulls, date) == pulls
    end

    test "does not returns pulls labeled in the future" do
      label = label_fixture("merge-2022-01-02")

      pulls = [pull_fixture([label])]
      date = Date.from_iso8601!("2022-01-01")

      assert Pull.past_pulls(pulls, date) == []
    end

    test "does not returns pulls labeled in the present" do
      label = label_fixture("merge-2022-01-01")

      pulls = [pull_fixture([label])]
      date = Date.from_iso8601!("2022-01-01")

      assert Pull.past_pulls(pulls, date) == []
    end
  end

  describe "past?/2" do
    test "when a pull has a past merge label" do
      pull = %{"labels" => [%{"name" => "merge-2022-01-01"}]}
      date = Date.from_iso8601!("2022-01-02")

      assert Pull.past?(pull, date)
    end

    test "when a pull has a current merge label" do
      pull = %{"labels" => [%{"name" => "merge-2022-01-01"}]}
      date = Date.from_iso8601!("2022-01-01")

      refute Pull.past?(pull, date)
    end

    test "when a pull has a future merge label" do
      pull = %{"labels" => [%{"name" => "merge-2022-01-02"}]}
      date = Date.from_iso8601!("2022-01-01")

      refute Pull.past?(pull, date)
    end
  end
end
