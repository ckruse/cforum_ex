import React from "react";
import Modal from "react-modal";

import { t } from "../../modules/i18n";
import { queryString } from "../../modules/helpers";

const SEARCH_TIMEOUT = 500;

export default class SearchModal extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: "", foundUsers: [], selectedUsers: [] };

    this.handleKeyPressed = this.handleKeyPressed.bind(this);
    this.selectUsers = this.selectUsers.bind(this);
    this.clearResults = this.clearResults.bind(this);
  }

  handleKeyPressed(event) {
    if (this.timer != null) {
      window.clearTimeout(this.timer);
    }

    this.setState({ ...this.state, value: event.target.value });

    this.timer = window.setTimeout(() => this.searchUsers(), SEARCH_TIMEOUT);
  }

  searchUsers() {
    const qs = queryString({ s: this.state.value });
    fetch(`/api/v1/users?${qs}&self=${this.props.selfSelect ? "yes" : "no"}`, { credentials: "same-origin" })
      .then((response) => response.json())
      .then((json) => {
        json.sort((a, b) => a.username.localeCompare(b.username));
        this.setState({ ...this.state, foundUsers: json });
      });
  }

  chooseUser(user) {
    if (this.props.single) {
      this.props.selectUser(user);
    } else {
      const newUsers = [...this.state.selectedUsers, user];
      newUsers.sort((a, b) => a.username.localeCompare(b.username));
      this.setState({ ...this.state, selectedUsers: newUsers });
    }
  }

  unchooseUser(user) {
    this.setState({ ...this.state, selectedUsers: this.state.selectedUsers.filter((u) => u.user_id !== user.user_id) });
  }

  selectUsers() {
    this.props.selectUser(this.state.selectedUsers);
  }

  clearResults() {
    this.setState({ ...this.state, foundUsers: [], selectedUsers: [] });
  }

  renderFoundUsers() {
    if (this.state.foundUsers.length === 0) {
      return (
        <li className="no-data" key="no-user-found">
          {t("none found")}
        </li>
      );
    } else {
      return this.state.foundUsers.map((user) => (
        <li key={user.user_id}>
          <span className="author">
            <img src={user.avatar.thumb} alt="" className="avatar" /> {user.username}
          </span>
          <button type="button" className="cf-primary-index-btn" onClick={() => this.chooseUser(user)}>
            {t("select user")}
          </button>
        </li>
      ));
    }
  }

  renderSelectedUsers() {
    return (
      <>
        <h2>{t("selected users")}</h2>
        <ul className="users-selector-selected-users-list" aria-live="assertive">
          {this.state.selectedUsers.length === 0 && (
            <li className="no-data" key="no-data">
              {t("none selected")}
            </li>
          )}
          {this.state.selectedUsers.map((user) => (
            <li key={user.user_id}>
              <span className="author">
                <img src={user.avatar.thumb} alt="" className="avatar" /> {user.username}
              </span>
              <button type="button" className="cf-primary-index-btn" onClick={() => this.unchooseUser(user)}>
                {t("unselect user")}
              </button>
            </li>
          ))}
        </ul>
      </>
    );
  }

  render() {
    return (
      <Modal
        isOpen={this.props.show}
        appElement={document.body}
        contentLabel={t("Search user")}
        onRequestClose={this.props.close}
        onAfterOpen={this.clearResults}
        closeTimeoutMS={300}
      >
        <div className="cf-form cf-user-selector-modal">
          <div className="cf-cgroup">
            <label htmlFor="users-selector-search-input">{t("username")}</label>
            <input type="text" id="users-selector-search-input" onInput={this.handleKeyPressed} autoFocus />
          </div>

          <h2>{t("found users")}</h2>
          <ul className="users-selector-found-users-list" aria-live="assertive">
            {this.renderFoundUsers()}
          </ul>

          {!this.props.single && this.renderSelectedUsers()}

          <p>
            {!this.props.single && (
              <button type="button" className="cf-primary-btn" onClick={this.selectUsers}>
                {t("choose selected users")}
              </button>
            )}{" "}
            <button type="button" className="cf-btn" onClick={this.props.close}>
              {t("cancel")}
            </button>
          </p>
        </div>
      </Modal>
    );
  }
}
