defmodule BypassResponseBuilderTest do
  alias BypassResponseBuilder.HTTPClient
  use ExUnit.Case
  doctest BypassResponseBuilder

  describe "create_response_for" do
    test "SUCCESS" do
      client = HTTPClient.client("http://vmlinarchuat1.loomissayles.com:4060")

      BypassResponseBuilder.create_response_for_get(client, "/api/user", [], [])
      assert true
    end
  end
end
