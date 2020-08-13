import React from "react";

import { t } from "../../modules/i18n";
import SearchModal from "./search_modal";
import { unique } from "../../modules/helpers";

export default class MultiUserSelector extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenUsers: [],
      showModal: false,
    };

    if (this.props.users && this.props.users.length > 0) {
      this.prefetchUsers();
    }

    this.removeUser = this.removeUser.bind(this);
    this.showSearchModal = this.showSearchModal.bind(this);
    this.hideSearchModal = this.hideSearchModal.bind(this);
    this.selectUsers = this.selectUsers.bind(this);
  }

  async prefetchUsers() {
    const formData = new FormData();
    this.props.users.forEach((id) => formData.append("ids[]", id));

    const response = await fetch(`/api/v1/users`, { cedentials: "same-origin", method: "post", body: formData });
    const users = await response.json();
    users.sort((a, b) => a.username.localeCompare(b.username));
    this.setState({ ...this.state, chosenUsers: users });
  }

  removeUser(user) {
    this.setState({ ...this.state, chosenUsers: this.state.chosenUsers.filter((u) => u.user_id != user.user_id) });
  }

  showSearchModal() {
    this.setState({ ...this.state, showModal: true });
  }

  hideSearchModal() {
    this.setState({ ...this.state, showModal: false });
  }

  selectUsers(users) {
    const newUsers = unique([...this.state.chosenUsers, ...users]);
    newUsers.sort((a, b) => a.username.localeCompare(b.username));
    this.setState({ ...this.state, chosenUsers: newUsers, showModal: false });
  }

  render() {
    return (
      <>
        <ul>
          {this.state.chosenUsers.map((user) => (
            <li key={user.user_id}>
              <input type="hidden" name={this.props.fieldName} value={user.user_id} />

              <a className="user-link" href={`/users/${user.user_id}`} title={t(" user") + " " + user.username}>
                <span className="registered-user">
                  <span className="visually-hidden">{t("link to profile of")}</span>
                  <img alt={t(" user") + " " + user.username} className="avatar" src={user.avatar.thumb} />
                  {" " + user.username}
                </span>
              </a>

              <button type="button" className="cf-index-btn" onClick={() => this.removeUser(user)}>
                {t("remove user")}
              </button>
            </li>
          ))}
        </ul>

        <button type="button" className="cf-users-selector-btn" onClick={this.showSearchModal}>
          {t("search user")}
        </button>

        {this.state.showModal && (
          <SearchModal
            selfSelect={this.props.selfSelect}
            single={false}
            show={this.state.showModal}
            close={this.hideSearchModal}
            selectUser={this.selectUsers}
          />
        )}
      </>
    );
  }
}
