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
  let channel = event.detail;

  channel.on("new_priv_message", data => {
    const elem = document.getElementById("mails");
    if (elem) {
      elem.innerText = data.unread;
      elem.title = t("{count} unread mails", { unread: data.unread });
    }

    alertInfo(
      t("You've got a new mail from {sender}: {subject}", {
        sender: data.priv_message.sender_name,
        subject: data.priv_message.subject
      })
    );
  });
});
