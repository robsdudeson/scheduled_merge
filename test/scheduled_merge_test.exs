defmodule ScheduledMergeTest do
  use ExUnit.Case

  import Double, only: [stub: 3]
  import Inject, only: [register: 2]

  alias ScheduledMerge.Github.Label
  alias ScheduledMerge.Github.Pull

  doctest ScheduledMerge

  setup [:setup_label, :setup_pull]

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

  defp setup_label(context) do
    stub =
      stub(Label, :delete_past_labels, fn _date ->
        case context[:delete_past_labels_result] do
          :error -> [{"a-label-name", :label_delete_error}]
          nil -> []
        end
      end)

    register(Label, stub)

    []
  end

  defp setup_pull(context) do
    stub =
      stub(Pull, :merge_todays_pulls, fn _date ->
        case context[:merge_todays_pulls_result] do
          :error -> [{999, :pull_merge_error}]
          nil -> []
        end
      end)

    register(Pull, stub)

    []
  end
end
