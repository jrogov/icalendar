defmodule ICalendar.Property.Param do
  # TODO: validation
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

  # TODO: generate all of this

  @params
  |> Enum.map(fn {name, spec} ->
    def spec(unquote(name)) do
      unquote(Macro.escape(spec))
    end
  end)
  def spec(_), do: %{default: :unknown}


  alias ICalendar.Util.Identifier
  def key_to_str(s) when is_binary(s), do: Identifier.normalize_keystr(s)
  for {key, spec} <- @params do
    def key_to_str(unquote(key)) do
      unquote(Identifier.format_key_to_str(key))
    end
  end
  def key_to_str(key), do: Identifier.format_key_to_str(key)

  def str_to_key(str), do: Identifier.format_str_to_key(str)
end
