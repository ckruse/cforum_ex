import React from "react";
import { render } from "react-dom";
import { ErrorBoundary } from "@appsignal/react";

import { t } from "../../modules/i18n";
import Badge from "./badge";
import NewBadgeModal from "./new_badge_modal";
import appsignal, { FallbackComponent } from "../../appsignal";

class BadgeManager extends React.Component {
  state = { user: null, showModal: false, lastAdded: 0 };

  async componentDidMount() {
    const rsp = await fetch(`/api/v1/users/${this.props.userId}`, { credentials: "same-origin" });
    const json = await rsp.json();
    this.setState({ user: json });
  }

  changeActive = (badge) => {
    const newBadges = [...this.state.user.badges];
    const index = newBadges.findIndex((b) => b.badge_user_id === badge.badge_user_id);
    newBadges[index].active = !newBadges[index].active;

    this.setState({ user: { ...this.state.user, badges: newBadges } });
  };

  deleteBadge = (badge) => {
    const newBadges = this.state.user.badges.filter((b) => b.badge_user_id !== badge.badge_user_id);
    this.setState({ user: { ...this.state.user, badges: newBadges } });
  };

  showNewBadgeModal = () => {
    this.setState({ showModal: true });
  };

  closeModal = () => {
    this.setState({ showModal: false });
  };

  selectBadge = (badge) => {
    this.setState({
      showModal: false,
      lastAdded: this.state.lastAdded + 1,
      user: {
        ...this.state.user,
        badges: [
          ...this.state.user.badges,
          { ...badge, active: true, badge_user_id: "bu_" + this.state.lastAdded + 1 },
        ],
      },
    });
  };

  render() {
    const badges = (this.state.user && this.state.user.badges) || [];

    return (
      <ErrorBoundary instance={appsignal} fallback={(error) => <FallbackComponent />}>
        <fieldset>
          <legend>{t("badge management")}</legend>

          <NewBadgeModal show={this.state.showModal} selectBadge={this.selectBadge} onClose={this.closeModal} />

          <p>
            <button type="button" onClick={this.showNewBadgeModal} className="cf-btn">
              {t("add new badge")}
            </button>
          </p>

          {badges.map((b, idx) => (
            <Badge
              badge={b}
              key={b.badge_user_id}
              changeActive={this.changeActive}
              deleteBadge={this.deleteBadge}
              index={idx}
              userId={this.state.user.user_id}
            />
          ))}
        </fieldset>
      </ErrorBoundary>
    );
  }
}

const setupBadgeManager = (element) => render(<BadgeManager userId={element.dataset.userId} />, element);

export default setupBadgeManager;
