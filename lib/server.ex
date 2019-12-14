defmodule Server do
  use GenServer

  def init(nil) do
    #initialize ets tables

    Simulator.initializetables()
    {:ok,nil}
  end

  def start(nil) do
    IO.puts "server initialized"
    GenServer.start_link(__MODULE__,nil,name: Server)
  end
  # def start_link(_ignore \\ nil) do
  #   Simulator.initializetables()
  #   GenServer.start_link(__MODULE__, nil, [])
  # end {:remove_user, userid}, _from, nil   |> Enum.at(0) |> elem(1)

  def handle_call({:registeruser,userid,sublist},from,nil) do
    IO.inspect userid
    IO.inspect sublist
    IO.inspect Enum.at(Tuple.to_list(from),0)
    :ets.insert_new(:users,{userid, sublist})
    :ets.insert_new(:activeusers,{userid, :true})
    :ets.insert_new(:userTweets,{userid, []})
    :ets.insert_new(:subscriberTweets,{userid, []})
    :ets.insert_new(:storeuserpids,{userid, Enum.at(Tuple.to_list(from),0)})

    {:reply, "registered", nil}
  end

  def handle_call({:subscribe,userid,sublist},_from,nil) do
    IO.inspect userid
    IO.inspect sublist
    temp = :ets.lookup(:users,userid) |> Enum.at(0) |> elem(1)
    IO.puts "temp"
    IO.inspect temp ++ sublist
    :ets.insert(:users,{userid,temp ++ sublist})
    IO.inspect :ets.lookup(:users,userid)


    {:reply, "subscribec", nil}
  end

  def handle_cast({:addtousertable,userid,sublist},nil) do
    IO.inspect userid
    IO.inspect sublist
    :ets.insert_new(:users,{userid, sublist})
    :ets.insert_new(:activeusers,{userid, :true})



    {:noreply,nil}
  end


  def get_msgs(userid) do
    IO.inspect :ets.lookup(:userTweets,userid)
  end

  def handle_cast({:printtable,userid},nil) do
    IO.puts "caasrted"
    IO.inspect userid
    # IO.inspect :ets.lookup(:users,userid)

    {:noreply,nil}
  end


  def handle_cast({:userTweets, userid, msgs},nil) do

    temp = :ets.lookup(:userTweets,userid) |> Enum.at(0) |> elem(1)
    :ets.insert(:userTweets,{userid,temp ++ msgs})
    IO.inspect :ets.lookup(:userTweets,userid)
    subscribers = :ets.lookup(:users,userid) |> Enum.at(0) |> elem(1)
    Enum.each(subscribers, fn subscriber ->
      cond do
      :ets.lookup(:subscriberTweets,subscriber) == [] -> :ets.insert_new(:subscriberTweets,{subscriber, msgs})
      true ->

            a =  Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:subscriberTweets,subscriber),0)),1)
            :ets.insert(:subscriberTweets,{subscriber, a ++ msgs})

      end
     end)
     IO.inspect :ets.lookup(:subscriberTweets,userid)

    #  scan for hashtags
    Enum.each(msgs, fn msg ->
      a = String.split(msg, " ")
    tag = ""
    tag = Enum.reduce(a,"",fn(word,tag)->
      cond do
            String.at(word,0) == "#" -> word
            true -> tag
          end
       end)
     IO.inspect tag
    cond do
    :ets.lookup(:hashTags,tag) == [] -> :ets.insert_new(:hashTags,{tag, [msg]})
    true ->

          a =  Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:hashTags,tag),0)),1)
          :ets.insert(:hashTags,{tag, a ++ [msg]})

    end
   end)

   #scan for mentions
   Enum.each(msgs, fn msg ->
    a = String.split(msg, " ")
  tag = ""
  tag = Enum.reduce(a,"",fn(word,tag)->
    cond do
          String.at(word,0) == "@" -> Enum.at(Tuple.to_list(Integer.parse(String.slice(word, 6..7))),0)
          true -> tag
        end
     end)
   IO.inspect tag
  cond do
  :ets.lookup(:mentions,tag) == [] -> :ets.insert_new(:mentions,{tag, [msg]})
  true ->

        a =  Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:mentions,tag),0)),1)
        :ets.insert(:mentions,{tag, a ++ [msg]})

  end
 end)

    {:noreply,nil}
  end


  def handle_cast({:searchhashtags,hash,userid},nil) do
    IO.inspect "tweetswithhashtags"
    IO.inspect :ets.lookup(:hashTags,hash) |> Enum.at(0) |> elem(1)
    tweetswithhashes = :ets.lookup(:hashTags,hash) |> Enum.at(0) |> elem(1)
    pidofsocket = :ets.lookup(:storeuserpids,userid) |> Enum.at(0) |> elem(1)
    IO.inspect pidofsocket
    send pidofsocket, %{"tweetText" => tweetswithhashes, "sender"=>userid,"key"=>0}
    {:noreply,nil}
  end

  def handle_cast({:givefeedforuser,userid},nil) do

    temp = :ets.lookup(:userTweets,userid) |> Enum.at(0) |> elem(1)
    IO.inspect temp
    temp1 = :ets.lookup(:subscriberTweets,userid) |> Enum.at(0) |> elem(1)
    IO.inspect "give feed for user called222"
    IO.inspect temp++temp1
    pidofsocket = :ets.lookup(:storeuserpids,userid) |> Enum.at(0) |> elem(1)
    send pidofsocket, %{"tweetText" => temp++temp1, "sender"=>userid,"key"=>1}
    {:noreply,nil}
  end

  def handle_cast({:addSubscriberTweet, userid, subscribers},nil) do
    mesgs = Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:userTweets,userid),0)),1)
    Enum.each(subscribers, fn subscriber ->
    cond do
    :ets.lookup(:subscriberTweets,subscriber) == [] -> :ets.insert_new(:subscriberTweets,{subscriber, mesgs})
    true ->

          a =  Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:subscriberTweets,subscriber),0)),1)
          :ets.insert(:subscriberTweets,{subscriber, a ++ mesgs})

    end
   end)


    {:noreply,nil}
  end


  def handle_cast({:addHash, userid, msgs},nil) do
    Enum.each(msgs, fn msg ->
      a = String.split(msg, " ")
    tag = ""
    tag = Enum.reduce(a,"",fn(word,tag)->
      cond do
            String.at(word,0) == "#" -> word
            true -> tag
          end
       end)
     IO.inspect tag
    cond do
    :ets.lookup(:hashTags,tag) == [] -> :ets.insert_new(:hashTags,{tag, [msg]})
    true ->

          a =  Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:hashTags,tag),0)),1)
          :ets.insert(:hashTags,{tag, a ++ [msg]})

    end
   end)


    {:noreply,nil}
  end


  def handle_cast({:mentionsHandle, userid, msgs},nil) do
    Enum.each(msgs, fn msg ->
      a = String.split(msg, " ")
    tag = ""
    tag = Enum.reduce(a,"",fn(word,tag)->
      cond do
            String.at(word,0) == "@" -> Enum.at(Tuple.to_list(Integer.parse(String.slice(word, 6..7))),0)
            true -> tag
          end
       end)
     IO.inspect tag
    cond do
    :ets.lookup(:mentions,tag) == [] -> :ets.insert_new(:mentions,{tag, [msg]})
    true ->

          a =  Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:mentions,tag),0)),1)
          :ets.insert(:mentions,{tag, a ++ [msg]})

    end
   end)


    {:noreply,nil}
  end



def handle_call({:remove_user, userid}, _from, nil) do
    :ets.delete(:users, userid)
    IO.puts "removeuser"
    {:reply, "userremoved", nil}
  end

  def handle_call({:logout_user, userid}, _from, nil) do
    :ets.insert(:activeusers,{userid, :false})
    IO.puts "logout_user"
    {:reply, "userlogouts", nil}

  end

  def handle_call({:login_user, userid}, _from, nil) do
    :ets.insert(:activeusers,{userid, :true})
    IO.puts "login_user!!!!!"
    {:reply, "userlogins", nil}

  end

end
