document.addEventListener("DOMContentLoaded", () => {
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
        document.querySelector(elements.url).closest(".cf-cgroup").hidden = false;
        document.querySelector(elements.custom).closest(".cf-cgroup").hidden = true;
        break;

      case "custom":
        document.querySelector(elements.url).closest(".cf-cgroup").hidden = true;
        document.querySelector(elements.custom).closest(".cf-cgroup").hidden = false;
        break;

      default:
        document.querySelector(elements.url).closest(".cf-cgroup").hidden = true;
        document.querySelector(elements.custom).closest(".cf-cgroup").hidden = true;
    }
  };

  showOrHide();

  document.querySelectorAll("[name='" + elements.option + "']").forEach(element => {
    element.addEventListener("change", showOrHide);
  });
});
