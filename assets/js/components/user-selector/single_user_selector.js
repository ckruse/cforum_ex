import React, { useEffect, useState } from "react";

import { t } from "../../modules/i18n";
import SearchModal from "./search_modal";

export default function SingleUserSelector({ userId, element, id, selfSelect }) {
  const [chosenUser, setChosenUser] = useState(null);
  const [showModal, setShowModal] = useState(false);

  async function fetchUser(userId) {
    const data = await fetch(`/api/v1/users/${userId}`, { credentials: "same-origin" });
    const json = await data.json();
    setChosenUser(json);
  }

  useEffect(() => {
    if (userId) {
      fetchUser(userId);
    }
  });

  function showSearchModal() {
    setShowModal(true);
  }

  function hideSearchModal() {
    setShowModal(false);
  }

  function selectUser(user) {
    setChosenUser(user);
    setShowModal(false);
    element.value = user.user_id;

    const event = new Event("change");
    element.dispatchEvent(event);
  }

  function clear() {
    setChosenUser(null);
    element.value = "";
    const event = new Event("change");
    element.dispatchEvent(event);
  }

  return (
    <>
      <div id={id} className="cf-users-selector">
        {chosenUser && (
          <span className="author">
            <img src={chosenUser.avatar.thumb} alt="" className="avatar" /> {chosenUser.username}
          </span>
        )}
        {!chosenUser && <em>{t("no user chosen")}</em>}
      </div>

      <button type="button" className="cf-users-selector-btn" onClick={showSearchModal}>
        {t("search user")}
      </button>

      <button type="button" className="cf-users-selector-btn" onClick={clear}>
        {t("clear")}
      </button>

      {showModal && (
        <SearchModal
          selfSelect={selfSelect}
          single={true}
          show={showModal}
          close={hideSearchModal}
          selectUser={selectUser}
        />
      )}
    </>
  );
}
