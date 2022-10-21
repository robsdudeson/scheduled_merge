defmodule ScheduledMerge.Support.Stubs do
  defmacro __using__(_) do
    quote do
      import Double, only: [stub: 3]
      import Inject, only: [register: 2]
      import ScheduledMerge.Support.Fixtures

      alias ScheduledMerge.Github.Client, as: Github
      alias ScheduledMerge.Github.Label
      alias ScheduledMerge.Github.Pull

      def github_client_stub(context) do
        stub =
          Github
          |> stub(:comment_issue, fn _issue, _message ->
            case context[:comment_issue_result] do
              nil -> :ok
              :error -> {:error, :error_reason}
            end
          end)
          |> stub(:delete_label, fn _label ->
            case context[:delete_label_result] do
              nil -> :ok
              :error -> {:error, {"a-label-name", "there was an error deleting the label"}}
            end
          end)
          |> stub(:fetch_label, fn _label_name ->
            case context[:fetch_label_result] do
              nil -> {:ok, label_fixture("a-label")}
              :error_label -> {:ok, label_fixture("error")}
              :error -> {:error, :error_reason}
            end
          end)
          |> stub(:fetch_labels, fn ->
            case context[:fetch_labels_result] do
              nil -> {:ok, [label_fixture("a-label")]}
              :error_label -> {:ok, label_fixture("error")}
              :error -> {:error, :error_reason}
            end
          end)
          |> stub(:label_issue, fn _issue, _label_name ->
            case context[:label_issue_result] do
              nil -> :ok
              :error -> {:error, :error_reason}
            end
          end)
          |> stub(:merge_pull, fn _pull ->
            case context[:merge_pull_result] do
              nil -> :ok
              :error -> {:error, :error_reason}
            end
          end)

        register(Github, stub)

        []
      end

      defp label_stub(context) do
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

      defp pull_stub(context) do
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
  end
end
