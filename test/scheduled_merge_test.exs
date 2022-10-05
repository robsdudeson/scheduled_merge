defmodule ScheduledMergeTest do
  use ExUnit.Case

  import Double, only: [stub: 3]
  import Inject, only: [register: 2]

  alias ScheduledMerge.Github.Label

  doctest ScheduledMerge

  setup [:setup_label]

  describe "run/1" do
    test "it cleans old labels" do
      assert ScheduledMerge.run() == :ok
      assert_received {ScheduledMerge.Github.Label, :delete_past_labels, _}
    end

    @tag delete_past_labels_result: :error
    test "if there are errors deleting labels, return them" do
      assert ScheduledMerge.run() == {:error, [{"a-label-name", :label_delete_error}]}
      assert_received {ScheduledMerge.Github.Label, :delete_past_labels, _}
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
end
