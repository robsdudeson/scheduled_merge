defmodule ScheduledMergeTest do
  use ExUnit.Case
  use ScheduledMerge.Support.Stubs

  doctest ScheduledMerge

  setup [:label_stub, :pull_stub]

  describe "run/1" do
    test "it cleans old labels" do
      assert ScheduledMerge.run() == :ok
      assert_received {ScheduledMerge.Github.Label, :delete_past_labels, _}
    end

    test "it merges todays pulls" do
      assert ScheduledMerge.run() == :ok
      assert_received {ScheduledMerge.Github.Pull, :merge_todays_pulls, _}
    end

    @tag delete_past_labels_result: :error
    test "if there are errors deleting labels, return them" do
      assert ScheduledMerge.run() == {:error, [{"a-label-name", :label_delete_error}]}
      assert_received {ScheduledMerge.Github.Label, :delete_past_labels, _}
    end

    @tag merge_todays_pulls_result: :error
    test "if there are errors merging pulles, return them" do
      assert ScheduledMerge.run() == {:error, [{999, :pull_merge_error}]}
      assert_received {ScheduledMerge.Github.Pull, :merge_todays_pulls, _}
    end
  end
end
