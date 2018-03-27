import { ready, bind, preventDefault } from "./events.js";
import { all } from "./selectors.js";
import { when } from "./logic.js";
import { create, nextElementSibling, parentElement, getAttribute, setAttribute, focus } from "./elements.js";
import { compose, pipe } from "./functional.js";
import { equal } from "./predicates.js";
import { t } from "./i18n.js";

function toggleInputType(input, button) {
  if (getAttribute("type", input) == "password") {
    setAttribute("type", "text", input);
    button.innerText = t("hide password");
  } else {
    setAttribute("type", "password", input);
    button.innerText = t("show password");
  }

  focus(input);
}

function setupShowPassword(passwords) {
  passwords.forEach(input => {
    const text = t("show password");
    const anchor = create("button");

    anchor.textContent = text;
    anchor.classList.add("cf-show-password");
    setAttribute("type", "button", anchor);

    bind(anchor, {
      click: pipe(preventDefault, event => toggleInputType(input, event.target))
    });

    parentElement(input).insertBefore(anchor, nextElementSibling(input));
  });
}

ready(function() {
  when(passwords => passwords.length, setupShowPassword, all("[data-show-password]"));
});
