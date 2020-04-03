defmodule ICalendar.Component do
  alias ICalendar.Component, as: C

  @type one_or_many(t) :: t | [t]
  # @type juncture :: dtstart
  #                 | {dtstart, dtend}
  #                 | {dtstart, timex_shift_options}

  # def encode_juncture() do
  # end

  @callback encode(self :: term) :: iodata
  @callback decode(props :: list) :: term

  defmacro __using__(_) do
    quote do
      # @crlf ICalendar.Config.crlf()
      @behaviour unquote(__MODULE__)
      alias unquote(__MODULE__)
    end
  end

  defdelegate encode(component, level \\ :any), to: C.Encoder
  # defdelegate decode(component, level \\ :any), to: C.Decoder


  alias ICalendar, as: I
  @component_mapping [
    {I.Calendar, "VCALENDAR"},
    {I.Event,    "VEVENT"},
    {I.Alarm,    "VALARM"},
    {I.Todo,     "VTODO"},
    {I.Journal,  "VJOURNAL"},
    {I.Freebusy, "VFREEBUSY"},
    {I.Timezone, "VTIMEZONE"},
    {I.Standard, "STANDARD"},
    {I.Daylight, "DAYLIGHT"}
  ]

  Enum.map(
    @component_mapping,
    fn {atom, str} -> def key_to_str(unquote(atom)), do: unquote(str) end)

  # def str_to_key(str), do: str |> String.lower() |> do_str_to_key()
  # Enum.map(
  #   @component_mapping,
  #   fn {atom, str} -> def do_str_to_key(str), do: atom end)
  # def do_str_to_key(other), do: throw({:error, {:unknown_component, other}})
end
