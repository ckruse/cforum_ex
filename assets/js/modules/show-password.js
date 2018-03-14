import { ready, bind, preventDefault } from "./events.js";
import { all } from "./selectors.js";
import { when } from "./logic.js";
import { create, nextElementSibling, parentElement, getAttribute, setAttribute, focus } from "./elements.js";
import { compose, pipe } from "./functional.js";
import { equal } from "./predicates.js";

function toggleInputType(input) {
  if (getAttribute("type", input) == "password") {
    setAttribute("type", "text", input);
  } else {
    setAttribute("type", "password", input);
  }

  focus(input);
}

function setupShowPassword(passwords) {
  passwords.forEach(input => {
    const text = input.dataset.showPassword || "show password";
    const anchor = create("button");

    anchor.textContent = text;
    anchor.classList.add("cf-show-password");
    setAttribute("type", "button", anchor);

    bind(anchor, {
      click: pipe(preventDefault, () => input, toggleInputType)
    });

    parentElement(input).insertBefore(anchor, nextElementSibling(input));
  });
}

ready(function() {
  when(passwords => passwords.length, setupShowPassword, all("[data-show-password]"));
});
