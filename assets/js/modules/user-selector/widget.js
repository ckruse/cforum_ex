import { ready, bind, preventDefault } from "../events";
import { create, parentElement, nextElementSibling, setAttribute } from "../elements";
import { pipe } from "../functional";
import { t } from "../i18n";

export default class Widget {
  constructor(single, input, showModalCallback) {
    this.single = single;
    this.input = input;
    this.showModalCallback = showModalCallback;

    if (this.single) {
      this.replaced = this.setupSingleSelector();
    }
  }

  setupSingleSelector() {
    const replaced = create("input");
    const btn = create("button");

    setAttribute("type", "hidden", this.input);

    setAttribute("type", "text", replaced);
    setAttribute("disabled", "disabled", replaced);
    replaced.classList.add("cf-users-selector");

    setAttribute("type", "button", btn);
    btn.classList.add("cf-users-selector-btn");
    btn.textContent = t("search user");

    bind(btn, {
      click: pipe(preventDefault, this.showModalCallback)
    });

    parentElement(this.input).insertBefore(btn, nextElementSibling(this.input));
    parentElement(this.input).insertBefore(replaced, btn);

    return replaced;
  }

  setUsers(users) {
    if (this.single) {
      this.replaced.value = users[0].username;
      this.input.value = users[0].user_id;
    } else {
      // TODO implement code path: show a list of users
    }
  }
}
