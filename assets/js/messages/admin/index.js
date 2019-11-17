import showDeleteMessage from "./deletion";
import restoreMessage from "./restore";
import forbidAnswer from "./no_answer";
import allowAnswer from "./answer";

const ACTIONS = {
  delete: showDeleteMessage,
  restore: restoreMessage,
  "no-answer": forbidAnswer,
  answer: allowAnswer
};

const dispatchClicks = ev => {
  let element = ev.target;
  if (element.nodeName !== "BUTTON") {
    element = ev.target.closest("button");
  }

  if (!element) {
    return;
  }

  const jsAction = element.dataset.js;

  if (!jsAction || !ACTIONS[jsAction]) {
    return;
  }

  ACTIONS[jsAction](ev, element);
};

document.querySelectorAll(".cf-thread-list, .admin-links").forEach(el => el.addEventListener("click", dispatchClicks));
