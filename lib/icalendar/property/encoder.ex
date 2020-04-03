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
      {_, vals, %{multi: delim}} when is_list(vals) ->
        {true, encode_multival_prop(key, value, params, delim)}
      {_, val, _} ->
        {true, encode_simple_prop(key, value, params)}
      # {vals, _} when is_list(vals) ->
      #   vals
      #   |> Enum.map(&encode_single_prop(key, &1, params))
      #   |> TODO THEN WHAT?
    end
  end

  # HAXX: we skip the per line encode here, but this isn't too elegant
  defp encode_multival_prop(key, vals, params, delim) do
    {encoded_vals, params} =
      vals
      # TODO: escape delims in text
      |> Util.enum_map_reduce_intersperse(params, delim,
           fn val, params_acc ->
             case Property.Value.encode(val) do
               {val, extra_params} ->
                 {val, Map.merge(params_acc, extra_params)}
               val ->
                 {val, params_acc}
             end
           end)

    [Property.key_to_str(key), encode_params(params), ":", encoded_vals]
  end

  defp encode_simple_prop(key, val, params) do
    # take any extra params the field encoding might have given
    {encoded_val, params} =
      case Property.Value.encode(val) do
        {val, extra_params} ->
          {val, Map.merge(params, extra_params)}
        val ->
          {val, params}
      end

    [Property.key_to_str(key), encode_params(params), ":", encoded_val]
  end


  @spec encode_params(params :: map) :: iodata
  defp encode_params(m) when map_size(m) == 0, do: []
  defp encode_params(params) do
    Util.enum_map_filter_intersperse(params, ";", fn
      {key, nil} -> false
      {key, val} ->
        {true, [Property.Param.key_to_str(key), "=", Util.RFC6868.escape(val)]}
      end,
      prepend: true)
  end

  @typep spec :: %{optional(atom) => any}


  # def encode(props, opts \\ [])
  # def encode(props, opts) when is_map(props), do: encode([props], opts)
  # def encode(props, opts), do: do_encode_props(props, [], opts)

  # # when map_size(props) == 1, do: [] # for #{__type__: _}
  # defp do_encode_props(iter, acc, opts) do
  #   case :maps.next(iter) do
  #     :none ->
  #       case acc do
  #         [] -> []
  #         acc -> tl(acc)
  #       end
  #     {:__type__, _, next_iter} -> do_encode_props(next_iter, acc, opts)
  #     {key, value, next_iter} ->
  #       # TODO: check correctness of list-in-list
  #       encoded_prop =
  #         case is_list(value) do
  #           true -> Enum.map(value, &encode_prop(key, &1, opts))
  #           false -> encode_prop(key, value, opts)
  #         end
  #       do_encode_props(next_iter, [@crlf, encoded_prop | acc], opts)
  #   end
  # end

  # defp encode_prop(key, value, opts) do
  #   spec = prop_spec(key)
  #   {value, params} =
  #     case value do
  #       %Property.Value{value: value, params: params} -> {value, params}
  #       value -> {value, %{}}
  #     end

  #   case {value, spec} do
  #     {vals, %{multi: delim}} when is_list(vals) ->
  #       encode_multival_prop(key, value, params, delim)
  #     {vals, _} when is_list(vals) ->
  #       vals
  #       |> Enum.map(&encode_single_prop(key, &1, params))
  #       # |> TODO THEN WHAT?
  #   end
  # end
end
