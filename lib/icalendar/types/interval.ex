defmodule ICalendar.Interval do
  @enforce_keys [:from]
  defstruct @enforce_keys ++ [to: nil]

  defmacro is_dtmod(dt) do
    quote do
      unquote(dt) in [DateTime, NaiveDateTime]
    end
  end

  def new(%mod{} = dt) when is_dtmod(mod) do
    %__MODULE__{from: dt}
  end
  def new({%mod{} = dt, shift_opts}) when is_dtmod(mod) and is_list(shift_opts) do
    %__MODULE__{from: dt, to: Timex.shift(dt, shift_opts)}
  end
  def new({%mod1{} = dt1, %mod2{} = dt2}) when is_dtmod(mod1) and is_dtmod(mod2) do
    %__MODULE__{from: dt1, to: dt2}
  end

  def calculate_end(%mod{} = start, end_arg) when is_dtmod(mod) do
    do_calculate_end(start, end_arg)
  end

  def do_calculate_end(start, nil) do
    nil
  end
  def do_calculate_end(start, shift_opts) when is_list(shift_opts) do
    Timex.shift(start, shift_opts)
  end
  def do_calculate_end(_start, %mod{} = dt) when is_dtmod(mod) do
    dt
  end

  def encode(%{from: from, to: to}) do
    to
    |> case do
         nil -> [dtstart: from]
         _ -> [dtstart: from, dtend: to]
       end
     |> ICalendar.Property.Encoder.encode()
  end

  defimpl ICalendar.Property.Value do
    def encode(interval, _opts), do: ICalendar.Interval.encode(interval)
  end
 end
