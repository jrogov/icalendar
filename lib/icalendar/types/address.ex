defmodule ICalendar.Address do
  defstruct [:val]

  defimpl ICalendar.Property.Value do
    def encode(val, opts) do
      val.val
    end
  end
end
