import { conf } from "../../modules/helpers";
import { getMessageTreeElement } from "./index";

const threadIsVisited = thread => {
  return thread.querySelectorAll(".cf-message-header:not(.visited)").length === 0;
};
const shouldFold = thread => threadIsVisited(thread) && document.body.dataset.controller === "ThreadController";

if (document.body.dataset.userId) {
  document.addEventListener("cf:userPrivate", event => {
    const channel = event.detail;

    channel.on("message_marked_read", ({ message_ids }) => {
      message_ids.forEach(id => {
        const elem = getMessageTreeElement(id);
        if (!elem) {
          return;
        }

        elem.classList.add("visited");

        const thread = elem.closest(".cf-thread");

        if (conf("open_close_close_when_read") === "yes" && shouldFold(thread)) {
          thread.querySelector("ol").remove();
        }
      });
    });
  });
}
