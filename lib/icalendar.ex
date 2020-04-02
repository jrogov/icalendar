defmodule ICalendar do
  @moduledoc """
  API for generating calendars in ICalendar (ICS) format

  Example:

    iex> use ICalendar
    ...> ICalendar.new(
    ...>    name: "My cool name",
    ...>    description: value("My description", param: "Param value")
    ...>    some_recurring_prop: [
    ...>      "Value",
    ...>      value("Value with params", param: "Some param")
    ...>     ])
  """

  @prodid "-//Polyfox//vObject 0.5.0//EN"

  @spec new() :: %{:__type__ => {atom, map}, optional(atom) => {term, map}}
  def new do
    %{
      # defaults
      __type__: :calendar,
      prodid: @prodid,
      version: "2.0",
      calscale: "GREGORIAN"
    }
  end

  @spec new(props :: map) :: map
  def new(props) do
    struct(new(), props)
  end

  defdelegate encode(object), to: ICalendar.Component.Encoder
  # defdelegate decode(string), to: ICalendar.Decoder

  @doc """
  To create a Phoenix/Plug controller and view that output ics format:
  Add to your config.exs:
  ```
  config :phoenix, :format_encoders,
    ics: ICalendar
  ```
  In your controller use:
  `
    calendar = %ICalendar{ events: events }
    render(conn, "index.ics", calendar: calendar)
  `
  The important part here is `.ics`. This triggers the `format_encoder`.

  In your view can put:
  ```
  def render("index.ics", %{calendar: calendar}) do
    calendar
  end
  ```
  """
  defdelegate encode_to_iodata(object, options \\ []),
    to: ICalendar.Encoder,
    as: :encode

  # TODO: add param to support inline-encoding with comma:
  # However, it should be noted that some properties
  # support encoding multiple values in a single property by separating
  # the values with a COMMA character.


  # cal_address and uri should be quoted
  # altrep delegated_from, delegated_to, dir, member, sent-by
  @params %{
    altrep: %{},
    cn: %{},
    cutype: %{
      values: ["INDIVIDUAL", "GROUP", "RESOURCE", "ROOM", "UNKNOWN"],
      allow_x_name: true,
      allow_iana: true},
    delegated_from: %{multi: ",", value: :cal_address},
    delegated_to: %{multi: ",", value: :cal_address},
    dir: %{},
    encoding: %{values: ["8BIT", "BASE64"]},
    fmttype: %{},
    fbtype: %{
      values: ["FREE", "BUSY", "BUSY-UNAVAILABLE", "BUSY-TENTATIVE"],
      allow_x_name: true,
      allow_iana: true
    },
    language: %{},
    member: %{multi: ",", value: :cal_address},
    # TODO These values are actually different per-component
    partstat: %{
      values: ["NEEDS-ACTION", "ACCEPTED", "DECLINED", "TENTATIVE",
               "DELEGATED", "COMPLETED", "IN-PROCESS"],
      allow_x_name: true,
      allow_iana: true
    },
    range: %{values: ["THISANDFUTURE"]},
    related: %{values: ["START", "END"]},
    reltype: %{
      values: ["PARENT", "CHILD", "SIBLING"],
      allow_x_name: true,
      allow_iana_token: true
    },
    role: %{
      values: ["REQ-PARTICIPANT", "CHAIR", "OPT-PARTICIPANT", "NON-PARTICIPANT"],
      allow_x_name: true,
      allow_iana_token: true
    },
    rsvp: %{value: :boolean},
    sent_by: %{value: :cal_address},
    tzid: %{matches: ~r/^\//},
    value: %{
      values: [:binary, :boolean, :cal_address, :date, :date_time,
               :duration, :float, :integer, :period, :recur, :text,
               :time, :uri, :utc_offset],
      allow_x_name: true,
      allow_iana_token: true
    }
  }

  @typep spec :: %{atom => %{}}
  @spec __params__(atom) :: spec

  @params
  |> Enum.map(fn {name, spec} ->
    def __params__(unquote(name)) do
      unquote(Macro.escape(spec))
    end
  end)
  def __params__(_), do: %{default: :unknown}

  defmacro value(val, params) do
    params =
      case params do
        l when is_list(params) -> {:%{}, [], params}
        o -> Map.new(o)
      end

    quote do
      %ICalendar.Value{
        value: unquote(val),
        params: unquote(params)
      }
    end
  end

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__), only: [value: 2]
      alias ICalendar, as: I
    end
  end
end
