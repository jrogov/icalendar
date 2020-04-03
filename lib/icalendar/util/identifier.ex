defmodule ICalendar.Util.Identifier do
  defmacro gen_common(
    enum,
    opts \\ [],
    enumerator \\ quote do &(&1) end
  ) do
    getter_block =
      case Keyword.get(opts, :getter, nil) do
        nil -> quote do end
        funname when is_atom(funname) ->
          quote do
            for elem <- unquote(enum) do
              {key, value} = (unquote(enumerator)).(elem)
              # funname = unquote(funname)
              quote do
                def spec(unquote(key)) do
                  # unquote(IO.inspect("WHY"))
                  unquote(value)
                end
              end
            end
          end
      end

    getter_block |> Macro.to_string |> IO.puts

    block =
      quote do
        alias ICalendar.Util.Identifier

        def key_to_str(s) when is_binary(s) do
          Identifier.normalize_keystr(s)
        end
        for elem <- unquote(enum) do
          {key, _} = unquote(enumerator).(elem)
          quote do
            def key_to_str(key) do
              IO.inspect("HERE")
              unquote(
                key
                |> Atom.to_string()
                |> String.upcase() # normalize_keystr
                |> String.replace("_", "-")
              )
            end
          end
        end
        def key_to_str(key) do
          IO.inspect("WTF")
          Identifier.format_key_to_str(key)
        end

        def str_to_key(str), do: Identifier.format_str_to_key(str)

        unquote(getter_block)
      end
    block |> Macro.to_string |> IO.puts
    block
  end


  def format_str_to_key(str) do
    try do
      str
      |> String.downcase()
      |> String.replace("-", "_")
      |> String.to_existing_atom()
    catch
      :error, :badarg ->
        normalize_keystr(str)
    end
  end

  def format_key_to_str(key) do
    key
    |> Atom.to_string()
    |> normalize_keystr
  end

  def normalize_keystr(keystr) do
    keystr
    |> String.upcase()
    |> String.replace("_", "-")
  end
end
