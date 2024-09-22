defmodule BypassResponseBuilder.HTTPClient do
  defstruct url: "", path: "", headers: [], options: [], params: %{}

  @type t() :: %__MODULE__{
          url: String.t(),
          path: String.t(),
          headers: keyword(),
          options: keyword(),
          params: map()
        }

  alias BypassResponseBuilder.Helpers

  def get(client) do
    final_url = Helpers.URI.maybe_add_query_params(client.url <> client.path, client.params)
    HTTPoison.get(final_url, client.headers, client.options)
  end

  def client(url, path \\ "", headers \\ [], options \\ [], params \\ %{}) do
    %__MODULE__{
      url: url,
      path: path,
      headers: headers,
      options: options,
      params: params
    }
  end
end
