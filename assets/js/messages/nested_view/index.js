import { conf, parseMessageUrl, isInAdminView } from "../../modules/helpers";
import { t } from "../../modules/i18n";

import "./mark_read";

const toggleFoldedHandler = (ev) => {
  const btn = ev.target;
  const posting = btn.closest(".posting-nested");
  toggleFolded(posting, btn);
};

const toggleFolded = (posting, button = null) => {
  if (!button) {
    button = posting.querySelector(".posting-header > .cf-message-header-unfold-button");
  }

  posting.classList.toggle("folded");

  if (posting.classList.contains("folded")) {
    button.firstChild.textContent = t("unfold");
  } else {
    button.firstChild.textContent = t("fold");
  }
};

const foldMessage = (el) => {
  if (el.classList.contains("deleted") && !isInAdminView()) {
    return;
  }

  const posting = el.closest(".posting-nested");
  const isActive = posting.classList.contains("active");
  const isRead = el.classList.contains("visited");

  if (!posting.querySelector(".cf-message-header-unfold-button")) {
    const node = document.createElement("button");
    node.type = "button";
    node.addEventListener("click", toggleFoldedHandler);
    node.classList.add("cf-message-header-unfold-button");
    node.setAttribute("aria-live", "assertive");

    posting.querySelector(".posting-header").appendChild(node);
    node.textContent = t(!isRead || isActive ? "fold" : "unfold");
  }

  if (isRead && !isActive) {
    posting.classList.add("folded");
  }
};

const toggleActiveMessage = (messageId, scrollToIt = true) => {
  const active = document.querySelector(".cf-thread-nested .cf-thread-message.active");
  if (active) {
    active.classList.remove("active");
    if (conf("fold_read_nested") === "yes") {
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

const foldAllMode = () =>
  document.querySelector(".cf-thread-nested-root.folded, .cf-thread-nested-root .folded") ? "unfold" : "fold";

const toggleAll = (ev) => {
  ev.stopPropagation();
  const mode = foldAllMode();

  if (mode === "fold") {
    document.querySelectorAll(".cf-thread-message:not(.folded)").forEach((el) => toggleFolded(el));
    ev.target.textContent = t("unfold all");
  } else {
    document.querySelectorAll(".cf-thread-message.folded").forEach((el) => toggleFolded(el));
    ev.target.textContent = t("fold all");
  }

  document.dispatchEvent(new CustomEvent("cf:foldingAllButtonChanged", { detail: ev.target }));
};

const initialFold = () => {
  if (!conf("fold_read_nested")) {
    return;
  }

  document
    .querySelectorAll(".cf-thread-nested .cf-thread-message > .posting-header > .cf-message-header")
    .forEach((el) => foldMessage(el));

  const el = document.querySelector(".cf-thread-nested .cf-thread-message.active");
  if (el) {
    el.scrollIntoView();
  }

  const mode = foldAllMode();
  const label = mode === "unfold" ? "unfold all" : "fold all";
  let foldingAllButton = document.getElementById("folding-all-button");

  if (!foldingAllButton) {
    foldingAllButton = document.createElement("button");
    document.body.appendChild(foldingAllButton);
    foldingAllButton.addEventListener("click", toggleAll);
    foldingAllButton.id = "folding-all-button";
  }

  foldingAllButton.textContent = t(label);
  document.dispatchEvent(new CustomEvent("cf:foldingAllButtonChanged", { detail: foldingAllButton }));
};

let initialFoldConfigDidLoadRun = false;
const initialFoldConfigDidLoad = () => {
  if (initialFoldConfigDidLoadRun) {
    return;
  }

  initialFoldConfigDidLoadRun = true;
  initialFold();
};

initialFold();
document.addEventListener("cf:configDidLoad", initialFoldConfigDidLoad);

document.querySelector(".cf-thread-list")?.addEventListener("click", function (ev) {
  const url = ev.target.href;
  if (!url || !url.match(/#m\d+$/)) {
    return;
  }

  const parsedUrl = parseMessageUrl(url);
  const location = parseMessageUrl(document.location.href);
  const elem = document.getElementById("m" + parsedUrl.messageId);

  /* ignore this click if link links to a different thread or is a message not yet loaded */
  if (parsedUrl.slug !== location.slug || parsedUrl.forum !== location.forum || !elem) {
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

document.querySelector(".cf-thread-nested-root").addEventListener("click", (ev) => {
  const trgt = ev.target;
  if (!trgt.matches(".cf-thread-message header a") || !trgt.href.match(/#m\d+$/)) {
    return;
  }

  ev.preventDefault();

  const newMessageUrl = parseMessageUrl(trgt.href);
  window.history.pushState("#m" + newMessageUrl.messageId, "", trgt.href);
  toggleActiveMessage("m" + newMessageUrl.messageId);
});
