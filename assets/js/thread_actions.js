import { parse } from "./modules/helpers";
import {
  openThreadHelper,
  closeThreadHelper,
  hideThreadHelper,
  unhideThreadHelper,
  markReadHelper,
  markInterestingHelper,
  markBoringHelper,
  subscribeMessageHelper,
  unsubscribeMessageHelper,
  noArchiveHelper,
  doArchiveHelper,
  deleteHelper,
  restoreHelper,
  noAnswerHelper,
  doAnswerHelper
} from "./thread_actions/helpers";
import { alertError } from "./alerts";
import { t } from "./modules/i18n";

const buttonElement = el => {
  if (el.nodeName === "BUTTON") return el;
  return el.closest("button");
};

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector(".cf-thread-list");

  if (!element || !element.matches) {
    return;
  }

  const validElements = {
    ".thread-icons .open": openThreadHelper,
    ".thread-icons .close": closeThreadHelper,
    ".thread-icons .hide": hideThreadHelper,
    ".thread-icons .unhide": unhideThreadHelper,
    ".thread-icons .mark-read": markReadHelper,
    ".thread-icons .no-archive": noArchiveHelper,
    ".thread-icons .archive": doArchiveHelper,
    ".message-icons .mark-interesting": markInterestingHelper,
    ".message-icons .boring": markBoringHelper,
    ".message-icons .subscribe": subscribeMessageHelper,
    ".message-icons .unsubscribe": unsubscribeMessageHelper,
    ".message-icons .delete": deleteHelper,
    ".message-icons .restore": restoreHelper,
    ".message-icons .answer": noAnswerHelper,
    ".message-icons .no-answer": doAnswerHelper
  };

  element.addEventListener("click", event => {
    const element = buttonElement(event.target);

    if (!element) {
      return;
    }

    const action = Object.keys(validElements).find(selector => element.matches(selector));

    if (!action) {
      return;
    }

    event.preventDefault();

    const form = element.closest("form");
    const requestParams = { credentials: "same-origin" };
    const { url, afterAction } = validElements[action](requestParams, form);

    fetch(url, requestParams).then(response => {
      if (!response.ok) {
        alertError(t("Oops, something went wrong!"));
        return;
      }

      if (afterAction) {
        afterAction(response);
      } else {
        response.text().then(text => {
          const node = parse(text);
          form.closest(".cf-thread").replaceWith(node);
        });
      }
    });
  });
});
