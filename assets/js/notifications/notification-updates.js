import { t } from "../modules/i18n";
import { alertInfoWithPath } from "../modules/alerts";
import { updateTitleInfos, setNewFavicon } from "../title_infos";

const updateNotificationCount = count => {
  const liElem = document.getElementById("user-notifications");
  if (liElem) {
    if (count > 0) {
      liElem.classList.add("new");
    } else {
      liElem.classList.remove("new");
    }
  }
};

document.addEventListener("cf:userPrivate", event => {
  const channel = event.detail;

  channel.on("new_priv_message", data => {
    updateTitleInfos();

    const elem = document.getElementById("mails");
    if (elem) {
      elem.innerText = `(${data.unread})`;
      elem.setAttribute("title", t("{count} unread mails", { unread: data.unread }));
    }

    const liElem = document.getElementById("post-link");
    if (liElem) {
      if (data.unread > 0) {
        liElem.classList.add("new");
      } else {
        liElem.classList.remove("new");
      }
    }

    alertInfoWithPath(
      t("You've got a new mail from {sender}: {subject}", {
        sender: data.priv_message.sender_name,
        subject: data.priv_message.subject
      }),
      data.path
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
    updateTitleInfos();
    setNewFavicon();

    const elem = document.getElementById("notifications-display");
    if (elem) {
      elem.innerText = `(${data.unread})`;
      elem.setAttribute("title", t("{count} new notifications"));
    }

    updateNotificationCount(data.unread);

    alertInfoWithPath(
      t("You've got a new notification: {subject}", { subject: data.notification.subject }),
      data.notification.path
    );
  });

  channel.on("notification_count", data => {
    updateTitleInfos();

    const elem = document.getElementById("notifications-display");
    if (elem) {
      elem.innerText = `(${data.unread})`;
      elem.setAttribute("title", t("{count} new notifications"));
    }

    updateNotificationCount(data.unread);
  });
});
