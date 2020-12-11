import React, { useEffect, useState } from "react";

import { t } from "../../modules/i18n";
import SearchModal from "./search_modal";
import { unique } from "../../modules/helpers";

export default function MultiUserSelector({ users, fieldName, selfSelect }) {
  const [chosenUsers, setChosenUsers] = useState([]);
  const [showModal, setShowModal] = useState(false);

  async function prefetchUsers() {
    const formData = new FormData();
    users.forEach((id) => formData.append("ids[]", id));

    const response = await fetch(`/api/v1/users`, { cedentials: "same-origin", method: "post", body: formData });
    const fetchedUsers = await response.json();
    fetchedUsers.sort((a, b) => a.username.localeCompare(b.username));
    setChosenUsers(fetchedUsers);
  }

  useEffect(
    () => {
      if (users && users.length > 0) {
        prefetchUsers();
      }
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [users]
  );

  function removeUser(user) {
    setChosenUsers(chosenUsers.filter((u) => u.user_id !== user.user_id));
  }

  function showSearchModal() {
    setShowModal(true);
  }

  function hideSearchModal() {
    setShowModal(false);
  }

  function selectUsers(users) {
    const newUsers = unique([...chosenUsers, ...users]);
    newUsers.sort((a, b) => a.username.localeCompare(b.username));
    setChosenUsers(newUsers);
    setShowModal(false);
  }

  return (
    <>
      <ul>
        {chosenUsers.map((user) => (
          <li key={user.user_id}>
            <input type="hidden" name={fieldName} value={user.user_id} />

            <a className="user-link" href={`/users/${user.user_id}`} title={t(" user") + " " + user.username}>
              <span className="registered-user">
                <span className="visually-hidden">{t("link to profile of")}</span>
                <img alt={t(" user") + " " + user.username} className="avatar" src={user.avatar.thumb} />
                {" " + user.username}
              </span>
            </a>

            <button type="button" className="cf-index-btn" onClick={() => removeUser(user)}>
              {t("remove user")}
            </button>
          </li>
        ))}
      </ul>

      <button type="button" className="cf-users-selector-btn" onClick={showSearchModal}>
        {t("search user")}
      </button>

      {showModal && (
        <SearchModal
          selfSelect={selfSelect}
          single={false}
          show={showModal}
          close={hideSearchModal}
          selectUser={selectUsers}
        />
      )}
    </>
  );
}
