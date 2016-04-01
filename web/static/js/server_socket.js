// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

//var e_log = document.getElementById("e_log")
//var e_cmd = document.getElementById("e_cmd")
//var e_start = document.getElementById("e_start")

//if (over_log) {

let socket = new Socket("/socket", {params: {token: window.userToken}})

if (!window.serverID) {
	console.log("serverID not found")
} else {


// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
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
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

var e_log    = document.getElementById("e_log")
var e_cmd    = document.getElementById("e_cmd")
var e_load   = document.getElementById("e_load")
var e_start  = document.getElementById("e_start")
var e_stop   = document.getElementById("e_stop")
var e_unload = document.getElementById("e_unload")


socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("servers:" + window.serverID, {})
channel.join()
  .receive("ok", resp => {
	console.log("Joined successfully", resp)
	channel.push("state", {})
		.receive("ok", (msg) =>
			console.log("Got state of: " + msg.loaded)
			)
  })
  .receive("error", resp => { console.log("Unable to join", resp) })
  //.after(10000, () => { console.log("Connection interruption") })

channel.onError(() => { console.log("Channel Error") })
channel.onClose(() => { console.log("Channel closed") })

channel.on("msg", payload => {
	var msg = payload.msg
		e_log.appendChild(document.createTextNode(msg))
		e_log.appendChild(document.createElement('br'))
})

channel.on("shell:msg", payload => { console.log("Shell thing: " + payload.msg) })
channel.on("server:load", payload => {
	e_log.appendChild(document.createTextNode("Server loaded"))
        e_log.appendChild(document.createElement('br'))
})
channel.on("server:unload", payload => {
	e_log.appendChild(document.createTextNode("Server unloaded"))
	e_log.appendChild(document.createElement('br'))
})
channel.on("server:start", payload => {
	console.log("Server start message")
	e_log.style.backgroundColor = "white";
	while (e_log.firstChild) {
		e_log.removeChild(e_log.firstChild)
	}
	e_start.disabled = true
})
channel.on("server:stop", payload => {
	console.log("Server stop message: " + payload.result)
	e_log.style.backgroundColor = "gray"
	e_start.disabled = false
})
channel.on("server:log", payload => {
	console.log("Server log message: " + payload.log)
	var log = payload.log
	e_log.appendChild(document.createTextNode(log))
	e_log.appendChild(document.createElement('br'))
	e_log.style.backgroundColor = "white"
	e_start.disabled = false
})

e_cmd.onkeypress = function(e) {
	if (e.keyCode == 13) {
		var cmd = e_cmd.value
		e_cmd.value = ""
		channel.push("server:cmd", {cmd: cmd})
	}
}


e_load.onclick   = function() { channel.push("server:load",   {}) }

e_start.onclick  = function() { channel.push("server:start",  {}) }

e_stop.onclick   = function() { channel.push("server:stop",   {}) }

e_unload.onclick = function() { channel.push("server:unload", {}) }


}

export default socket


