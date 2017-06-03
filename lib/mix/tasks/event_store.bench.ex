defmodule Mix.Tasks.EventStore.Bench do
  use Mix.Task

  alias EventStore.Storage
  alias EventStore.Storage.Database

  @doc false
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:postgrex)
    {:ok, _} = Application.ensure_all_started(:eventstore)

    :observer.start

    initial = :erlang.memory(:total)
    count = 1000000

    mems = Enum.map(1..count, fn i ->
      if (rem(i, div(count, 100)) == 0) do
        IO.puts "#{round(i / count * 100)} %"
      end

      EventStore.read_stream_forward(UUID.uuid4(), 0)
      :erlang.memory(:total)
    end)

    total = mems |> List.last

    IO.puts "Initial: #{initial |> to_mb}"
    IO.puts "Total: #{total |> to_mb}"
    IO.puts "Increase per read: #{(total - initial) / length(mems)}"
  end

  defp to_mb(bytes), do: bytes / 1024 / 1024
end
