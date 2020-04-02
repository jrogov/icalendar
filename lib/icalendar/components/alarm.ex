defmodule ICalendar.Alarm.Action do
  defmodule Display do
    defstruct description: ""
  end

  defmodule Audio do
    defstruct attach: ""
  end

  defmodule Email do
    defstruct description: "",
      summary: "",
      attendees: [],
      attach: []
  end
end

defmodule ICalendar.Alarm do
  alias ICalendar.Alarm.Action
  alias ICalendar.Property

  use ICalendar.Component

  defstruct __type__: :alarm,
            action: %Action.Display{description: ""},
            trigger: TODODuration

            # TODO: check
    """
    In an alarm set to trigger on the "START" of an event or to-do,
    the "DTSTART" property MUST be present in the associated event or
    to-do.  In an alarm in a "VEVENT" calendar component set to
    trigger on the "END" of the event, either the "DTEND" property
    MUST be present, or the "DTSTART" and "DURATION" properties MUST
    both be present.  In an alarm in a "VTODO" calendar component set
    to trigger on the "END" of the to-do, either the "DUE" property
    MUST be present, or the "DTSTART" and "DURATION" properties MUST
    both be present.

    The alarm can be defined such that it triggers repeatedly.  A
    definition of an alarm with a repeating trigger MUST include both
    the "DURATION" and "REPEAT" properties.  The "DURATION" property
    specifies the delay period, after which the alarm will repeat.
    The "REPEAT" property specifies the number of additional
    repetitions that the alarm will be triggered.  This repetition
    count is in addition to the initial triggering of the alarm.  Both
    of these properties MUST be present in order to specify a
    repeating alarm.  If one of these two properties is absent, then
    the alarm will not repeat beyond the initial trigger.
    """

  def encode(%__MODULE__{
        action: action,
        trigger: trigger,
  }) do
    [
      Action.encode(action),
      @crlf,
      Property.encode(trigger)
    ]
  end
end
