import { parse } from "./modules/helpers";
import { t } from "./modules/i18n";

const addNotificationCheckbox = el => {
  const td = document.createElement("td");

  const input = document.createElement("input");
  input.type = "checkbox";
  input.value = el.id;

  td.appendChild(input);
  el.insertBefore(td, el.firstChild);
};

const handleClickEvent = (ev, btnDelete, btnMarkRead, btnMarkUnread) => {
  if (ev.target.nodeName !== "INPUT") {
    return;
  }

  const id = ev.target.value;
  if (ev.target.checked) {
    document
      .querySelector("form[data-js='notifications-batch-form']")
      .appendChild(parse(`<input type="hidden" name="notifications[]" value="${id}">`));
  } else {
    document.querySelector(`form[data-js='notifications-batch-form'] input[value='${id}']`).remove();
  }

  if (document.querySelectorAll("form[data-js='notifications-batch-form'] input[name='notifications[]']").length > 0) {
    btnMarkRead.textContent = t("mark selected notifications as read");
    btnMarkUnread.textContent = t("mark selected notifications as unread");
    btnDelete.textContent = t("delete selected notifications");
  } else {
    btnMarkRead.textContent = t("mark all notifications as read");
    btnMarkUnread.textContent = t("mark all notifications as unread");
    btnDelete.textContent = t("delete all notifications");
  }
};

if (document.body.dataset.controller === "NotificationController") {
  const notifications = document.querySelectorAll(".cf-notifications-table tr.notification");

  if (notifications.length > 0) {
    const tbl = document.querySelector(".cf-notifications-table");
    const th = document.createElement("th");
    const tr = tbl.querySelector("thead tr");

    const btnMarkRead = document.querySelector("form[data-js='notifications-batch-form'] [data-js='batch-mark-read']");
    const btnMarkUnread = document.querySelector(
      "form[data-js='notifications-batch-form'] [data-js='batch-mark-unread']"
    );
    const btnDelete = document.querySelector("form[data-js='notifications-batch-form'] [data-js='batch-delete']");

    tr.insertBefore(th, tr.firstChild);

    notifications.forEach(addNotificationCheckbox);
    document
      .querySelector(".cf-notifications-table")
      .addEventListener("click", ev => handleClickEvent(ev, btnDelete, btnMarkRead, btnMarkUnread));
  }
}
