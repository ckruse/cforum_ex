import React, { useEffect, useRef, useState } from "react";
import Modal from "react-modal";

import { t } from "../../modules/i18n";
import FoundBadge from "./found_badge";

const SEARCH_TIMEOUT = 500;

export default function NewBadgeModal({ show, onClose, selectBadge }) {
  const [value, setValue] = useState("");
  const [badges, setBadges] = useState([]);
  const [foundBadges, setFoundBadges] = useState([]);
  const timer = useRef();

  useEffect(() => {
    (async () => {
      const rsp = await fetch("/api/v1/badges");
      const json = await rsp.json();
      setBadges(json);
      setFoundBadges(json);
    })();
  }, []);

  function handleKeyPressed(event) {
    if (timer.current) {
      window.clearTimeout(timer.current);
    }

    setValue(event.target.value);
    timer.current = window.setTimeout(searchBadges, SEARCH_TIMEOUT);
  }

  function searchBadges() {
    const v = value.toLowerCase();
    const found = badges.filter((b) => b.name.toLowerCase().indexOf(v) !== -1);
    setFoundBadges(found);
  }

  return (
    <Modal
      isOpen={show}
      appElement={document.body}
      contentLabel={t("Search badge")}
      onRequestClose={onClose}
      closeTimeoutMS={300}
    >
      <div className="cf-form cf-new-badge-modal">
        <div className="cf-cgroup">
          <label htmlFor="new-badge-modal-search-input">{t("badge name")}</label>
          <input type="text" id="new-badge-modal-search-input" onInput={handleKeyPressed} />
        </div>
      </div>

      <h3>{t("found badges")}</h3>
      {foundBadges.length === 0 && <p>{t("no badges found")}</p>}

      <ul>
        {foundBadges.map((b) => (
          <FoundBadge key={b.badge_id} badge={b} selectBadge={selectBadge} />
        ))}
      </ul>

      <p>
        <button type="button" className="cf-btn" onClick={onClose}>
          {t("cancel")}
        </button>
      </p>
    </Modal>
  );
}
