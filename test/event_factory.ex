defmodule EventStore.EventFactory do
  alias EventStore.{EventData,RecordedEvent}

  defmodule Event do
    defstruct event: nil
  end

  def create_events(number_of_events) when number_of_events > 0 do
    correlation_id = UUID.uuid4()

    1..number_of_events
    |> Enum.map(fn number ->
      %EventData{
        correlation_id: correlation_id,
        event_type: "unit_test_event",
        headers: serialize(%{"user" => "user@example.com"}),
        payload: serialize(%EventStore.EventFactory.Event{event: number})
      }
    end)
  end

  def create_recorded_events(number_of_events, stream_id, initial_event_id \\ 1, initial_stream_version \\ 1) when number_of_events > 0 do
    correlation_id = UUID.uuid4()

    1..number_of_events
    |> Enum.map(fn number ->
      event_id = initial_event_id + number - 1
      stream_version = initial_stream_version + number - 1

      %RecordedEvent{
        event_id: event_id,
        stream_id: stream_id,
        stream_version: stream_version,
        correlation_id: correlation_id,
        event_type: "unit_test_event",
        headers: serialize(%{"user" => "user@example.com"}),
        payload: serialize(%EventStore.EventFactory.Event{event: event_id}),
        created_at: :calendar.universal_time
      }
    end)
  end

  def deserialize_events(events) do
    events
    |> Enum.map(fn event ->
      %RecordedEvent{event | payload: deserialize(event.payload), headers: deserialize(event.headers)}
    end)
  end

  defp serialize(term) do
    EventStore.TermSerializer.serialize(term)
  end
  
  defp deserialize(binary) do
    EventStore.TermSerializer.deserialize(binary)
  end
end
