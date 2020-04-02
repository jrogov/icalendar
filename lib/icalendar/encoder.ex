# defmodule ICalendar.Encoder do
#   alias ICalendar.RFC6868
#   alias ICalendar.Util
#   import ICalendar, only: [__props__: 1]

#   @crlf "\n"

#   defp component_str(key) do
#     case key do
#       :event    -> "VEVENT"
#       :alarm    -> "VALARM"
#       :calendar -> "VCALENDAR"
#       :todo     -> "VTODO"
#       :journal  -> "VJOURNAL"
#       :freebusy -> "VFREEBUSY"
#       :timezone -> "VTIMEZONE"
#       :standard -> "STANDARD"
#       :daylight -> "DAYLIGHT"
#     end
#   end

#   @doc "Encode into iCal format."
#   def encode(obj) do
#     encode_component(obj)
#   end

#   use ICalendar.Util

#   @doc "Encode a component."
#   @spec encode_component(component :: map) :: iodata
#   def encode_component(%{__type__: key} = component) do
#     cstr = component_str(key)
#     encoded_component =
#       # TODO: map drop is slow, use some form of a skip, probably reduce
#       component
#       |> Map.drop([:__type__])
#       |> Enum.map(fn
#            {key, vals} when is_list(vals) ->
#              Enum.map(vals, fn val -> encode_prop(key, val) end)
#            {key, val} ->
#              ICalendar.Property.encode(key, val)
#          end)

#     ~i"""
#     BEGIN:#{key}
#     #{encoded_component}
#     END:#{key}
#     """
#   end

# end
