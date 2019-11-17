import { parse } from "../modules/helpers";
import { alertError } from "../modules/alerts";
import { t } from "../modules/i18n";

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
  doArchiveHelper
} from "./helpers";

const buttonElement = el => {
  if (el.nodeName === "BUTTON") return el;
  return el.closest("button");
};

const setupThreadActions = element => {
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
    ".message-icons .unsubscribe": unsubscribeMessageHelper
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

    element.disabled = true;
    element.classList.add("loading");

    fetch(url, requestParams).then(response => {
      element.disabled = false;
      element.classList.remove("loading");

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
};

export default setupThreadActions;
