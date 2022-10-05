defmodule ScheduledMerge.Github.PullTest do
  use ExUnit.Case

  import ExUnit.CaptureLog, only: [capture_log: 1]
  import Double, only: [stub: 3]
  import Inject, only: [register: 2]
  import ScheduledMerge.Support.Fixtures

  alias ScheduledMerge.Github.Client, as: Github
  alias ScheduledMerge.Github.Pull

  describe "merge_pulls/1" do
    setup [:setup_github_client]

    test "it will merge a pull" do
      pulls = [pull] = [pull_fixture()]

      assert Pull.merge_pulls(pulls) == []
      assert_received {ScheduledMerge.Github.Client, :merge_pull, [^pull]}
    end

    @tag merge_pull_result: :error
    test "it aggregates any errors" do
      pulls = [pull] = [pull_fixture()]

      assert capture_log(fn ->
               assert Pull.merge_pulls(pulls) == [{pull["number"], :pull_merge_error}]
             end) =~ "Failed to merge pull: '##{pull["number"]}'"

      assert_received {ScheduledMerge.Github.Client, :merge_pull, [^pull]}
    end
  end

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

  defp setup_github_client(context) do
    stub =
      stub(Github, :merge_pull, fn _pull ->
        case context[:merge_pull_result] do
          nil -> :ok
          :error -> {:error, {"a-pull-number", "there was an error merging the pull"}}
        end
      end)

    register(Github, stub)

    []
  end
end
