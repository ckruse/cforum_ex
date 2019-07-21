import { Socket } from "phoenix";
import { updateTitleInfos } from "./title_infos";

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

const privateChannelJoined = channel => {
  document.dispatchEvent(new CustomEvent("cf:userLobby", { detail: channel }));

  channel.push("visible_forums", {}).receive("ok", ({ forums }) => {
    window.visibleForums = forums;

    forums.forEach(forum => {
      const channel = socket.channel(`forum:${forum.forum_id}`, {});
      channel
        .join()
        .receive("ok", () => {
          document.dispatchEvent(new CustomEvent("cf:forumChannel", { detail: { channel, forum_id: forum.forum_id } }));
        })
        .receive("error", ({ reason }) => console.log("failed joining forum room", reason))
        .receive("timeout", () => console.log("forum room: networking issue. Still waiting..."));

      channel.on("new_message", data => {
        updateTitleInfos();
        const event = new CustomEvent("cf:newMessage", { detail: { channel, data } });
        document.dispatchEvent(event);
      });
    });
  });
};

export let allUsersChannel = socket.channel(`users:lobby`, {});
allUsersChannel
  .join()
  .receive("ok", () => privateChannelJoined(allUsersChannel))
  .receive("error", ({ reason }) => {
    console.log("failed joining users lobby", reason);
    document.dispatchEvent(new CustomEvent("cf:userLobbyFailed"));
  })
  .receive("timeout", () => {
    console.log("users lobby: networking issue. Still waiting...");
    document.dispatchEvent(new CustomEvent("cf:userLobbyFailed"));
  });

export let privateUserChannel = null;

if (document.body.dataset.userId) {
  privateUserChannel = socket.channel(`users:${document.body.dataset.userId}`, {});
  privateUserChannel
    .join()
    .receive("ok", () => document.dispatchEvent(new CustomEvent("cf:userPrivate", { detail: privateUserChannel })))
    .receive("error", ({ reason }) => {
      console.log("failed joining private user channel", reason);
      document.dispatchEvent(new CustomEvent("cf:userPrivateFailed"));
    })
    .receive("timeout", () => {
      console.log("private user channel: networking issue. Still waiting...");
      document.dispatchEvent(new CustomEvent("cf:userPrivateFailed"));
    });
}

export default socket;
