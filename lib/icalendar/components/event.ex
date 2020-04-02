defmodule ICalendar.Event do
  use ICalendar.Component
  alias __MODULE__

  alias ICalendar.Property
  alias ICalendar.Alarm

  @type t :: %__MODULE__{
    dtstamp: DateTime,
    uid: UID,
    when: C.juncture
  }

  @optkeys [:dtstamp, :uid, :when, :alarms]

  @enforce_keys [:when]
  defstruct @enforce_keys ++ [
    __type__: :component,
    dtstamp: DateTime, # :required, :once, fallback to now
    uid: UID, # :once, :required (maybe fallback to uuidv4)
    when: nil,
    # :once, :required if (method in calendar), else optional,
    alarms: [],
    props: [
      # ;
      # ; The following are OPTIONAL,
      # ; but MUST NOT occur more than once.
      # ;
      # class / created / description / geo /
      # last-mod / location / organizer / priority /
      # seq / status / summary / transp /
      # url / recurid /
      # ;
      # ; The following is OPTIONAL,
      # ; but SHOULD NOT occur more than once.
      # ;
      # attach / attendee / categories / comment /
      # contact / exdate / rstatus / related /
      # resources / rdate / x-prop / iana-prop
    ]
  ]

  # Maybe todo
  # def spec do
  #   %{
  #     dtstamp: %{default: :datetime},
  #     uid: %{default: :text}
  #   }
  # end


  def new(opts) do
    {struct_opts, props} = Keyword.split(opts, @optkeys)
    case Keyword.pop(struct_opts, :when) do
      {nil, _} -> throw "when field is required for #{__MODULE__}"
      {wh, struct_opts} ->
        struct_opts =
          opts
          |> Map.new()
          |> Map.put(:when, ICalendar.Interval.new(wh))
          |> Map.put_new_lazy(:dtstamp, fn -> Timex.now() end)
          |> Map.put_new_lazy(:uid, fn -> UUID.uuid4() end)
          |> Map.put_new(:props, props)

        struct(Event, struct_opts)
    end
  end

  def encode(%__MODULE__{
    dtstamp: dtstamp,
    uid: uid,
    when: juncture,
    alarms: alarms,
    props: props
  }) do
    [
      Property.encode([uid: uid, dtstamp: dtstamp]),
      ICalendar.Interval.encode(juncture),
      # encode_juncture(juncture),
      # @crlf,
      Property.encode(props),
      # @crlf,
      Component.encode(alarms, :alarm)
    ]
  end

  # def decode(%__MODULE__{}) do
  #   [{:dtstamp, :required},
  #    {:uid, :required},
  #    # {{[:dtstart, :dtend, :duration], &{:when, encode_juncture(&1)}}, :required},
  #    ]
  #    # {:alarms, }
  #    # alarms: [],
  #   # props: []]
  # end

  # Check if event has DTSTART and/or DTEND if alarm needs it
  # def validate_alarms(_self)
end
