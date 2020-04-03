defmodule ICalendarTest do
  use ExUnit.Case
  use ICalendarTest.Helpers
  alias ICalendarTest.Helpers
  use ICalendar

  test "ICalendar.encode/1 of empty calendar" do
    ics = I.Calendar.new() |> I.encode() |> IO.chardata_to_string()

    assert ics == Helpers.newline_to_crlf("""
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//arikai//iCalendar 0.5.0//EN
    CALSCALE:GREGORIAN
    END:VCALENDAR
    """)
  end

  test "ICalendar.encode/1 skips property with empty (nil) value" do
    ics =
      I.Calendar.new(some_cool_prop: nil)
      |> I.encode()
      |> IO.chardata_to_string()

    assert ics == Helpers.newline_to_crlf("""
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//arikai//iCalendar 0.5.0//EN
    CALSCALE:GREGORIAN
    END:VCALENDAR
    """)
  end

  test "ICalendar.encode/1 supports extra props" do
    ics =
      I.Calendar.new(some_cool_prop: "Some string")
      |> I.encode()
      |> IO.chardata_to_string()

    assert ics == Helpers.newline_to_crlf("""
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//arikai//iCalendar 0.5.0//EN
    CALSCALE:GREGORIAN
    SOME-COOL-PROP:Some string
    END:VCALENDAR
    """)
  end

  test "ICalendar.encode/1 of a calendar with an event, as in README" do
    ics =
      [
        # TODO: force UTC encoding of dtstamp (another type)
        I.Event.new(
          uid: "film-amy-adam",
          dtstamp: ~U[2015-12-23 22:00:00Z],
          summary: "Film with Amy and Adam",
          start: ~U[2015-12-24 08:30:00Z],
          end: [minutes: 15],
          description: "Let's go see Star Wars.",
        ),
        I.Event.new(
          uid: "morning-meeting-9000",
          dtstamp: ~U[2015-12-24 18:00:00Z],
          summary: "Morning meeting",
          start: ~U[2015-12-24 19:00:00Z],
          end: ~U[2015-12-24 22:30:00Z],
          description: "A big long meeting with lots of details.",
        )
      ]
      |> I.Calendar.new([])
      |> I.encode()
      |> assert_lines_fuzzy([
           """
           BEGIN:VCALENDAR
           VERSION:2.0
           PRODID:-//arikai//iCalendar 0.5.0//EN
           CALSCALE:GREGORIAN
           BEGIN:VEVENT
           UID:film-amy-adam
           DTSTAMP:20151223T220000Z
           DTSTART:20151224T083000Z
           DTEND:20151224T084500Z
           """,
           {:fuzzy,
           """
           SUMMARY:Film with Amy and Adam
           DESCRIPTION:Let's go see Star Wars.
           """},
           """
           END:VEVENT
           BEGIN:VEVENT
           UID:morning-meeting-9000
           DTSTAMP:20151224T180000Z
           DTSTART:20151224T190000Z
           DTEND:20151224T223000Z
           """,
           {:fuzzy,
           """
           SUMMARY:Morning meeting
           DESCRIPTION:A big long meeting with lots of details.
           """},
           """
           END:VEVENT
           END:VCALENDAR
           """])
  end

  test "Icalender.to_ics/1 with location and sanitization" do
    [
      I.Event.new(
        uid: "film-amy-adam",
        dtstamp: ~U[2015-12-23 22:00:00Z],
        summary: "Film with Amy and Adam",
        start: ~U[2015-12-24 08:30:00Z],
        end: [minutes: 15],
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada"
      )
    ]
    |> I.Calendar.new([])
    |> I.encode()
    |> assert_lines_fuzzy([
         """
         BEGIN:VCALENDAR
         VERSION:2.0
         PRODID:-//arikai//iCalendar 0.5.0//EN
         CALSCALE:GREGORIAN
         BEGIN:VEVENT
         UID:film-amy-adam
         DTSTAMP:20151223T220000Z
         DTSTART:20151224T083000Z
         DTEND:20151224T084500Z
         """,
         {:fuzzy,
         """
         DESCRIPTION:Let's go see Star Wars\\, and have fun.
         LOCATION:123 Fun Street\\, Toronto ON\\, Canada
         SUMMARY:Film with Amy and Adam
         """},
         """
         END:VEVENT
         END:VCALENDAR
         """
    ])

  end

  test "ICalendar.encode/1 with RRULE" do
    [
      I.Event.new(
        uid: "event-unique-uid",
        dtstamp: ~U[1990-01-01 00:00:00Z],
        start: ~U[1990-01-01 00:00:00Z],
        rrule: %ICalendar.RRULE{
          frequency: :yearly,
          until: Timex.to_datetime({{2022, 10, 12}, {15, 30, 0}}, "Etc/UTC"),
          by_day: [:monday, :wednesday, :friday],
          week_start: :monday,
          by_month: [:april]
        }
      )
    ]
    |> I.Calendar.new([])
    |> I.encode()
    |> assert_lines_fuzzy([
         """
         BEGIN:VCALENDAR
         VERSION:2.0
         PRODID:-//arikai//iCalendar 0.5.0//EN
         CALSCALE:GREGORIAN
         BEGIN:VEVENT
         UID:event-unique-uid
         DTSTAMP:19900101T000000Z
         DTSTART:19900101T000000Z
         RRULE:FREQ=YEARLY;UNTIL=20221012T153000Z;BYDAY=MO,WE,FR;BYMONTH=4;WKST=MO
         END:VEVENT
         END:VCALENDAR
         """
    ])
  end

  test "ICalendar.encode/1 with event with alarm" do
    I.Calendar.new([
      contents: [I.Event.new(
                    start: ~U[1990-01-01 00:00:00Z],
                    alarms: [I.Alarm.new(
                                action: "This alarm was displayed!",
                                trigger: ~U[1990-01-01 00:00:01Z])])]
    ])
    |> I.encode()
    |> assert_lines_fuzzy([
      """
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//arikai//iCalendar 0.5.0//EN
      CALSCALE:GREGORIAN
      BEGIN:VEVENT
      DTSTART:19900101T000000Z
      BEGIN:VALARM
      ACTION:DISPLAY
      DESCRIPTION:This alarm was displayed!
      TRIGGER:19900101T000001Z
      END:VALARM
      END:VEVENT
      END:VCALENDAR
      """
    ])
  end

  test "" do
    # c = I.Calendar.new(
    #   contents: [
    #     I.Event.new(
    #       start: Timex.now(),
    #       alarms: [
    #         I.Alarm.new(
    #           trigger: Timex.now(),
    #           action: %I.Alarm.Action.Audio{
    #             attach: %I.Binary{val: b, type: "image/png"}})])])
    # c = I.Calendar.new(
    #   contents: [
    #     I.Event.new(
    #       start: Timex.now(),
    #       attach: %I.Binary{val: b, type: "image/png"})])
  end



#   test "ICalender.to_ics/1 -> ICalendar.from_ics/1 and back again" do
#     events = [
#       %ICalendar.Event{
#         summary: "Film with Amy and Adam",
#         dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
#         dtend:   Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
#         description: "Let's go see Star Wars, and have fun.",
#         location: "123 Fun Street, Toronto ON, Canada"
#       }
#     ]
#     {:ok, new_event} =
#       %ICalendar{ events: events }
#       |> ICalendar.encode
#       |> ICalendar.from_ics

#     assert events |> List.first == new_event
#   end

#   test "encode_to_iodata/2" do
#     events = [
#       %ICalendar.Event{
#         summary: "Film with Amy and Adam",
#         dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
#         dtend:   Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
#         description: "Let's go see Star Wars.",
#       },
#       %ICalendar.Event{
#         summary: "Morning meeting",
#         dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
#         dtend:   Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
#         description: "A big long meeting with lots of details.",
#       },
#     ]
#     cal = %ICalendar{ events: events }

#     assert {:ok, ical} = ICalendar.encode_to_iodata(cal, [])
#     assert ical == """
#     BEGIN:VCALENDAR
#     CALSCALE:GREGORIAN
#     VERSION:2.0
#     BEGIN:VEVENT
#     DESCRIPTION:Let's go see Star Wars.
#     DTEND;TZID=Etc/UTC:20151224T084500
#     DTSTART;TZID=Etc/UTC:20151224T083000
#     SUMMARY:Film with Amy and Adam
#     END:VEVENT
#     BEGIN:VEVENT
#     DESCRIPTION:A big long meeting with lots of details.
#     DTEND;TZID=Etc/UTC:20151224T223000
#     DTSTART;TZID=Etc/UTC:20151224T190000
#     SUMMARY:Morning meeting
#     END:VEVENT
#     END:VCALENDAR
#     """
#   end

#   test "encode_to_iodata/1" do
#     events = [
#       %ICalendar.Event{
#         summary: "Film with Amy and Adam",
#         dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
#         dtend:   Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
#         description: "Let's go see Star Wars.",
#       },
#       %ICalendar.Event{
#         summary: "Morning meeting",
#         dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
#         dtend:   Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
#         description: "A big long meeting with lots of details.",
#       },
#     ]
#     cal = %ICalendar{ events: events }

#     assert {:ok, ical} = ICalendar.encode_to_iodata(cal)
#     assert ical == """
#     BEGIN:VCALENDAR
#     CALSCALE:GREGORIAN
#     VERSION:2.0
#     BEGIN:VEVENT
#     DESCRIPTION:Let's go see Star Wars.
#     DTEND;TZID=Etc/UTC:20151224T084500
#     DTSTART;TZID=Etc/UTC:20151224T083000
#     SUMMARY:Film with Amy and Adam
#     END:VEVENT
#     BEGIN:VEVENT
#     DESCRIPTION:A big long meeting with lots of details.
#     DTEND;TZID=Etc/UTC:20151224T223000
#     DTSTART;TZID=Etc/UTC:20151224T190000
#     SUMMARY:Morning meeting
#     END:VEVENT
#     END:VCALENDAR
#     """
#   end
end
