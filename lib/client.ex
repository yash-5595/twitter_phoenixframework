defmodule Client do
  use GenServer

  def start(userid,numMsgs) do
    # IO.inspect userid
    GenServer.start_link(__MODULE__, [userid,numMsgs], name: {:via, Registry, {:storeuserpids, userid}})
  end

  def init([userid,numMsgs]) do
    msgs = msgGen(numMsgs)
    GenServer.cast(Server,{:userTweets, userid, msgs})
    {:ok,{userid,msgs}}
  end


  def msgGen(numMsgs) do
    acc = []
    acc = Enum.reduce(1..numMsgs,[],fn(k,acc)->
              acc = acc ++ [get_string()]
             end)
    acc
    end

    def get_string() do
      wrds = ["Kasi ","Pathi ","Just ","Abhi ","Akka ","bava ","Cyuaa ","pilkuth ","PK ","Arey ","OutAvvali ","Douche","aaaahh ","PathiRaju ","PathiRani ","Dasanna ","Ponnu ","Thaagubotu ","Pilla ","Bunty ","Chikkav "]
      tags = ["#Hard ","#Feelz ","#Diffu ","#Zeefee ","#Dippam ","#Xo ","#Weekend ","#NBA ","#NFL ","#kikufeels","#disha"]
      ac = Enum.join(["", Enum.join(Enum.take_random(wrds,10),"")],"")
      tigs = Enum.at(Enum.take_random([Enum.at(Enum.take_random(tags,1),0),""],1),0)
      usr = Enum.at(Enum.take_random([Enum.join(["@User_",Integer.to_string(Enum.at(Enum.take_random(Enum.to_list(1..10),1), 0))],""),""],1),0)
      new = Enum.join([tigs,usr]," ")

      Enum.join([ac,new],"")
    end

  def handle_cast({:addsubscribers,sublist},{userid,msgs}) do
    #

    GenServer.cast(Server,{:addtousertable, userid,sublist})
    # IO.puts "gothgvere"
    {:noreply,{userid,msgs}}

  end


  def handle_cast({:addSubTweet},{userid,msgs}) do
    #

    # GenServer.cast(Server,{:addtousertable, userid,sublist})
    # IO.puts "gothgvere"
    cond do
      :ets.lookup(:users,userid) != [] -> GenServer.cast(Server,{:addSubscriberTweet, userid,Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:users,userid),0)),1)})
      true ->
    end
    # subscibers = Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:users,userid),0)),1)
    # GenServer.cast(Server,{:addSubscriberTweet, userid,subscibers})
    {:noreply,{userid,msgs}}

  end


  def handle_cast({:addHashTags},{userid,msgs}) do
    # cond do
    #   :ets.lookup(:users,userid) != [] -> GenServer.cast(Server,{:addSubscriberTweet, userid,Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:users,userid),0)),1)})
    #   true ->
    # end
    GenServer.cast(Server,{:addHash, userid,msgs})
    {:noreply,{userid,msgs}}

  end

  def handle_cast({:addMentions},{userid,msgs}) do
    # cond do
    #   :ets.lookup(:users,userid) != [] -> GenServer.cast(Server,{:addSubscriberTweet, userid,Enum.at(Tuple.to_list(Enum.at(:ets.lookup(:users,userid),0)),1)})
    #   true ->
    # end
    GenServer.cast(Server,{:mentionsHandle, userid,msgs})
    {:noreply,{userid,msgs}}

  end



  def handle_info(:kill_me_pls, {userid,msgs}) do
    {:stop, :normal, {userid,msgs}}
  end

  def terminate(_,userid,msgs) do
    IO.puts "killing user"
    IO.inspect userid
  end

  def handle_call(:removeuser, _from,{userid,msgs}) do
    IO.puts "remove user called"
    GenServer.call(Server, {:remove_user, userid})
    send(Twitter.getpidofnode(userid) , :kill_me_pls)
    {:reply, "removesuccess", {userid,msgs}}
  end


  def handle_call(:logoutme, _from,{userid,msgs}) do

    IO.puts "logout user called"
    GenServer.call(Server, {:logout_user, userid})
    {:reply, "logout", {userid,msgs}}
  end

  def handle_call(:loginme, _from,{userid,msgs}) do

    IO.puts "login user called"
    GenServer.call(Server, {:login_user, userid})
    {:reply, "login", {userid,msgs }}
  end
end
