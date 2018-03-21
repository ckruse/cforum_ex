import { ready, bind, preventDefault } from "../events";
import { all } from "../selectors";
import { when } from "../logic";
import { parse, create, parentElement, nextElementSibling, setAttribute, clearChildren } from "../elements";
import { pipe } from "../functional";
import { t } from "../i18n";
import { queryString } from "../helpers";

import Modal from "./modal";
import Widget from "./widget";

class UsersSelector {
  constructor(input) {
    //this.input = input;
    this.users = [];
    this.selectedUsers = [];
    this.single = input.dataset.userSelector == "single";

    this.widget = new Widget(this.single, input, () => this.showModal());

    this.modal = new Modal(
      this.single,
      (value, callback) => this.searchUsers(value, callback),
      (uid, callback) => this.selectUser(uid, callback),
      (uid, callback) => this.unselectUser(uid, callback),
      () => this.chooseUsers()
    );
  }

  searchUsers(value, callback) {
    if (!value) {
      this.users = [];
      callback([]);
      return;
    }

    const qs = queryString({ s: value });
    fetch(`/api/v1/users?${qs}`)
      .then(response => response.json())
      .then(json => {
        this.users = json;
        callback(this.users);
      });
  }

  selectUser(uid, callback) {
    const user = this.users.find(u => u.user_id == uid);
    this.selectedUsers.push(user);
    const foundUsers = this.users.filter(user => !this.selectedUsers.includes(user));

    callback(foundUsers, this.selectedUsers);
  }

  unselectUser(uid, callback) {
    this.selectedUsers = this.selectedUsers.filter(u => u.user_id != uid);
    const foundUsers = this.users.filter(user => !this.selectedUsers.includes(user));
    callback(foundUsers, this.selectedUsers);
  }

  chooseUsers(event) {
    this.widget.setUsers(this.selectedUsers);
    this.modal.hide();
  }

  showModal() {
    this.modal.show();
  }
}

function setupUserSelector(inputs) {
  inputs.forEach(input => new UsersSelector(input));
}

ready(function() {
  when(inputs => inputs.length, setupUserSelector, all("[data-user-selector='yes'], [data-user-selector='single']"));
});
