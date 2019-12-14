defmodule Twitter do
  use GenServer
  @moduledoc """
  Documentation for Twitter.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Twitter.hello()
      :world

  """

  # def main(args) do
  #   args |> parse_args |> starteverything()
  # end
  # defp parse_args(args) do
  #   {_,parameters,_} = OptionParser.parse(args, switches: [help: :boolean])
  #   parameters
  # end



  def starteverything(noofusers,noofmsgs) do
    # noofusers = 10
    # noofmsgs = 5

    Registry.start_link(keys: :unique, name: :storeuserpids)
    # server genprocess starting
    # spawn(fn -> Server.start(nil) end)
    # {:ok, pid} = Server.start_link
    # IO.inspect(pid)
    # Process.register pid, Server
    #client genservers starting
    Server.start(nil)
    for i <- 1..noofusers do
      Client.start(i,noofmsgs)
      # spawn(fn -> Client.start(i) end)
    end
    # registerusers()
  end

  def registerusers(noofusers) do
    # noofusers = 10
    Simulator.initializestuff(noofusers)
    Simulator.subScriberTweet(noofusers)
    Simulator.hashTagsHandle(noofusers)
    Simulator.mentionsHandle(noofusers)
    # hello()
  end
  def hello do

    noofusers = 10
    Simulator.initializestuff(noofusers)
    Simulator.subScriberTweet(noofusers)
    Simulator.hashTagsHandle(noofusers)
    Simulator.mentionsHandle(noofusers)
    GenServer.call(Twitter.getpidofnode(1),:logoutme)
    GenServer.call(Twitter.getpidofnode(1),:loginme)
    IO.inspect :ets.lookup(:activeusers,1)
    # GenServer.cast(pid,{:printtable,1})

  end

  def getpidofnode(user) do
    case Registry.lookup(:storeuserpids, user) do
    [{pid, _}] -> pid
    [] -> nil
    end
  end

end


