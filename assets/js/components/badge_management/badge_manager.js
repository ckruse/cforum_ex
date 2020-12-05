import React, { useEffect, useState } from "react";
import { render } from "react-dom";
import { ErrorBoundary } from "@appsignal/react";

import { t } from "../../modules/i18n";
import Badge from "./badge";
import NewBadgeModal from "./new_badge_modal";
import appsignal, { FallbackComponent } from "../../appsignal";

function BadgeManager({ userId }) {
  const [user, setUser] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [lastAdded, setLastAdded] = useState(0);

  useEffect(() => {
    (async () => {
      const rsp = await fetch(`/api/v1/users/${userId}`, { credentials: "same-origin" });
      const json = await rsp.json();
      setUser(json);
    })();
  }, [userId]);

  function changeActive(badge) {
    const badges = [...user.badges];
    const index = badges.findIndex((b) => b.badge_user_id === badge.badge_user_id);
    badges[index].active = !badges[index].active;

    setUser({ ...user, badges });
  }

  function deleteBadge(badge) {
    const badges = user.badges.filter((b) => b.badge_user_id !== badge.badge_user_id);
    setUser({ ...user, badges });
  }

  function showNewBadgeModal() {
    setShowModal(true);
  }

  function closeModal() {
    setShowModal(false);
  }

  function selectBadge(badge) {
    setShowModal(false);
    setLastAdded(lastAdded + 1);
    setUser({ ...user, badges: [...user.badges, { ...badge, active: true, badge_user_id: "bu_" + lastAdded + 1 }] });
  }

  const badges = user?.badges || [];

  return (
    <ErrorBoundary instance={appsignal} fallback={(error) => <FallbackComponent />}>
      <fieldset>
        <legend>{t("badge management")}</legend>

        <NewBadgeModal show={showModal} selectBadge={selectBadge} onClose={closeModal} />

        <p>
          <button type="button" onClick={showNewBadgeModal} className="cf-btn">
            {t("add new badge")}
          </button>
        </p>

        {badges.map((b, idx) => (
          <Badge
            badge={b}
            key={b.badge_user_id}
            changeActive={changeActive}
            deleteBadge={deleteBadge}
            index={idx}
            userId={user.user_id}
          />
        ))}
      </fieldset>
    </ErrorBoundary>
  );
}

const setupBadgeManager = (element) => render(<BadgeManager userId={element.dataset.userId} />, element);

export default setupBadgeManager;
