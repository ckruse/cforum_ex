import { parse } from "./modules/helpers";
import { t } from "./modules/i18n";

document.addEventListener("DOMContentLoaded", () => {
  const elem = document.querySelector("#alerts-container");
  elem.addEventListener("click", event => {
    if (event.target.matches(".cf-alert button, .cf-alert button span, .cf-alert")) {
      event.target.closest(".cf-alert").remove();
    }
  });

  const alerts = elem.querySelectorAll(".cf-alert.cf-success");
  window.setTimeout(() => {
    alerts.forEach(alrt => alrt.remove());
  }, 10000);
});

export const alert = (type, text) => {
  const node = document.createElement("div");
  node.classList.add("cf-alert", "cf-" + type, "fade", "in");

  const btn = parse(`      <button type="button" class="close" data-dismiss="cf-alert" aria-label="${t("close")}">
        <span aria-hidden="true">&times;</span>
      </button>`);

  node.appendChild(btn);
  node.appendChild(document.createTextNode(text));

  document.querySelector("#alerts-container").appendChild(node);

  if (type == "success") {
    window.setTimeout(() => node.remove(), 10000);
  }
};

export const alertError = text => alert("error", text);
export const alertSuccess = text => alert("success", text);
