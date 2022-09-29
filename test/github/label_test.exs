defmodule ScheduledMerge.Github.LabelTest do
  use ExUnit.Case

  import ScheduledMerge.Support.Fixtures

  alias ScheduledMerge.Github.Label

  describe "merge_label/1" do
    test "produces a valid label name" do
      date = Date.from_iso8601!("2022-01-01")

      assert Label.merge_label(date) == %{
               "name" => "merge-2022-01-01",
               "color" => Label.default_merge_color()
             }
    end
  end

  describe "past_merge_label?/2" do
    test "when a label represents a past date" do
      label = label_fixture("merge-2022-01-01")
      date = Date.from_iso8601!("2022-01-02")
      assert Label.past_merge_label?(label, date)
    end

    test "when a label represents the same date" do
      label = label_fixture("merge-2022-01-01")
      date = Date.from_iso8601!("2022-01-01")
      refute Label.past_merge_label?(label, date)
    end

    test "when a label represents a future same date" do
      label = label_fixture("merge-2022-01-02")
      date = Date.from_iso8601!("2022-01-01")
      refute Label.past_merge_label?(label, date)
    end

    test "when a label is not a merge label" do
      label = label_fixture("not a merge")
      date = Date.from_iso8601!("2022-01-01")
      refute Label.past_merge_label?(label, date)
    end

    test "when a label is merge but not a valid iso8601 date" do
      label = label_fixture("merge-bad-iso")
      date = Date.from_iso8601!("2022-01-01")

      assert_raise ArgumentError,
                   "cannot parse \"bad-iso\" as date, reason: :invalid_format",
                   fn ->
                     Label.past_merge_label?(label, date)
                   end
    end
  end

  describe "present_merge_label?/2" do
    test "when a label represents a past date" do
      label = label_fixture("merge-2022-01-01")
      date = Date.from_iso8601!("2022-01-02")

      refute Label.present_merge_label?(label, date)
    end

    test "when a label represents the same date" do
      label = label_fixture("merge-2022-01-01")
      date = Date.from_iso8601!("2022-01-01")

      assert Label.present_merge_label?(label, date)
    end

    test "when a label represents a future same date" do
      label = label_fixture("merge-2022-01-02")
      date = Date.from_iso8601!("2022-01-01")

      refute Label.present_merge_label?(label, date)
    end

    test "when a label is not a merge label" do
      label = label_fixture("not a merge")
      date = Date.from_iso8601!("2022-01-01")

      refute Label.present_merge_label?(label, date)
    end

    test "when a label is merge but not a valid iso8601 date" do
      label = label_fixture("merge-bad-iso")
      date = Date.from_iso8601!("2022-01-01")

      assert_raise ArgumentError,
                   "cannot parse \"bad-iso\" as date, reason: :invalid_format",
                   fn ->
                     Label.past_merge_label?(label, date)
                   end
    end
  end
end
