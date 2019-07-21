import { t } from "../modules/i18n";
import { alertInfo } from "../modules/alerts";

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
      const intlScore = new Intl.NumberFormat(window.navigator.language).format(data.score);
      elem.innerText = `(${intlScore})`;
      elem.setAttribute("title", t("{score} points", { score: intlScore }));
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

  channel.on("notification_count", data => {
    const elem = document.getElementById("notifications-display");
    if (elem) {
      elem.innerText = `${data.unread}`;
      elem.setAttribute("title", t("{count} new notifications"));
    }
  });
});
