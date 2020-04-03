defmodule ICalendar.Binary do
  defstruct [:val, :type]

  defimpl ICalendar.Property.Value do
    def encode(val, _opts) do
      {Base.encode64(val.val), %{encoding: "BASE64", fmttype: val.type}}
    end
  end
end
