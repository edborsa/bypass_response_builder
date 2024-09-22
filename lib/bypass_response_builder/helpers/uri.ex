defmodule BypassResponseBuilder.Helpers.URI do
  def maybe_add_query_params(url, query_params) do
    if Kernel.map_size(query_params) > 0 do
      url
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(query_params))
      |> URI.to_string()
    else
      url
    end
  end
end
