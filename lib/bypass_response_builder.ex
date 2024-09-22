defmodule BypassResponseBuilder do
  alias BypassResponseBuilder.HTTPClient
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduledoc """
  Documentation for `BypassResponseBuilder`.
  """

  @doc """
    client =
      HTTPClient.client(
        "http://vmlinarchuat1.loomissayles.com:4060",
        "/api/user/gsimonds"
      )

  BypassResponseBuilder.create_response_for_get(client, "gsimonds")
  """
  def create_response_for_get(client, mock_file) do
    ExVCR.Config.cassette_library_dir("mock_data")

    use_cassette "#{mock_file}" do
      HTTPClient.get(client)
    end
  end

  @doc """
      path = "mock_data/gsimonds.json"
      BypassResponseBuilder.read_generic_vcr_response(path)
  """
  def read_generic_vcr_response(path) do
    path
    |> File.read!()
    |> Jason.decode!()
  end

  def json_encoded_pretty_body(response) do
    response
    |> elem(1)
    |> Map.get(:body)
    |> jsonfy_pretty_map()
  end

  @doc """
      some_body = %{
        "active" => true
        }
      json_of_some_body = BypassResponseBuilder.jsonfy_pretty_map(some_body)
      vcr_response_path = "test/vcr_cassettes/httpoison/generic_get.json"
      BypassResponseBuilder.update_vcr_body_response(vcr_response_path, json_of_some_body)
  """
  def update_vcr_body_response(vcr_response_path, body) when is_map(body) do
    update_vcr_body_response(vcr_response_path, jsonfy_pretty_map(body))
  end

  def update_vcr_body_response(vcr_response_path, new_json_body) when is_binary(new_json_body) do
    new_file_content =
      vcr_response_path
      |> File.read!()
      |> Jason.decode!()
      |> List.first()
      |> Kernel.put_in(["response", "body"], new_json_body)
      |> then(fn body -> [body] end)
      |> Jason.encode!()
      |> Jason.Formatter.pretty_print()

    {:ok, file} = File.open(vcr_response_path, [:write])
    IO.binwrite(file, new_file_content)
    File.close(file)
  end

  def jsonfy_pretty_map(body) do
    body
    |> Jason.encode!()
    |> Jason.Formatter.pretty_print()
  end

  @doc """
      vcr_response_path = "test/vcr_cassettes/httpoison/success_multiple_get.json"
      BypassResponseBuilder.split_vcr_response_in_multiple(vcr_response_path)
  """
  def split_vcr_response_in_multiple(vcr_response_path) do
    vcr_response_path
    |> File.read!()
    |> Jason.decode!()
    |> Enum.reduce(%{count: 0}, fn request, acc ->
      file_extention = Path.extname(vcr_response_path)
      file_name = Path.basename(vcr_response_path, ".json") <> "_#{acc.count}" <> file_extention
      {:ok, file} = File.open(file_name, [:write])

      content =
        [prettyfy_request(request)]
        |> Jason.encode!()
        |> Jason.Formatter.pretty_print()

      IO.binwrite(file, content)
      File.close(file)
      %{acc | count: acc.count + 1}
    end)
  end

  def prettyfy_request(request) do
    response_body =
      request
      |> Map.get("response")
      |> Map.get("body")
      |> Jason.decode!()
      |> Jason.encode!()
      |> Jason.Formatter.pretty_print()

    put_in(request, ["response", "body"], response_body)
  end

  @doc """
    Returns a body to be used to update a response
  """
  def manipulate_postman_response(postman_response) do
    postman_response
    |> Jason.decode!()
  end
end
