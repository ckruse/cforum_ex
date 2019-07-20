import { Socket } from "phoenix";

const params = {};
if (window.userToken) {
  params.token = window.userToken;
}

let socket = new Socket("/socket", { params });
socket.connect();

socket.onOpen(() => {
  const elem = document.getElementById("user-info");
  if (elem) {
    elem.classList.add("connected");
  }
});

socket.onClose(() => {
  const elem = document.getElementById("user-info");
  if (elem) {
    elem.classList.remove("connected");
  }
});

socket.onError(() => {
  const elem = document.getElementById("user-info");
  if (elem) {
    elem.classList.remove("connected");
  }
});

// Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("topic:subtopic", {})
// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })

export default socket;
