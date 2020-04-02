defmodule ICalendar.Component.Encoder do
  alias ICalendar.Component
  @crlf ICalendar.Config.crlf()

  alias ICalendar.Util
  def encode(component, level \\ :any)
  def encode(component, expected_type) when is_map(component) do
    encode_single(component, expected_type)
  end
  def encode(components, expected_type) do
    # TODO: ordered Task.async_stream
    Util.enum_map_intersperse(components, @crlf, &encode_single(&1, expected_type))
  end

  defp encode_single(component = %module{__type__: type}, expected_type) do
    case type == expected_type or expected_type == :any do
      false -> throw {:error, {:unexpected_component_type, type, component}}
      true ->
        use ICalendar.Util

        # TODO: single pass
        encoded_component =
          component
          |> module.encode()
          |> Util.enum_filter_intersperse(@crlf, &(&1 != [] and &1 != ""))

        str = Component.key_to_str(module)

        ~i"""
        BEGIN:#{str}
        #{encoded_component}
        END:#{str}
        """
    end
  end
end
