defmodule ICalendar.Alarm.Action do
  alias ICalendar.Property
  alias __MODULE__

  @crlf ICalendar.Config.crlf()

  @action_mapping [
    {Action.Display, "DISPLAY"},
    {Action.Audio, "AUDIO"},
    {Action.Email, "EMAIL"}
  ]

  for {key, str} <- @action_mapping do
    def key_to_str(unquote(key)), do: unquote(str)
  end

  # for {key, str} <- @action_mapping do
  #   def str_to_key(unquote(str)), do: unquote(key)
  # end

  def encode(%mod{} = action) do
    [action
    |> Map.drop([:__struct__])
    |> Map.put(:action, key_to_str(mod))
    |> Property.encode()]
  end

  defmodule Display do
    defstruct __type__: :action,
              description: ""

    # def encode(%__MODULE__{description: desc}) do
    #   [Property.encode(description: desc)]
    # end
  end

  defmodule Audio do
    defstruct __type__: :action,
              attach: ""

    # def encode(%__MODULE__{attach: attach}) do
    #   [Property.encode(attach: attach)]
    # end
  end

  defmodule Email do
    defstruct __type__: :action,
              description: "",
              summary: "",
              attendees: [],
              attach: []
  end
end

defmodule ICalendar.Alarm do
  alias __MODULE__
  alias ICalendar.Alarm.Action
  alias ICalendar.Property

  use ICalendar.Component


  @enforce_keys [:action, :trigger]
  defstruct [__type__: :alarm, props: []] ++ @enforce_keys

  def new(opts) do
    {struct_opts, props} = Keyword.split(opts, [:action, :trigger])

    action =
      opts
      |> Keyword.fetch!(:action)
      |> case do
           str when is_binary(str) or is_list(str) ->
             %Action.Display{description: str}
           %_{} = action -> action
         end
    trigger = Keyword.fetch!(opts, :trigger)

    %Alarm{action: action, trigger: trigger, props: props}
  end

  def encode(%__MODULE__{
        action: action,
        trigger: trigger,
        props: props
  }) do
    [
      Action.encode(action),
      Property.encode([{:trigger, trigger} | props])
    ]
  end


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
end
