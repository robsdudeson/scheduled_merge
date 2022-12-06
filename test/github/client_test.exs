defmodule ScheduledMerge.Github.ClientTest do
  use ExUnit.Case

  import Double, only: [stub: 3]
  import Inject, only: [register: 2]
  import ScheduledMerge.Support.Fixtures, only: [pull_fixture: 0]

  alias ScheduledMerge.Github.Client

  @test_repo "ghost/fake"
  @test_api_url "http://fakeapi.local"
  @test_api_token "bogus_token"

  @success 200
  @created 201
  @forbidden {403, :forbidden}
  @not_found {404, :not_found}
  @method_not_allowed {405, :method_not_allowed}
  @sha_head_mismatch {409, :sha_head_mismatch}
  @gone {410, :gone}
  @request_invalid {422, :request_invalid}
  @server_error {500, :server_error}

  setup [:mock_config]

  setup do
    [pull: pull_fixture()]
  end

  describe "fetch_pulls/0" do
    setup [:pulls_fetch_stub]

    test "it calls the API with the expected params" do
      Client.fetch_pulls()

      assert_received {HTTPoison, :get!, [actual_url, actual_headers]}

      assert actual_url == "#{@test_api_url}/repos/#{@test_repo}/pulls"

      assert actual_headers == [
               {"accept", "application/vnd.github+json"},
               {"authorization", "Bearer #{@test_api_token}"}
             ]
    end

    test "it lists Pull Requests in a repo" do
      assert [%{"id" => 1}] = Client.fetch_pulls()
    end

    @tag pulls_response: :error
    test "it blows up on errors" do
      assert_raise CaseClauseError, fn -> Client.fetch_pulls() end
    end
  end

  describe "merge_pulls/1" do
    setup [:pulls_merge_stub]

    test "it calls the API with the proper params", %{pull: %{"number" => pull_number} = pull} do
      Client.merge_pull(pull)

      assert_received {HTTPoison, :put!, [actual_url, actual_payload, actual_headers]}

      assert actual_url == "#{@test_api_url}/repos/#{@test_repo}/pulls/#{pull_number}/merge"
      assert actual_payload == ""

      assert actual_headers == [
               {"accept", "application/vnd.github+json"},
               {"authorization", "Bearer #{@test_api_token}"}
             ]
    end

    test "it deals with http-200s", %{pull: pull} do
      assert :ok = Client.merge_pull(pull)
    end

    for {status_code, error_atom} <- [
          @forbidden,
          @not_found,
          @method_not_allowed,
          @sha_head_mismatch,
          @request_invalid
        ] do
      @tag pulls_merge_response: {:error, status_code}
      @tag error_atom: error_atom
      test "it deals with known errors gracefully: #{status_code} #{error_atom}", %{
        pull: pull,
        error_atom: error_atom
      } do
        assert {:error, error_atom} == Client.merge_pull(pull)
      end
    end

    @tag pulls_merge_response: :error
    test "it blows up for unknown errors", %{pull: pull} do
      assert_raise CaseClauseError, fn -> Client.merge_pull(pull) end
    end
  end

  describe "comment_issue" do
    setup [:comment_issue_stub]

    @comment_message "some comment"

    test "it calls the API with the proper parameters", %{pull: %{"number" => pull_number} = pull} do
      Client.comment_issue(pull, @comment_message)

      assert_received {HTTPoison, :post!, [actual_url, actual_payload, actual_headers]}

      assert actual_url == "#{@test_api_url}/repos/#{@test_repo}/issues/#{pull_number}/comments"
      assert actual_payload == Jason.encode!(%{body: @comment_message})

      assert actual_headers == [
               {"accept", "application/vnd.github+json"},
               {"authorization", "Bearer #{@test_api_token}"}
             ]
    end

    test "it deals with successfully created comments", %{pull: pull} do
      assert :ok == Client.comment_issue(pull, @comment_message)
    end

    for {status_code, error_atom} <- [
          @forbidden,
          @not_found,
          @gone,
          @request_invalid
        ] do
      @tag comment_issue_response: {:error, status_code}
      @tag error_atom: error_atom
      test "it deals with known errors gracefully: #{status_code} #{error_atom}", %{
        pull: pull,
        error_atom: error_atom
      } do
        assert {:error, error_atom} == Client.comment_issue(pull, @comment_message)
      end
    end

    @tag comment_issue_response: :error
    test "it will blow up for unknown errors", %{pull: pull} do
      assert_raise CaseClauseError, fn -> Client.comment_issue(pull, @comment_message) end
    end
  end

  defp pulls_fetch_stub(context) do
    stub =
      stub(HTTPoison, :get!, fn _url, _headers ->
        case context[:pulls_response] do
          nil ->
            %{status_code: @success, body: pulls_fixture()}

          :error ->
            %{status_code: @server_error, body: "some error"}
        end
      end)

    register(HTTPoison, stub)

    []
  end

  defp pulls_fixture, do: File.read!("test/support/fixtures/github_get_pulls.json")

  defp pulls_merge_stub(context) do
    stub =
      stub(HTTPoison, :put!, fn _url, _payload, _headers ->
        case context[:pulls_merge_response] do
          nil ->
            %{status_code: @success, body: "huzah!"}

          {:error, code} ->
            %{status_code: code, body: "some error"}

          :error ->
            %{status_code: @server_error, body: "server error"}
        end
      end)

    register(HTTPoison, stub)

    []
  end

  defp comment_issue_stub(context) do
    stub =
      stub(HTTPoison, :post!, fn _url, _payload, _headers ->
        case context[:comment_issue_response] do
          nil ->
            %{status_code: @created, body: "huzah!"}

          {:error, code} ->
            %{status_code: code, body: "some error"}

          :error ->
            %{status_code: @server_error, body: "server error"}
        end
      end)

    register(HTTPoison, stub)

    []
  end

  defp mock_config(_context) do
    existing_env = Application.get_env(:scheduled_merge, :github)

    new_env =
      existing_env
      |> Enum.into(%{})
      |> Map.merge(%{repo: @test_repo, api_url: @test_api_url, api_token: @test_api_token})
      |> Map.to_list()

    Application.put_env(:scheduled_merge, :github, new_env)

    on_exit(fn -> Application.put_env(:scheduled_merge, :github, existing_env) end)

    []
  end
end
