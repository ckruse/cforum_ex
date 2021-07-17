if (document.body.dataset.controller === "Events.AttendeeController") {
  const el = document.createElement("input");
  el.type = "date";
  const supportsDate = el.type === "date";

  el.type = "time";
  const supportsTime = el.type === "time";

  if (supportsDate && supportsTime) {
    document.querySelectorAll(".datetime.help").forEach((el) => {
      el.remove();
    });
  }
}
