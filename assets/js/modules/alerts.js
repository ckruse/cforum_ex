import { t } from "./i18n";
import { parse } from "./helpers";

const SUCCESS_TIMEOUT = 5;
const INFO_TIMEOUT = 10;
const ERROR_TIMEOUT = 0;

const removeAlert = alrt => {
  alrt.classList.add("fade-in-exit", "fade-in-exit-active");
  window.setTimeout(() => alrt.remove(), 300);
};

const alertsContainer = document.querySelector("#alerts-container");
alertsContainer.querySelectorAll(".cf-alert").forEach(alert => {
  let timeout;

  if (alert.classList.contains("cf-error")) {
    timeout = ERROR_TIMEOUT;
  } else if (alert.classList.contains("cf-success")) {
    timeout = SUCCESS_TIMEOUT;
  } else {
    timeout = INFO_TIMEOUT;
  }

  window.setTimeout(() => removeAlert(alert), timeout * 1000);
});

alertsContainer.addEventListener("click", ev => {
  if (ev.target.matches(".cf-alert, .cf-alert *")) {
    const alert = ev.target.closest(".cf-alert");
    removeAlert(alert);
  }
});

export const alert = (type, text, timeout) => {
  const alert = parse(`<div class="cf-${type} cf-alert cf-js-alert fade in" role="alert">
    <button type="button" class="close" aria-label="${t("close")}">
      <span aria-hidden="true">&times;</span>
    </button>

    ${text}
  </div>`);

  const alertChild = alertsContainer.appendChild(alert.firstChild);

  if (timeout) {
    window.setTimeout(() => removeAlert(alertChild), timeout * 1000);
  }
};

export const alertError = (text, timeout = ERROR_TIMEOUT) => alert("error", text, timeout);
export const alertSuccess = (text, timeout = SUCCESS_TIMEOUT) => alert("success", text, timeout);
export const alertInfo = (text, timeout = INFO_TIMEOUT) => alert("info", text, timeout);
