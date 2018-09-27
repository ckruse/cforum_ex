import { bind } from "../../modules/events";
import { createModal } from "../../modules/modal";
import { parse, clearChildren } from "../../modules/elements";
import { t } from "../../modules/i18n";

const SEARCH_TIMEOUT = 500;

export default class Modal {
  constructor(single, searchCallback, selectionCallback, unselectionCallback, chooseCallback) {
    this.single = single;
    this.foundUserList = null;
    this.selectedUserList = null;

    this.modal = this.createSelectorModal();

    this.searchCallback = searchCallback;
    this.selectionCallback = selectionCallback;
    this.unselectionCallback = unselectionCallback;
    this.chooseCallback = chooseCallback;
  }

  searchUsers(event) {
    this.searchCallback(event.target.value, users => this.renderFoundUsers(users));
  }

  selectedUserHtml() {
    if (this.single) {
      return "";
    }

    return `
      <h2>${t("selected users")}</h2>
      <ul class="users-selector-selected-users-list" aria-live="assertive">
        <li class="no-data">${t("none selected")}</li>
      </ul>
    `;
  }

  createSelectorModal() {
    const content = parse(`
      <div class="cf-form cf-user-selector-modal">
        <div class="cf-cgroup">
          <label for="users-selector-search-input">${t("username")}</label>
          <input type="text" id="users-selector-search-input">
        </div>

        <h2>${t("found users")}</h2>
        <ul class="users-selector-found-users-list" aria-live="assertive">
          <li class="no-data">${t("none found")}</li>
        </ul>

        ${this.selectedUserHtml()}

        <p>
          <button type="button" class="cf-primary-btn">${t("choose selected users")}</button>
          <button type="button" data-a11y-dialog-hide class="cf-btn">${t("cancel")}</button>
        </p>
      </div>`);

    let timer = null;
    const searchField = content.querySelector("#users-selector-search-input");
    const okBtn = content.querySelector(".cf-primary-btn");

    this.foundUserList = content.querySelector(".users-selector-found-users-list");
    this.selectedUserList = content.querySelector(".users-selector-selected-users-list");

    bind(searchField, {
      input: event => {
        if (timer != null) {
          window.clearTimeout(timer);
        }

        timer = window.setTimeout(() => this.searchUsers(event), SEARCH_TIMEOUT);
      }
    });

    bind(this.foundUserList, { click: event => this.selectUser(event) });
    bind(okBtn, { click: event => this.chooseUsers(event) });

    if (!this.single) {
      bind(this.selectedUserList, { click: event => this.unselectUser(event) });
    }

    return createModal(t("Search user"), content);
  }

  renderFoundUsers(users) {
    if (users.length == 0) {
      this.foundUserList.innerHTML = `<li class="no-data">${t("none found")}</li>`;
      return;
    }

    clearChildren(this.foundUserList);

    const fragment = document.createDocumentFragment();
    const html = users
      .map(user => {
        const elem = parse(`<li>
          <span class="author"><img src="${user.avatar.thumb}" class="avatar"> ${user.username}</span>
          <button type="button" class="cf-primary-index-btn">${t("select user")}</button>
        </li>`);

        elem.firstChild.dataset.userId = user.user_id;
        return elem.firstChild;
      })
      .forEach(elem => fragment.appendChild(elem));

    this.foundUserList.appendChild(fragment);
  }

  renderSelectedUsers(selectedUsers) {
    if (selectedUsers.length == 0) {
      this.selectedUserList.innerHTML = `<li class="no-data">${t("none selected")}</li>`;
      return;
    }

    clearChildren(this.selectedUserList);
    const fragment = document.createDocumentFragment();
    const html = selectedUsers
      .map(user => {
        const elem = parse(`<li>
        <span class="author"><img src="${user.avatar.thumb}" class="avatar"> ${user.username}</span>
        <button type="button" class="cf-destructive-index-btn">${t("unselect user")}</button>
      </li>`);

        elem.firstChild.dataset.userId = user.user_id;
        return elem.firstChild;
      })
      .forEach(elem => fragment.appendChild(elem));

    this.selectedUserList.appendChild(fragment);
  }

  selectUser(event) {
    if (event.target.nodeName != "BUTTON") {
      return;
    }

    const li = event.target.closest("li");
    const uid = li.dataset.userId;

    this.selectionCallback(uid, (foundUsers, selectedUsers) => {
      if (this.single) {
        this.chooseUsers();
      } else {
        this.renderFoundUsers(foundUsers);
        this.renderSelectedUsers(selectedUsers);
      }
    });
  }

  unselectUser(event) {
    if (event.target.nodeName != "BUTTON") {
      return;
    }

    const li = event.target.closest("li");
    const uid = li.dataset.userId;

    this.unselectionCallback(uid, (foundUsers, selectedUsers) => {
      this.renderFoundUsers(foundUsers);
      this.renderSelectedUsers(selectedUsers);
    });
  }

  chooseUsers() {
    this.chooseCallback();
  }

  show(foundUsers) {
    if (!foundUsers) {
      foundUsers = [];
    }

    this.renderFoundUsers(foundUsers);
    if (!this.single) {
      this.renderSelectedUsers([]);
    }
    this.modal.show();
  }

  hide() {
    this.modal.hide();
  }
}
