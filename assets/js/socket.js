// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix";

let socket = new Socket("/socket", { params: { token: window.userToken } });

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect();

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:subtopic", {});
channel
  .join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
  })
  .receive("error", resp => {
    console.log("Unable to join", resp);
  });

function register(userName) {
  //register the new client
  channel
    .push("register", userName)
    .receive("registered", resp => console.log("registered", resp));
}

function subscribeUser(user, subscribersList) {
  channel
    .push("subscribe", { username: user, usersToSub: subscribersList })
    .receive("subscribed", resp => console.log("subscribed", user));
  console.log({ username: user, usersToSub: subscribersList });
}

function sendUserTweet(tweet, username) {
  channel.push("tweet_subscribers", {
    tweetText: tweet,
    username: username,
    time: `${Date()}`
  });

  channel.push("getfeeds", {
    username: userName.value,
    time: `${Date()}`
  });
  console.log({ tweetText: tweet, username: username, time: `${Date()}` });
}

function searchHashTag(username, hashTagValue) {
  channel.push("search_hashtag", {
    username: username,
    hashtagList: hashTagValue,
    time: `${Date()}`
  });
  console.log({
    username: username,
    hashtagList: [hashTagValue],
    time: `${Date()}`
  });
  // hashTagValue = "";
}

var userName = document.getElementById("username");
userName.addEventListener("keypress", function(event) {
  console.log("key press");

  if (event.keyCode == 13) {
    register(userName.value);
    console.log(userName.value);
  }
});

var subscribeUsername = document.getElementById("subscribe-username");
subscribeUsername.addEventListener("keypress", function(event) {
  console.log("subscribe username");
  if (event.keyCode == 13) {
    subscribeUser(userName.value, subscribeUsername.value);
    console.log(subscribeUsername.value);
  }
});

var sendTweet = document.getElementById("send-tweet");
sendTweet.addEventListener("keypress", function(event) {
  if (event.keyCode == 13) {
    sendUserTweet(sendTweet.value, userName.value);
  }
});

var searchHashTagInput = document.getElementById("search-hashtag");
searchHashTagInput.addEventListener("keypress", function(event) {
  if (event.keyCode == 13) {
    searchHashTag(userName.value, searchHashTagInput.value);
  }
});

// var getFeedButton = document.getElementById("get-feed");
// getFeedButton.addEventListener("click", function(event) {
//   channel.push("getfeeds", {
//     username: userName.value,
//     time: `${Date()}`
//   });
//   console.log({
//     username: userName.value,
//     time: `${Date()}`
//   });
//   console.log("button clicked");
// });

channel.on("tweet_sub", payload => {
  console.log(payload.tweetText, "payloadtweettext");
  var messages = document.getElementById("messages");

  var p = document.createElement("p");
  p.innerHTML = "<b>Tweets with Hashtags: </b>" + payload.tweetText;
  messages.appendChild(p);
});

channel.on("tweet_feeds", payload => {
  var messages = document.getElementById("messages");

  var p = document.createElement("p");
  var tweets = payload.tweetText;
  console.log(tweets.length, "length", tweets);
  p.innerHTML = "<b>Tweets: </b>" + tweets;
  messages.appendChild(p);
});
export default socket;
