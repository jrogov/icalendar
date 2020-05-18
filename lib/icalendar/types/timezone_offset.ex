defmodule ICalendar.UTCOffset do
  defstruct [:val]

  defimpl ICalendar.Property.Value do
    def encode(val, _opts) do
      val.val
    end
  end
end
