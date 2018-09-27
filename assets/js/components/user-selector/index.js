import { ready } from "../../modules/events";
import { all } from "../../modules/selectors";
import { when } from "../../modules/logic";
import { queryString } from "../../modules/helpers";
import { unique } from "../../modules/lists";

import Modal from "./modal";
import Widget from "./widget";

class UsersSelector {
  constructor(input) {
    //this.input = input;
    this.users = [];
    this.selectedUsers = [];
    this.chosenUsers = [];

    this.single = input.dataset.userSelector == "single";
    this.selfSelectable = "yes";

    if (input.dataset.userSelectorSelf == "no") {
      this.selfSelectable = "no";
    }

    if (this.single && input.value) {
      this.setInitialValue(input.value);
    } else if (!this.single) {
      this.fieldName = input.dataset.fieldName;
      this.setInitialValuesFromList(input);
    }

    this.widget = new Widget(
      this.single,
      input,
      () => this.showModal(),
      (user_id, cb) => this.unchooseUser(user_id, cb),
      this.fieldName
    );

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
    fetch(`/api/v1/users?${qs}&self=${this.selfSelectable}`, { credentials: "same-origin" })
      .then(response => response.json())
      .then(json => {
        this.users = json;
        callback(this.users);
      });
  }

  selectUser(uid, callback) {
    const user = this.users.find(u => u.user_id == uid);
    if (this.single) {
      this.selectedUsers = [user];
    } else {
      this.selectedUsers.push(user);
    }

    const foundUsers = this.users.filter(user => !this.selectedUsers.includes(user));

    callback(foundUsers, this.selectedUsers);
  }

  unselectUser(uid, callback) {
    this.selectedUsers = this.selectedUsers.filter(u => u.user_id != uid);
    const foundUsers = this.users.filter(user => !this.selectedUsers.includes(user));
    callback(foundUsers, this.selectedUsers);
  }

  chooseUsers(event) {
    if (this.single) {
      this.chosenUsers = [...this.selectedUsers];
    } else {
      this.chosenUsers = [...this.chosenUsers, ...this.selectedUsers];
    }

    this.chosenUsers = unique(this.chosenUsers, (ary, searchedElem) => {
      return ary.findIndex(elem => searchedElem.user_id == elem.user_id);
    });

    this.widget.setUsers(this.chosenUsers);
    this.modal.hide();
  }

  unchooseUser(user_id, callback) {
    this.chosenUsers = this.chosenUsers.filter(user => user.user_id != user_id);
    callback(this.chosenUsers);
  }

  setInitialValue(id) {
    fetch(`/api/v1/users/${id}`, { credentials: "same-origin" })
      .then(response => response.json())
      .then(json => {
        this.chosenUsers = [json];
        this.widget.setUsers([json]);
      });
  }

  setInitialValuesFromList(list) {
    const formData = new FormData();
    const ids = all("input[type=hidden]", list);
    ids.forEach(el => formData.append("ids[]", el.value));

    if (!ids) {
      return;
    }

    fetch(`/api/v1/users`, { cedentials: "same-origin", method: "post", body: formData })
      .then(response => response.json())
      .then(json => {
        this.chosenUsers = json;
        this.widget.setUsers(json);
      });
  }

  showModal() {
    this.selectedUsers = [];
    this.modal.show(this.users);
  }
}

function setupUserSelector(inputs) {
  inputs.forEach(input => new UsersSelector(input));
}

ready(function() {
  when(inputs => inputs.length, setupUserSelector, all("[data-user-selector='yes'], [data-user-selector='single']"));
});
