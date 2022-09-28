defmodule ScheduledMergeTest do
  use ExUnit.Case
  doctest ScheduledMerge

  test "run the tool" do
    assert ScheduledMerge.run() == :ok
  end
end
