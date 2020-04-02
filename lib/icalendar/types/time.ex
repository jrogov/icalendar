defmodule ICalendar.Time do
  @moduledoc """
  Represents an iCalendar time.
  """
  @type t :: %__MODULE__{
    hour: Calendar.hour,
    minute: Calendar.minute,
    second: Calendar.second,
    time_zone: Calendar.time_zone()
  }

  defstruct [:hour, :minute, :second, :time_zone]

  def new(hour, minute, second, time_zone \\ nil) do
    {:ok, %__MODULE__{hour: hour, minute: minute, second: second, time_zone: time_zone}}
  end

  def from_time(%Elixir.Time{hour: hour, minute: minute, second: second}) do
    __MODULE__.new(hour, minute, second)
  end

  def to_time(%__MODULE__{hour: hour, minute: minute, second: second, time_zone: nil}) do
    Elixir.Time.new(hour, minute, second)
  end

  defimpl ICalendar.Property.Value do
    import ICalendar.Util, only: [zero_pad: 2]
    def encode(%{time_zone: "Etc/UTC"} = val, _opts) do
      zero_pad(val.hour, 2) <> zero_pad(val.minute, 2) <> zero_pad(val.second, 2) <> "Z"
    end

    def encode(%{time_zone: time_zone} = val, _opts) when not is_nil(time_zone) do
      {
        zero_pad(val.hour, 2) <> zero_pad(val.minute, 2) <> zero_pad(val.second, 2),
        %{tzid: time_zone}
      }
    end

    def encode(val, _opts) do
      zero_pad(val.hour, 2) <> zero_pad(val.minute, 2) <> zero_pad(val.second, 2)
    end
  end

end
