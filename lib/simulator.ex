defmodule Simulator do
  use GenServer



  def initializestuff(noofusers) do

    listofusers = Enum.to_list(1..noofusers)
    Enum.reduce(listofusers, 1, fn user, rank ->
      maxNumOfSubscribers = length(listofusers)
      zipfFollowCount = ceil((1/rank)*maxNumOfSubscribers)
      followers = Enum.take_random(listofusers, zipfFollowCount) -- [user]
      GenServer.cast(Twitter.getpidofnode(user), {:addsubscribers, followers})

      rank + 1
    end)
    :timer.sleep(10)
    # GenServer.cast(Server, {:printtable, 1})
    # IO.puts "initialexit"
  end

  def subScriberTweet(noofusers) do
    listofusers = Enum.to_list(1..noofusers)
    acc = Enum.reduce(listofusers, 1, fn user, acc ->
      GenServer.cast(Twitter.getpidofnode(user), {:addSubTweet})
      acc
    end)

  end

  def hashTagsHandle(noofusers) do
    listofusers = Enum.to_list(1..noofusers)
    acc = Enum.reduce(listofusers, 1, fn user, acc ->
      GenServer.cast(Twitter.getpidofnode(user), {:addHashTags})
      acc
    end)
  end

  def mentionsHandle(noofusers) do
    listofusers = Enum.to_list(1..noofusers)
    acc = Enum.reduce(listofusers, 1, fn user, acc ->
      GenServer.cast(Twitter.getpidofnode(user), {:addMentions})
      acc
    end)
  end


  def querry(string) do

  end



  def initializetables() do

    :ets.new(:users,[:set,:public,:named_table,{:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:storeuserpids,[:set,:public,:named_table,{:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:activeusers,[:set,:public,:named_table,{:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:userTweets,[:set,:public,:named_table,{:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:subscriberTweets,[:set,:public,:named_table,{:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:hashTags,[:set,:public,:named_table,{:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:mentions,[:set,:public,:named_table,{:read_concurrency, true}, {:write_concurrency, true}])

  end




end
