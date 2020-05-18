defmodule ICalendar.Util do
  def zero_pad(val, count) when val >= 0 do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

  @doc """
  Creates ~i to create IO lists that look like standard interpolation

  Source: https://blog.smartlogic.io/elixir-performance-using-io-data-lists/
  """
  defmacro sigil_i({:<<>>, _, text}, delimeter) do
    delimeter =
      delimeter
      |> case do
           '' -> ICalendar.Config.crlf
           'escape' ++ _chars ->
             # TODO: Is this sensible code?
             Enum.flat_map(delimeter, &[?\\, &1])
           chars -> chars
         end
      |> IO.chardata_to_string()

    text
    |> Enum.reduce([], fn
         {:"::", _, [{_, _, [text]} | _] = _interpolation}, acc -> [text | acc]
         text, acc when is_binary(text) ->
           new_text =
             text
             |> :elixir_interpolation.unescape_chars()
             |> String.replace("\n", delimeter)
           [new_text | acc]
       end)
    |> case do # Trim unnecessary trailing delimeter
         [totrim | rest] when byte_size(totrim) >= byte_size(delimeter) ->
           txtsz = byte_size(totrim)
           delsz = byte_size(delimeter)
           [:binary.part(totrim, txtsz, txtsz-delsz) | rest]
         keep -> keep
       end
    |> Enum.reverse()
  end

  def enum_map_intersperse(enum, sep, fun, opts \\ []) when is_function(fun, 1) do
    enum
    |> Enum.reduce(init_acc(sep, opts), &[sep, fun.(&1) | &2])
    |> finish_acc(opts)
  end

  def enum_filter_intersperse(enum, sep, fun, opts \\ [])
  when is_function(fun, 1) do
    enum
    |> Enum.reduce(init_acc(sep, opts),
    &(if fun.(&1) do [sep, &1 | &2] else &2 end))
    |> finish_acc(opts)
  end

  def enum_map_filter_intersperse(enum, sep, fun, opts \\ [])
  when is_function(fun, 1) do
    enum
    |> Enum.reduce(init_acc(sep, opts), fn elem, acc ->
      case fun.(elem) do
        {true, value} -> [sep, value | acc]
        false -> acc
      end
    end)
    |> finish_acc(opts)
  end

  def enum_map_reduce_intersperse(enum, acc, sep, fun, opts \\ [])
  when is_function(fun, 2) do
    {intacc, acc} = Enum.reduce(enum, {init_acc(sep, opts), acc},
      fn elem, {list_acc, acc} ->
        {new_elem, new_acc} = fun.(elem, acc)
        {[sep, new_elem | list_acc], new_acc}
      end)

    {finish_acc(intacc, opts), acc}
  end

  defp init_acc(sep, opts) do
    case Keyword.get(opts, :prepend, false) do
      true -> [sep]
      false -> []
    end
  end

  def finish_acc([], _opts), do: []
  def finish_acc(acc, opts) do
    case Keyword.get(opts, :append, false) do
      true -> acc
      false -> tl(acc)
    end
    |> Enum.reverse()
  end

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [sigil_i: 2]
      alias unquote(__MODULE__)
    end
  end
end
