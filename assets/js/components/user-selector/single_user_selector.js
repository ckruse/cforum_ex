import React from "react";

import { t } from "../../modules/i18n";
import SearchModal from "./search_modal";

export default class SingleUserSelector extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenUser: null,
      showModal: false,
    };

    if (this.props.userId) {
      fetch(`/api/v1/users/${this.props.userId}`, { credentials: "same-origin" })
        .then((json) => json.json())
        .then((json) => this.setState({ chosenUser: json }));
    }

    this.showSearchModal = this.showSearchModal.bind(this);
    this.hideSearchModal = this.hideSearchModal.bind(this);
    this.selectUser = this.selectUser.bind(this);
    this.clear = this.clear.bind(this);
  }

  showSearchModal() {
    this.setState({ showModal: true });
  }

  hideSearchModal() {
    this.setState({ showModal: false });
  }

  selectUser(user) {
    this.setState({ chosenUser: { ...user }, showModal: false });
    this.props.element.value = user.user_id;

    const event = new Event("change");
    this.props.element.dispatchEvent(event);
  }

  clear() {
    this.setState({ chosenUser: null });
    this.props.element.value = "";
    const event = new Event("change");
    this.props.element.dispatchEvent(event);
  }

  render() {
    const user = this.state.chosenUser;

    return (
      <>
        <div id={this.props.id} className="cf-users-selector">
          {user && (
            <span className="author">
              <img src={user.avatar.thumb} alt="" className="avatar" /> {user.username}
            </span>
          )}
          {!user && <em>{t("no user chosen")}</em>}
        </div>
        <button type="button" className="cf-users-selector-btn" onClick={this.showSearchModal}>
          {t("search user")}
        </button>
        <button type="button" className="cf-users-selector-btn" onClick={this.clear}>
          {t("clear")}
        </button>
        {this.state.showModal && (
          <SearchModal
            selfSelect={this.props.selfSelect}
            single={true}
            show={this.state.showModal}
            close={this.hideSearchModal}
            selectUser={this.selectUser}
          />
        )}
      </>
    );
  }
}
