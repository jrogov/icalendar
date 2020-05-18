defmodule ICalendar.Calendar do
  alias __MODULE__
  alias ICalendar.{Component, Property}

  @prodid "-//arikai//iCalendar 0.5.0//EN"

  defstruct __type__: :object,
            prodid: @prodid,
            version: "2.0",
            calscale: "GREGORIAN",
            name: nil,
            props: [],
            contents: []

  @mainprops [:prodid, :version, :calscale, :contents]

  def new, do: new([])
  def new(opts), do: with_props(opts)
  def new(contents, opts) do
    opts
    |> Keyword.put(:contents, contents)
    |> with_props()
  end

  def with_props(calendar \\ %Calendar{}, props) do
    {struct_base, props} = Keyword.split(props, @mainprops)
    struct(calendar, [{:props, props} | struct_base])
  end

  def encode(self) do
    %{prodid: prodid,
      version: version,
      calscale: calscale,
      name: name,
      props: props,
      contents: contents} = self
    [
      [{:version, version},
       {:prodid, prodid},
       {:calscale, calscale},
       {"X-WR-CALNAME", name}
       | props]
      |> Property.encode(),
      Component.encode(contents, :component)
    ]
  end
end
