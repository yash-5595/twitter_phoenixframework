defmodule TwittersimulatorWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:subtopic", _message, socket) do
    {:ok, socket}
  end

  def join("room:"<> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
end

def handle_in("register", userName, socket) do
  # GenServer.call(:server, {:register, userName, socket})
  GenServer.cast(Server, {:printtable, userName})
  GenServer.call(Server,{:registeruser,userName,[]})
  IO.puts "Imcalled mfaf"
  push socket, "registered",  %{"userName" => userName}
  {:reply, :registered, socket}
end

def handle_in("subscribe", payload, socket) do
  userName = payload["username"]
  usersToSub = [payload["usersToSub"]] # A list of usernames
  GenServer.call(Server, {:subscribe, userName,usersToSub})
  push socket, "subscribed",  %{"userName" => userName}
  {:reply, :subscribed, socket}
end

def handle_in("tweet_subscribers", payload, socket) do
  tweetText = [payload["tweetText"]]
  userName = payload["username"]
  tweet_time =  payload["time"]
  event = "tweet_subscribers"
  IO.puts "username"
  IO.inspect userName
  IO.inspect tweetText
  GenServer.cast(Server, {:userTweets, userName, tweetText})
  {:noreply, socket}
end


def handle_in("search_hashtag", params, socket) do
  #{username: userNamesList[i], hashtagList: hashtagList, time: `${Date()}`}
  userName = params["username"]
  hashtagList = params["hashtagList"]
  time = params["time"]
  GenServer.cast(Server, {:searchhashtags,hashtagList,userName})
  {:noreply, socket}
end

def handle_in("getfeeds", params, socket) do
  #{username: userNamesList[i], hashtagList: hashtagList, time: `${Date()}`}
  userName = params["username"]
  time = params["time"]
  IO.inspect "give feed for user called"
  GenServer.cast(Server, {:givefeedforuser,userName})
  {:noreply, socket}
end


# def handle_info({:searchhashtag, tweetText}, socket) do
#   IO.inspect ["search hasth --------------", tweetText]
#   # push socket, "search_hashtag", %{"searched_tweet" => tweetText}

#   {:noreply, socket}
# end

def handle_info(tweetText, socket) do
  # IO.inspect "tweettext"
  # IO.inspect tweetText["sender"]
  # push socket, "tweet_sub", tweetText

  if(tweetText["key"] ===1) do
    IO.puts "got here ---------"
    push socket, "tweet_feeds", tweetText
  end
  if(tweetText["key"] ===0) do
    IO.puts "--- ---------"
    push socket, "tweet_sub", tweetText
  end
  {:noreply, socket}
end

end
