import {Socket} from "phoenix"

class App {

  static init(){
    $('#join-room-button').click(function(){
      var room = $('#room-input').val()
      if(room.length > 0) {
        window.location.href = '?room=' + room;
      }
    })


    var socket     = new Socket("/ws")
    socket.connect()
    var $status    = $("#status")
    var $messages  = $("#messages")
    var $input     = $("#message-input")
    var $username  = $("#username")

    if(localStorage.getItem("username")) {
      $username.val(localStorage.getItem("username"))
    }

    socket.onClose( e => console.log("CLOSE", e))

    var room = location.search.split('room=')[1] || "lobby"
    var chan = socket.chan("rooms:" + room, {user: $username.val()})
    chan.join().receive("ignore", () => console.log("auth error"))
               .receive("ok", () => console.log("join ok"))
               .after(10000, () => console.log("Connection interruption"))
    chan.onError(e => console.log("something went wrong", e))
    chan.onClose(e => console.log("channel closed", e))

    $input.off("keypress").on("keypress", e => {
      if (e.keyCode == 13) {
        chan.push("new:msg", {user: $username.val(), body: $input.val()})
        localStorage.setItem("username", $username.val())
        $input.val("")
      }
    })

    chan.on("new:msg", msg => {
      $messages.append(this.messageTemplate(msg))
      scrollTo(0, document.body.scrollHeight)
    })

    chan.on("user:entered", msg => {
      var username = this.sanitize(msg.user || "anonymous")
      $messages.append(`<br/><i>[${username} entered]</i>`)
    })
  }

  static sanitize(html){ return $("<div/>").text(html).html() }

  static messageTemplate(msg){
    let username = this.sanitize(msg.user || "anonymous")
    let body     = this.sanitize(msg.body)

    return(`<p><a href='#'>[${username}]</a>&nbsp; ${body}</p>`)
  }

}

$( () => App.init() )

export default App
