import React, { useEffect, useRef, useState } from "react";
import Modal from "react-modal";

import { t } from "../../../modules/i18n";

export default function LinkModal(props) {
  const [linkText, setLinkText] = useState(props.linkText || "");
  const [linkTarget, setLinkTarget] = useState("");
  const focusElement = useRef();

  useEffect(() => {
    setLinkText(props.linkText || "");
    setLinkTarget("");
  }, [props.linkText]);

  function handleTextKeyPressed(event) {
    setLinkText(event.target.value);
  }

  function handleTargetKeyPressed(event) {
    setLinkTarget(event.target.value);
  }

  function onAfterOpen() {
    if (focusElement.current) {
      focusElement.current.focus();
    }
  }

  function okPressed() {
    setLinkText("");
    setLinkTarget("");

    props.onOk(linkText, linkTarget);
  }

  return (
    <Modal
      isOpen={props.isOpen}
      appElement={document.body}
      contentLabel={t("Add new link")}
      onRequestClose={props.onCancel}
      onAfterOpen={onAfterOpen}
      closeTimeoutMS={300}
      shouldReturnFocusAfterClose={false}
    >
      <div className="cf-form">
        <div className="cf-cgroup">
          <label htmlFor="add-link-modal-linktext">{t("link description")}</label>
          <input
            ref={focusElement}
            type="text"
            id="add-link-modal-linktext"
            onChange={handleTextKeyPressed}
            value={linkText}
          />
        </div>

        <div className="cf-cgroup">
          <label htmlFor="add-link-modal-linkurl">{t("link target")}</label>
          <input type="text" id="add-link-modal-linkurl" onChange={handleTargetKeyPressed} value={linkTarget} />
        </div>

        <button className="cf-primary-btn" type="button" onClick={okPressed}>
          {t("add link")}
        </button>

        <button className="cf-btn" type="button" onClick={props.onCancel}>
          {t("cancel")}
        </button>
      </div>
    </Modal>
  );
}
