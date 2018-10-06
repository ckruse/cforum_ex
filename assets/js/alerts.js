document.addEventListener("DOMContentLoaded", () => {
  const elem = document.querySelector("#alerts-container");
  elem.addEventListener("click", event => {
    if (event.target.matches(".cf-alert button, .cf-alert button span")) {
      event.target.closest(".cf-alert").remove();
    }
  });

  const alerts = elem.querySelectorAll(".cf-alert.cf-success");
  window.setTimeout(() => {
    alerts.forEach(alrt => alrt.remove());
  }, 10000);
});
