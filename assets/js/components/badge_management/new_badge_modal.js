import React from "react";
import Modal from "react-modal";

import { t } from "../../modules/i18n";
import FoundBadge from "./found_badge";

const SEARCH_TIMEOUT = 500;

class NewBadgeModal extends React.Component {
  state = {
    value: "",
    badges: [],
    foundBadges: [],
  };

  componentDidMount() {
    fetch("/api/v1/badges")
      .then((rsp) => rsp.json())
      .then((json) => this.setState({ badges: json }));
  }

  handleKeyPressed = (event) => {
    if (this.timer != null) {
      window.clearTimeout(this.timer);
    }

    this.setState({ value: event.target.value });
    this.timer = window.setTimeout(() => this.searchBadges(), SEARCH_TIMEOUT);
  };

  searchBadges = () => {
    const v = this.state.value.toLowerCase();
    const found = this.state.badges.filter((b) => b.name.toLowerCase().indexOf(v) !== -1);
    this.setState({ foundBadges: found });
  };

  render() {
    return (
      <Modal
        isOpen={this.props.show}
        appElement={document.body}
        contentLabel={t("Search badge")}
        onRequestClose={this.props.onClose}
        closeTimeoutMS={300}
      >
        <div className="cf-form cf-new-badge-modal">
          <div className="cf-cgroup">
            <label htmlFor="new-badge-modal-search-input">{t("badge name")}</label>
            <input type="text" id="new-badge-modal-search-input" onInput={this.handleKeyPressed} />
          </div>
        </div>

        <h3>{t("found badges")}</h3>
        {this.state.foundBadges.length === 0 && <p>{t("no badges found")}</p>}

        <ul>
          {this.state.foundBadges.map((b) => (
            <FoundBadge key={b.badge_id} badge={b} selectBadge={this.props.selectBadge} />
          ))}
        </ul>

        <p>
          <button type="button" className="cf-btn" onClick={this.props.onClose}>
            {t("cancel")}
          </button>
        </p>
      </Modal>
    );
  }
}

export default NewBadgeModal;
