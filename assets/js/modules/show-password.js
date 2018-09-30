import { t } from "./i18n.js";

function toggleInputType(input, button) {
  if (input.getAttribute("type") == "password") {
    input.setAttribute("type", "text");
    button.innerText = t("hide password");
  } else {
    input.setAttribute("type", "password");
    button.innerText = t("show password");
  }

  input.focus();
}

function setupShowPassword(input) {
  const text = t("show password");
  const anchor = document.createElement("button");

  anchor.textContent = text;
  anchor.classList.add("cf-show-password");
  anchor.setAttribute("type", "button");

  anchor.addEventListener("click", ev => {
    ev.preventDefault();
    toggleInputType(input, ev.target);
  });

  input.parentNode.insertBefore(anchor, input.nextSibling);
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-show-password]").forEach(setupShowPassword);
});
