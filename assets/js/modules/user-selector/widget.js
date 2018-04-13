import { ready, bind, preventDefault } from "../events";
import { parse, create, parentElement, nextElementSibling, setAttribute, clearChildren } from "../elements";
import { select } from "../selectors";
import { pipe } from "../functional";
import { t } from "../i18n";

export default class Widget {
  constructor(single, input, showModalCallback, removeUserCallback, fieldName) {
    this.single = single;
    this.input = input;
    this.showModalCallback = showModalCallback;
    this.removeUserCallback = removeUserCallback;
    this.fieldName = fieldName || "";

    if (this.single) {
      this.replaced = this.setupSingleSelector();
    } else {
      this.setupMultiSelector();
    }
  }

  setupSelectorButton() {
    const btn = create("button");
    setAttribute("type", "button", btn);
    btn.classList.add("cf-users-selector-btn");
    btn.textContent = t("search user");

    bind(btn, {
      click: pipe(preventDefault, this.showModalCallback)
    });

    return btn;
  }

  setupSingleSelector() {
    const replaced = create("input");
    const btn = this.setupSelectorButton();

    setAttribute("type", "hidden", this.input);

    setAttribute("type", "text", replaced);
    setAttribute("disabled", "disabled", replaced);
    replaced.classList.add("cf-users-selector");

    parentElement(this.input).insertBefore(btn, nextElementSibling(this.input));
    parentElement(this.input).insertBefore(replaced, btn);

    return replaced;
  }

  setupMultiSelector() {
    const btn = this.setupSelectorButton();
    parentElement(this.input).insertBefore(btn, this.input.nextSibling);
  }

  userRow(user) {
    const li = parse(`<li>
                  <input type="hidden" name="${this.fieldName}" value="${user.user_id}">
                  <a class="user-link" href="/users/${user.user_id}" title="${t("user") + " " + user.username}">
                    <span class="registered-user">
                      <span class="visually-hidden">${t("link to profile of")}</span>
                      <img alt="${t("user") + " " + user.username}" class="avatar" src="${user.avatar.thumb}">
                      ${user.username}
                    </span>
                  </a>

                  <button type="button" class="cf-index-btn">${t("remove user")}</button>
                </li>`);

    const btn = select("button", li);
    bind(btn, {
      click: () => {
        this.removeUserCallback(user.user_id, users => this.setUsers(users));
      }
    });

    return li;
  }

  setUsers(users) {
    if (this.single) {
      this.replaced.value = users[0].username;
      this.input.value = users[0].user_id;
    } else {
      const sortedUsers = users.sort((a, b) => a.username.localeCompare(b.username));
      const html = sortedUsers.map(user => this.userRow(user));

      clearChildren(this.input);
      html.forEach(el => this.input.appendChild(el));
    }
  }
}
