defmodule ICalendar.Binary do
  defstruct [:val]

  defimpl ICalendar.Property.Value do
    def encode(val, _opts) do
      Binary.encode64(val.val)
    end
  end
end
