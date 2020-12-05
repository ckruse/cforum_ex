document.addEventListener("DOMContentLoaded", () => {
  if (document.body.id !== "flag-message") {
    return;
  }

  const elements = {
    option: "moderation_queue_entry[reason]",
    url: "#moderation_queue_entry_duplicate_url",
    custom: "#moderation_queue_entry_custom_reason",
  };

  const showOrHide = () => {
    const elem = document.querySelector("[name='" + elements.option + "']:checked");
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

  document.querySelectorAll("[name='" + elements.option + "']").forEach((element) => {
    element.addEventListener("change", showOrHide);
  });
});
