defmodule ICalendar.Property.Encoder do
  alias ICalendar.Property
  alias ICalendar.Util

  @crlf ICalendar.Config.crlf()

  def encode(props, opts \\ []) do
    props
    |> Enumerable.impl_for()
    |> case do
         nil -> [props]
         _ -> props
       end
    |> Util.enum_map_filter_intersperse(@crlf, &encode_prop/1, opts)
  end

  defp encode_prop({key, value}) do
    spec = Property.spec(key)
    {value, params} =
      case value do
        %Property.Value{value: value, params: params} -> {value, params}
        value -> {value, %{}}
      end

    case {key, value, spec} do
      {util_key, _, _} when util_key in [:__struct__, :__type__] ->
        false
      {_, nil, _} ->
        false
      {key, vals, %{multi: delim}} when is_list(vals) ->
        {true, encode_multival_prop(key, vals, params, delim)}
      {key, val, _} ->
        {true, encode_simple_prop(key, val, params)}
      # {vals, _} when is_list(vals) ->
      #   vals
      #   |> Enum.map(&encode_single_prop(key, &1, params))
      #   |> TODO THEN WHAT?
    end
  end

  # HAXX: we skip the per line encode here, but this isn't too elegant
  defp encode_multival_prop(key, vals, params, delim) do
    keystr = Property.key_to_str(key)
    enc_params = encode_params(params)

    {encoded_vals, _params} =
      vals
      # TODO: escape delims in text
      |> Util.enum_map_reduce_intersperse(params, delim,
           fn val, params_acc ->
             case Property.Value.encode(val, params) do
               {val, extra_params} ->
                 {val, Map.merge(params_acc, extra_params)}
               val ->
                 {val, params_acc}
             end
           end)

    # Here we skip params encoding
    # TODO: remember why
    [keystr, enc_params, ":", encoded_vals]
    |> wrap_content_line()
  end

  defp encode_simple_prop(key, val, params) do
    # take any extra params the field encoding might have given
    {encoded_val, params} =
      case Property.Value.encode(val, params) do
        {val, extra_params} ->
          {val, Map.merge(params, extra_params)}
        val ->
          {val, params}
      end

    [Property.key_to_str(key), encode_params(params), ":", encoded_val]
    |> wrap_content_line()
  end


  @spec encode_params(params :: map) :: iodata
  defp encode_params(m) when map_size(m) == 0, do: []
  defp encode_params(params) do
    Util.enum_map_filter_intersperse(params, ";", fn
      {_key, nil} -> false
      {key, val} ->
        {true, [Property.Param.key_to_str(key), "=", Util.RFC6868.escape(val)]}
      end,
      prepend: true)
  end

  # TODO: see 3.1
  defp wrap_content_line(line), do: line
  # defp wrap_content_line(line) do
  #   len = IO.iodata_length(line)
  #   case len > 75 do
  #     true => do_wrap_content_line(line, 0, len)
  #     false => line
  #   end
  # end
  # defp do_wrap_content_line(line, count, len) do

  # end
end
