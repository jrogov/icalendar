defmodule ICalendar.Event do
  use ICalendar.Component
  alias __MODULE__

  alias ICalendar.Property

  # TODO
  @type t :: %__MODULE__{
    dtstamp: DateTime,
    uid: UID,
    # start:
  }

  # @optkeys [:dtstamp, :uid, :start, :alarms]
  @enforce_keys [:start]
  defstruct @enforce_keys ++ [
    __type__: :component,
    dtstamp: nil, # :required, :once, fallback to now
    uid: nil, # :once, :required (maybe fallback to uuidv4)
    end: nil, # :once, :required if (method in calendar), else optional,
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
    ],
    alarms: []
  ]
  @mainprops @struct |> Map.drop([:__struct__, :__type__, :props]) |> Map.keys()

  # Maybe todo
  # def spec do
  #   %{
  #     dtstamp: %{default: :datetime},
  #     uid: %{default: :text}
  #   }
  # end


  def new(opts) do
    {struct_opts, props} = Keyword.split(opts, @mainprops)
    struct(Event, [{:props, props} | struct_opts])
  end

  def encode(%__MODULE__{
    uid: uid,
    dtstamp: dtstamp,
    start: start,
    end: end_arg,
    props: props,
    alarms: alarms,
  }) do
    [
      Property.encode([
        {:uid, uid},
        {:dtstamp, dtstamp},
        {:dtstart, start},
        {:dtend, ICalendar.Interval.calculate_end(start, end_arg)}
        | props]),
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
