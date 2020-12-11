import React, { useRef, useState } from "react";
import Modal from "react-modal";

import { t } from "../../modules/i18n";
import { queryString } from "../../modules/helpers";

const SEARCH_TIMEOUT = 500;

export default function SearchModal(props) {
  const [value, setValue] = useState("");
  const [foundUsers, setFoundUsers] = useState([]);
  const [selectedUsers, setSelectedUsers] = useState([]);

  const timer = useRef();

  async function searchUsers() {
    const qs = queryString({ s: value });
    const response = await fetch(`/api/v1/users?${qs}&self=${props.selfSelect ? "yes" : "no"}`, {
      credentials: "same-origin",
    });
    const json = await response.json();
    json.sort((a, b) => a.username.localeCompare(b.username));
    setFoundUsers(json);
  }

  function handleKeyPressed(event) {
    if (timer.current) {
      window.clearTimeout(timer.current);
    }

    setValue(event.target.value);
    timer.current = window.setTimeout(() => searchUsers(), SEARCH_TIMEOUT);
  }

  function chooseUser(user) {
    if (props.single) {
      props.selectUser(user);
    } else {
      const newUsers = [...selectedUsers, user];
      newUsers.sort((a, b) => a.username.localeCompare(b.username));
      setSelectedUsers(newUsers);
    }
  }

  function unchooseUser(user) {
    setSelectedUsers(selectedUsers.filter((u) => u.user_id !== user.user_id));
  }

  function selectUsers() {
    props.selectUser(selectedUsers);
  }

  function clearResults() {
    setFoundUsers([]);
    setSelectedUsers([]);
  }

  function renderFoundUsers() {
    if (foundUsers.length === 0) {
      return (
        <li className="no-data" key="no-user-found">
          {t("none found")}
        </li>
      );
    }

    return foundUsers.map((user) => (
      <li key={user.user_id}>
        <span className="author">
          <img src={user.avatar.thumb} alt="" className="avatar" /> {user.username}
        </span>
        <button type="button" className="cf-primary-index-btn" onClick={() => chooseUser(user)}>
          {t("select user")}
        </button>
      </li>
    ));
  }

  function renderSelectedUsers() {
    return (
      <>
        <h2>{t("selected users")}</h2>
        <ul className="users-selector-selected-users-list" aria-live="assertive">
          {selectedUsers.length === 0 && (
            <li className="no-data" key="no-data">
              {t("none selected")}
            </li>
          )}
          {selectedUsers.map((user) => (
            <li key={user.user_id}>
              <span className="author">
                <img src={user.avatar.thumb} alt="" className="avatar" /> {user.username}
              </span>
              <button type="button" className="cf-primary-index-btn" onClick={() => unchooseUser(user)}>
                {t("unselect user")}
              </button>
            </li>
          ))}
        </ul>
      </>
    );
  }

  return (
    <Modal
      isOpen={props.show}
      appElement={document.body}
      contentLabel={t("Search user")}
      onRequestClose={props.close}
      onAfterOpen={clearResults}
      closeTimeoutMS={300}
    >
      <div className="cf-form cf-user-selector-modal">
        <div className="cf-cgroup">
          <label htmlFor="users-selector-search-input">{t("username")}</label>
          <input type="text" id="users-selector-search-input" onInput={handleKeyPressed} autoFocus />
        </div>

        <h2>{t("found users")}</h2>
        <ul className="users-selector-found-users-list" aria-live="assertive">
          {renderFoundUsers()}
        </ul>

        {!props.single && renderSelectedUsers()}

        <p>
          {!props.single && (
            <button type="button" className="cf-primary-btn" onClick={selectUsers}>
              {t("choose selected users")}
            </button>
          )}
          <button type="button" className="cf-btn" onClick={props.close}>
            {t("cancel")}
          </button>
        </p>
      </div>
    </Modal>
  );
}
