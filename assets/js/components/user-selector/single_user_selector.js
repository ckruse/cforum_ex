import React from "react";

import { t } from "../../modules/i18n";
import SearchModal from "./search_modal";

export default class SingleUserSelector extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenUser: null,
      showModal: false
    };

    if (this.props.userId) {
      fetch(`/api/v1/users/${this.props.userId}`, { credentials: "same-origin" })
        .then(json => json.json())
        .then(json => this.setState({ ...this.state, chosenUser: json }));
    }

    this.showSearchModal = this.showSearchModal.bind(this);
    this.hideSearchModal = this.hideSearchModal.bind(this);
    this.selectUser = this.selectUser.bind(this);
  }

  showSearchModal() {
    this.setState({ ...this.state, showModal: true });
  }

  hideSearchModal() {
    this.setState({ ...this.state, showModal: false });
  }

  selectUser(user) {
    this.setState({ ...this.state, chosenUser: { ...user }, showModal: false });
    this.props.element.value = user.user_id;
  }

  render() {
    const username = this.state.chosenUser ? this.state.chosenUser.username : "";

    return (
      <div>
        <input id={this.props.id} type="text" readOnly={true} value={username} className="cf-users-selector" />
        <button type="button" className="cf-users-selector-btn" onClick={this.showSearchModal}>
          {t("search user")}
        </button>

        <SearchModal
          selfSelect={this.props.selfSelect}
          single={true}
          show={this.state.showModal}
          close={this.hideSearchModal}
          selectUser={this.selectUser}
        />
      </div>
    );
  }
}
