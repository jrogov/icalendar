ExUnit.start()

defmodule ICalendarTest.Helpers do
  use ExUnit.Case

  def newline_to_crlf(binary, opts \\ []) do
    replaced = String.replace(binary, "\n", ICalendar.Config.crlf())
    case Keyword.get(opts, :trim, true) do
      false -> replaced
      true -> replaced |> String.trim_trailing(ICalendar.Config.crlf())
    end
  end

  @crlf ICalendar.Config.crlf
  def assert_lines_fuzzy(result, expected, eol \\ @crlf) do
    bin =
      result
      |> case do
           l when is_list(l) -> IO.chardata_to_string(l)
           b when is_binary(b) -> b
         end
    do_alf(bin, expected, eol)
  end

  defp do_alf("", [], _), do: :ok
  defp do_alf(bin, [], _) do
    flunk "Assertion failed: unexpected binary part:#{inspect bin}"
  end
  defp do_alf(bin, [{:fuzzy, linebin} | rest_expected], eol) do
    lines = String.split(linebin, "\n", trim: true)

    count = length(lines)
    {found_lines, [restbin]} =
      bin
      |> String.split(eol, trim: true, parts: 1 + count)
      |> Enum.split(count)

    assert Enum.sort(found_lines) == Enum.sort(lines)
    do_alf(restbin, rest_expected, eol)
  end
  defp do_alf(bin, [{:ignore, description} | rest_expected], eol) do
    linecount =
      description
      |> String.split("\n", trim: true)
      |> length()

    {found_lines, [restbin]} =
      bin
      |> String.split(eol, trim: true, parts: 1 + linecount)
      |> Enum.split(linecount)

    assert length(found_lines) == linecount,
      alf_message({:ignore, description}, bin, "too little lines to ignore")

    do_alf(restbin, rest_expected, eol)
  end
  defp do_alf(bin, [binexp | rest_expected], eol) when is_binary(binexp) do
    binexp =
      binexp
      |> String.trim_trailing("\n")
      |> String.replace("\n", eol)

    actsz = byte_size(bin)
    expsz = byte_size(binexp)
    assert actsz >= expsz,
      alf_message(binexp, bin, "actual is smaller than expected")

    act_part = :binary.part(bin, 0, expsz)
    assert act_part == binexp,
      alf_message(binexp, bin, "binary prefix does not match")

    act_rest = :binary.part(bin, actsz, -(actsz-expsz))
    do_alf(act_rest, rest_expected, eol)
  end

  defp alf_message(expected, actual, message) do
    """
    Assertion failed: #{message}
    Expected: #{inspect expected}
      Actual: #{inspect actual}
    """
  end

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [assert_lines_fuzzy: 2]
    end
  end
end
