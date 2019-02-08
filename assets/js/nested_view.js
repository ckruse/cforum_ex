import { conf, parseMessageUrl } from "./modules/helpers";
import { t } from "./modules/i18n";

const toggleFoldedHandler = ev => {
  const btn = ev.target;
  const posting = btn.closest(".posting-nested");
  toggleFolded(posting, btn);
};

const toggleFolded = (posting, button = null) => {
  if (!button) {
    button = posting.querySelector(
      ".posting-header > .cf-message-header > .details > .cf-message-header-unfold-button"
    );
  }

  posting.classList.toggle("folded");

  if (posting.classList.contains("folded")) {
    button.firstChild.textContent = t("unfold");
  } else {
    button.firstChild.textContent = t("fold");
  }
};

const foldMessage = el => {
  const posting = el.closest(".posting-nested");

  const node = document.createElement("button");
  node.type = "button";
  node.addEventListener("click", toggleFoldedHandler);
  node.classList.add("cf-message-header-unfold-button");
  node.setAttribute("aria-live", "assertive");

  posting.querySelector(".cf-message-header .details").appendChild(node);

  if (!posting.classList.contains("active")) {
    node.appendChild(document.createTextNode(t("unfold")));
    posting.classList.add("folded");
  } else {
    node.appendChild(document.createTextNode(t("fold")));
  }
};

const toggleActiveMessage = (messageId, scrollToIt = true) => {
  const active = document.querySelector(".cf-thread-nested .cf-thread-message.active");
  if (active) {
    active.classList.remove("active");
    if (conf("fold_read_nested")) {
      toggleFolded(active);
    }
  }

  const newActive = document.getElementById(messageId);
  if (!newActive) {
    return;
  }

  const thread = newActive.closest(".cf-thread-message");
  thread.classList.add("active");
  if (thread.classList.contains("folded")) {
    toggleFolded(thread);
  }

  if (scrollToIt) {
    thread.scrollIntoView();
  }
};

if (document.body.dataset.controller === "MessageController" && document.body.classList.contains("nested-view")) {
  document.addEventListener("cf:configDidLoad", () => {
    if (!conf("fold_read_nested")) {
      return;
    }

    document
      .querySelectorAll(".cf-thread-nested .cf-thread-message > .posting-header > .cf-message-header.visited")
      .forEach(el => foldMessage(el));

    const el = document.querySelector(".cf-thread-nested .cf-thread-message.active");
    if (el) {
      el.scrollIntoView();
    }
  });

  document.querySelector(".cf-thread-list").addEventListener("click", function(ev) {
    const url = ev.target.href;

    if (!url || !url.match(/#m\d+$/)) {
      return;
    }

    const parsedUrl = parseMessageUrl(url);
    const location = parseMessageUrl(document.location.href);

    /* ignore this click if link links to a different thread */
    if (parsedUrl.slug !== location.slug || parsedUrl.forum !== location.forum) {
      return;
    }

    ev.preventDefault();
    window.history.pushState("#m" + parsedUrl.messageId, "", url);
    toggleActiveMessage("m" + parsedUrl.messageId);
  });

  window.addEventListener("popstate", () => {
    if (!document.location.href.match(/#m\d+$/)) {
      return;
    }

    const parsedUrl = parseMessageUrl(document.location.href);
    const active = document.querySelector(
      ".cf-thread-nested .cf-thread-message.active > .posting-header > .cf-message-header"
    );
    if (active && active.id === "m" + parsedUrl.messageId) {
      return;
    }

    toggleActiveMessage("m" + parsedUrl.messageId, false);
  });

  document.querySelector(".cf-thread-nested-root").addEventListener("click", ev => {
    const trgt = ev.target;
    if (!trgt.matches(".cf-thread-message a") || !trgt.href.match(/#m\d+$/)) {
      return;
    }

    ev.preventDefault();

    const newMessageUrl = parseMessageUrl(trgt.href);
    window.history.pushState("#m" + newMessageUrl.messageId, "", trgt.href);
    toggleActiveMessage("m" + newMessageUrl.messageId);
  });
}
