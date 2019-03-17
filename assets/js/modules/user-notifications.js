import socket from "../socket";
import { t } from "./i18n";
import { alertInfo } from "../alerts";

export let allUsersChannel = socket.channel(`users:lobby`, {});
allUsersChannel
  .join()
  .receive("ok", () => document.dispatchEvent(new CustomEvent("cf:userLobby", { detail: allUsersChannel })))
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

document.addEventListener("cf:userPrivate", event => {
  const channel = event.detail;

  channel.on("new_priv_message", data => {
    const elem = document.getElementById("mails");
    if (elem) {
      elem.innerText = data.unread;
      elem.setAttribute("title", t("{count} unread mails", { unread: data.unread }));
    }

    alertInfo(
      t("You've got a new mail from {sender}: {subject}", {
        sender: data.priv_message.sender_name,
        subject: data.priv_message.subject
      })
    );
  });

  channel.on("score-update", data => {
    const elem = document.querySelector("#user-info .score");

    if (elem) {
      elem.innerText = `(${data.score})`;
      elem.setAttribute("title", t("{score} points", { score: data.score }));
    }
  });

  channel.on("new_notification", data => {
    const elem = document.getElementById("notifications-display");
    if (elem) {
      elem.innerText = `${data.unread}`;
      elem.setAttribute("title", t("{count} new notifications"));
    }

    alertInfo(t("You've got a new notification: {subject}", { subject: data.notification.subject }));
  });
});

document.addEventListener("cf:userLobby", event => {
  const channel = event.detail;

  channel.push("visible_forums", {}).receive("ok", ({ forums }) => {
    window.visibleForums = forums;

    forums.forEach(forum => {
      const channel = socket.channel(`forum:${forum.forum_id}`, {});
      channel
        .join()
        .receive("ok", () => {})
        .receive("error", ({ reason }) => console.log("failed joining forum room", reason))
        .receive("timeout", () => console.log("forum room: networking issue. Still waiting..."));

      channel.on("new_message", data => {
        const event = new CustomEvent("cf:newMessage", { detail: data });
        document.dispatchEvent(event);
      });
    });
  });
});
