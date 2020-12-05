import { parseMessageUrl, parse } from "../modules/helpers";
import { alertError } from "../modules/alerts";
import { t } from "../modules/i18n";

const SELECTOR =
  "button[data-js=mark-unread], button[data-js=mark-interesting], button[data-js=mark-boring], button[data-js=subscribe], button[data-js=unsubscribe]";

const ACTIONS = {
  "mark-unread": {
    url: "/api/v1/messages/mark-unread",
    action: (event, thread, response) => {
      event.target.remove();
      return true;
    },
  },
  "mark-interesting": {
    url: "/api/v1/messages/interesting",
    action: (event, thread, response) => {
      event.target.textContent = t("mark message boring");
      event.target.dataset.js = "mark-boring";
      return true;
    },
  },
  "mark-boring": {
    url: "/api/v1/messages/boring",
    action: (event, thread, response) => {
      event.target.textContent = t("mark message interesting");
      event.target.dataset.js = "mark-interesting";
      return true;
    },
  },
  subscribe: {
    url: "/api/v1/messages/subscribe",
    action: (event, thread, response) => {
      event.target.textContent = t("unsubscribe message");
      event.target.dataset.js = "unsubscribe";
      return true;
    },
  },
  unsubscribe: {
    url: "/api/v1/messages/unsubscribe",
    action: (event, thread, response) => {
      event.target.textContent = t("subscribe message");
      event.target.dataset.js = "subscribe";
      return true;
    },
  },
};

const messageButtonClicked = async (ev) => {
  const form = ev.target.closest("form");

  const thread = form.closest(".cf-thread-message");
  const header = thread.querySelector(".cf-message-header");
  const mid = header.id.replace(/^m/, "");
  const url = parseMessageUrl(header.querySelector("h2 a, h3 a").href);

  const csrfToken = form.querySelector('input[name="_csrf_token"]').value;
  const action = ACTIONS[ev.target.dataset.js];

  if (!action) {
    return;
  }

  ev.preventDefault();

  const fdata = new FormData();
  fdata.append("_csrf_token", csrfToken);
  fdata.append("slug", url.slug);
  fdata.append("message_id", mid);
  fdata.append("forum", document.body.dataset.currentForum);
  fdata.append("fold", "no");

  try {
    const response = await fetch(action.url, {
      method: "POST",
      credentials: "same-origin",
      cache: "no-cache",
      body: fdata,
    });

    if (!response.ok) {
      throw new Error();
    }

    const text = await response.text();

    const replace = !action.action || action.action(ev, thread, text);

    if (replace) {
      const node = parse(text);
      document.querySelector(".cf-thread-list .cf-thread").replaceWith(node);
    }
  } catch (e) {
    alertError(t("Oops, something went wrong!"));
  }
};

document.querySelectorAll(SELECTOR).forEach((button) => button.addEventListener("click", messageButtonClicked));
