import { ready, bind } from "./modules/events";
import { select, all } from "./modules/selectors";
import { toggleHiddenState } from "./modules/elements";

ready(function() {
  if (document.body.id != "flag-message") {
    return;
  }

  const showOrHide = () => {
    const elem = select("[name='moderation_queue_entry[reason]']:checked");
    const value = elem ? elem.value : null;

    switch (value) {
      case "duplicate":
        select("#moderation_queue_entry_duplicate_url").closest(".cf-cgroup").hidden = false;
        select("#moderation_queue_entry_custom_reason").closest(".cf-cgroup").hidden = true;
        break;

      case "custom":
        select("#moderation_queue_entry_duplicate_url").closest(".cf-cgroup").hidden = true;
        select("#moderation_queue_entry_custom_reason").closest(".cf-cgroup").hidden = false;
        break;

      default:
        select("#moderation_queue_entry_duplicate_url").closest(".cf-cgroup").hidden = true;
        select("#moderation_queue_entry_custom_reason").closest(".cf-cgroup").hidden = true;
    }
  };

  showOrHide();

  all("[name='moderation_queue_entry[reason]']").forEach(element => {
    bind(element, {
      change: showOrHide
    });
  });
});
