defmodule ICalendar.Property do
  alias __MODULE__

  @moduledoc """
  Provide structure to define properties of an Event
  """

  defstruct key: nil,
            value: nil,
            params: %{}

  @type key :: atom | unknown_key
  @type unknown_key :: String.t

  @type value :: any

  @type param :: atom | unknown_param
  @type unknown_param :: String.t

  @type params :: %{param => any}

  @type t :: %__MODULE__{key: key, value: value, params: params} |
             {key, value, params}

  defdelegate encode(key, value \\ []), to: Property.Encoder
  # defdelegate decode(key, value \\ []), to: Property.Decoder

  @props %{
    action:           %{default: :text},
    attach:           %{default: :uri}, # uri or binary
    attendee:         %{default: :cal_address},
    calscale:         %{default: :text},
    categories:       %{default: :text, multi: ","},
    class:            %{default: :text},
    comment:          %{default: :text},
    completed:        %{default: :date_time},
    contact:          %{default: :text},
    created:          %{default: :date_time},
    description:      %{default: :text},
    dtend:            %{default: :date_time, allowed: [:date_time, :date]},
    dtstamp:          %{default: :date_time},
    dtstart:          %{default: :date_time, allowed: [:date_time, :date]},
    due:              %{default: :date_time, allowed: [:date_time, :date]},
    duration:         %{default: :duration},
    exdate:           %{default: :date_time, allowed: [:date_time, :date], multi: ","},
    exrule:           %{default: :recur}, # deprecated
    freebusy:         %{default: :period, multi: ","},
    geo:              %{default: :float, structured: ";"},
    last_modified:    %{default: :date_time},
    location:         %{default: :text},
    method:           %{default: :text},
    organizer:        %{default: :cal_address},
    percent_complete: %{default: :integer},
    priority:         %{default: :integer},
    prodid:           %{default: :text},
    rdate:            %{default: :date_time, allowed: [:date_time, :date, :period], multi: ","}, # TODO: detect
    recurrence_id:    %{default: :date_time, allowed: [:date_time, :date]},
    related_to:       %{default: :text},
    repeat:           %{default: :integer},
    request_status:   %{default: :text},
    resources:        %{default: :text, multi: ","},
    rrule:            %{default: :recur},
    sequence:         %{default: :integer},
    status:           %{default: :text},
    summary:          %{default: :text},
    transp:           %{default: :text},
    trigger:          %{default: :duration, allowed: [:duration, :date_time]},
    tzid:             %{default: :text},
    tzname:           %{default: :text},
    tzoffsetfrom:     %{default: :utc_offset},
    tzoffsetto:       %{default: :utc_offset},
    tzurl:            %{default: :uri},
    uid:              %{default: :text},
    url:              %{default: :uri},
    version:          %{default: :text},
  }

  # @spec spec(atom) :: spec
  for {name, spec} <- @props do
    def spec(unquote(name)) do
      unquote(Macro.escape(spec))
    end
  end
  def spec(_), do: %{default: :unknown}

  def key_to_str(s) when is_binary(s), do: normalize_keystr(s)
  for {key, spec} <- @props do
    def key_to_str(unquote(key)) do
      unquote(
        key
        |> Atom.to_string()
        |> String.upcase() # normalize_keystr
        |> String.replace("_", "-")
      )
    end
  end
  def key_to_str(key), do: format_key_to_str(key)

  def str_to_key(str), do: format_str_to_key(str)

  defp format_str_to_key(str) do
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

  defp format_key_to_str(key) do
    key
    |> Atom.to_string()
    |> normalize_keystr
  end

  defp normalize_keystr(keystr) do
    keystr
    |> String.upcase()
    |> String.replace("_", "-")
  end
end
