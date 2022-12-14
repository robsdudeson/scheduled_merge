defmodule ScheduledMerge.Github.PullTest do
  use ExUnit.Case
  use ScheduledMerge.Support.Stubs

  import ExUnit.CaptureLog, only: [capture_log: 1]
  import ScheduledMerge.Support.Fixtures

  alias ScheduledMerge.Github.Pull

  describe "merge_pulls/1" do
    setup [:github_client_stub]

    test "it will merge a pull" do
      pulls = [pull] = [pull_fixture()]

      assert Pull.merge_pulls(pulls) == []
      assert_received {ScheduledMerge.Github.Client, :merge_pull, [^pull]}
    end

    @tag merge_pull_result: :error
    test "it aggregates any errors" do
      pulls = [pull] = [pull_fixture()]
      expected_error_message = "Failed to merge pull: '##{pull["number"]}' - error_reason"

      assert capture_log(fn ->
               assert Pull.merge_pulls(pulls) == [{pull["number"], :pull_merge_error}]
             end) =~ expected_error_message

      assert_received {ScheduledMerge.Github.Client, :merge_pull, [^pull]}

      assert_received {ScheduledMerge.Github.Client, :fetch_label, ["merge-failed"]}

      assert_received {ScheduledMerge.Github.Client, :comment_issue,
                       [^pull, ^expected_error_message]}

      assert_received {ScheduledMerge.Github.Client, :label_issue, [^pull, "a-label"]}
    end

    @tag merge_pull_result: :error
    @tag comment_issue_result: :error
    test "it logs errors adding commenting errors" do
      pulls = [pull] = [pull_fixture()]

      assert capture_log(fn ->
               assert Pull.merge_pulls(pulls) == [{pull["number"], :pull_merge_error}]
             end) =~ "Failed to add error comment to pull '##{pull["number"]}'"
    end

    @tag merge_pull_result: :error
    @tag label_issue_result: :error
    test "it deals with labeling errors" do
      pulls = [pull] = [pull_fixture()]

      assert capture_log(fn ->
               assert Pull.merge_pulls(pulls) == [{pull["number"], :pull_merge_error}]
             end) =~ "Failed to add error label to pull '##{pull["number"]}'"
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
end
