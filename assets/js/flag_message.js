import { ready, bind } from "./modules/events";
import { select, all } from "./modules/selectors";
import { toggleHiddenState } from "./modules/elements";

ready(function() {
  if (!["flag-message", "close-vote-message-new"].includes(document.body.id)) {
    return;
  }

  const elementNames = {
    "flag-message": {
      option: "moderation_queue_entry[reason]",
      url: "#moderation_queue_entry_duplicate_url",
      custom: "#moderation_queue_entry_custom_reason"
    },
    "close-vote-message-new": {
      option: "close_vote[reason]",
      url: "#close_vote_duplicate_url",
      custom: "#close_vote_custom_reason"
    }
  };

  const elements = elementNames[document.body.id];

  const showOrHide = () => {
    const elem = select("[name='" + elements.option + "']:checked");
    const value = elem ? elem.value : null;

    switch (value) {
      case "duplicate":
        select(elements.url).closest(".cf-cgroup").hidden = false;
        select(elements.custom).closest(".cf-cgroup").hidden = true;
        break;

      case "custom":
        select(elements.url).closest(".cf-cgroup").hidden = true;
        select(elements.custom).closest(".cf-cgroup").hidden = false;
        break;

      default:
        select(elements.url).closest(".cf-cgroup").hidden = true;
        select(elements.custom).closest(".cf-cgroup").hidden = true;
    }
  };

  showOrHide();

  all("[name='" + elements.option + "']").forEach(element => {
    bind(element, {
      change: showOrHide
    });
  });
});
