defmodule ICalendar.Calendar do
  alias __MODULE__
  alias ICalendar.{Component, Property}

  @prodid "-//arikai//iCalendar 0.5.0//EN"

  defstruct __type__: :object,
            prodid: @prodid,
            version: "2.0",
            calscale: "GREGORIAN",
            props: [],
            contents: []

  @optkeys [:prodid, :version, :calscale]

  def new, do: %Calendar{}
  def new(opts) do
    {struct_base, props} = Keyword.split(opts, [:contents | @optkeys])
    struct(%Calendar{props: props}, struct_base)
  end
  def new(contents, opts) do
    {struct_base, props} = Keyword.split(opts, @optkeys)
    struct(%Calendar{contents: contents, props: props}, struct_base)
  end

  def encode(self) do
    %{prodid: prodid,
      version: version,
      calscale: calscale,
      props: props,
      contents: contents} = self
    [
      [{:version, version},
       {:prodid, prodid},
       {:calscale, calscale}
       | props]
      |> Property.encode(),
      Component.encode(contents, :component)
    ]
  end
end
