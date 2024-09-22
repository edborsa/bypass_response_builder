defmodule BypassResponseBuilder.HTTPClientTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias BypassResponseBuilder.HTTPClient

  setup context do
    ExVCR.Config.cassette_library_dir("test/vcr_cassettes")

    client =
      HTTPClient.client(
        "http://vmlinarchuat1.loomissayles.com:4060",
        "/api/user/gsimonds"
      )

    Map.merge(context, %{client: client})
  end

  describe "get/1" do
    test "SUCCESS", %{client: client} do
      use_cassette "httpoison/success_get" do
        assert {:ok, %{body: body}} = HTTPClient.get(client)

        assert %{
                 "active" => true,
                 "email" => "GSimonds@loomissayles.com",
                 "employeeid" => 1422,
                 "first_name" => "Geoff",
                 "groups" => [
                   %{
                     "email" => "AocUsers@loomissayles.com",
                     "name" => "aocusers",
                     "uid" => "AocUsers"
                   }
                   | _
                 ],
                 "last_name" => "Simonds",
                 "location" => "Boston",
                 "username" => "gsimonds"
               } = Jason.decode!(body)
      end
    end
  end

  describe "multiple" do
    setup context do
      ed_client =
        HTTPClient.client(
          "http://vmlinarchuat1.loomissayles.com:4060",
          "/api/user/eborsa"
        )

      Map.merge(context, %{ed_client: ed_client})
    end

    test "foo", %{client: client, ed_client: ed_client} do
      use_cassette "httpoison/success_multiple_get" do
        assert {:ok, %{body: body}} = HTTPClient.get(client)
        assert {:ok, %{body: body}} = HTTPClient.get(ed_client)
      end
    end
  end
end
