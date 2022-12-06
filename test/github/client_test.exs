defmodule ScheduledMerge.Github.ClientTest do
  use ExUnit.Case

  import Double, only: [stub: 3]
  import Inject, only: [register: 2]

  alias ScheduledMerge.Github.Client

  @test_repo "ghost/fake"
  @test_api_url "http://fakeapi.local"
  @test_api_token "bogus_token"

  describe "fetch_pulls/0" do
    setup [:pulls_fetch_stub]

    setup do
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

  defp pulls_fetch_stub(context) do
    stub =
      stub(HTTPoison, :get!, fn _url, _headers ->
        case context[:pulls_response] do
          nil ->
            %{status_code: 200, body: pulls_fixture()}

          :error ->
            %{status_code: 404, body: "some error"}
        end
      end)

    register(HTTPoison, stub)

    []
  end

  defp pulls_fixture, do: File.read!("test/support/fixtures/github_get_pulls.json")
end
