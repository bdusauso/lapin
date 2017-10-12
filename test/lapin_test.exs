defmodule LapinTest do
  use ExUnit.Case
  doctest Lapin

  alias Lapin.{Connection, Message}

  setup_all do
    exchange = "test_exchange"
    queue = "test_queue"
    %{
      exchange: exchange,
      queue: queue,
      producer: [
        handle: :test_producer,
        virtual_host: "local",
        channels: [
          [
            role: :producer,
            worker: LapinTest.TestWorker,
            exchange: exchange,
            queue: queue
          ]
        ]
      ],
      consumer: [
        handle: :test_consumer,
        virtual_host: "local",
        channels: [
          [
            role: :consumer,
            worker: LapinTest.TestWorker,
            exchange: exchange,
            queue: queue
          ]
        ]
      ],
      message: %Message{payload: ""}
    }
  end

  test "Producer can publish", ctx do
    {:ok, producer} = Connection.start_link(ctx.producer)
    :ok = Lapin.Connection.publish(producer, ctx.exchange, "", ctx.message)
  end

  test "Consumer can't publish", ctx do
    {:ok, consumer} = Connection.start_link(ctx.consumer)
    {:error, _} = Lapin.Connection.publish(consumer, ctx.exchange, "", ctx.message)
  end
end
