import React, { useState } from "react";
import Modal from "react-modal";

import { t } from "../../modules/i18n";
import Boundary from "../../Boundary";

export default function AdminModal(props) {
  const [isOpen, setIsOpen] = useState(true);
  const [formValues, setformValues] = useState({ chosenReason: null, customReason: "" });

  function closeModal() {
    setIsOpen(false);
    window.setTimeout(props.onClose, 300);
  }

  const isValid = () => {
    const hasReason = !!formValues.chosenReason;
    const hasCustom = formValues.chosenReason === "custom" && !!formValues.customReason;
    const customIsValid = hasCustom || formValues.chosenReason !== "custom";

    return hasReason && customIsValid;
  };

  const reasonChanged = (ev) => setformValues({ ...formValues, chosenReason: ev.target.value });
  const customReasonChanged = (ev) => setformValues({ ...formValues, customReason: ev.target.value });

  const noReasonAction = () => {
    props.noReasonAction();
    closeModal();
  };

  const checkDeleteMessage = () => {
    if (isValid) {
      props.reasonAction(formValues.chosenReason, formValues.customReason);
      closeModal();
    }
  };

  return (
    <Boundary>
      <Modal
        isOpen={isOpen}
        appElement={document.body}
        contentLabel={props.heading}
        onRequestClose={closeModal}
        closeTimeoutMS={300}
      >
        <h2>{props.heading}</h2>

        <div className="cf-form cf-delete-message-modal">
          <div className="cf-cgroup">
            <label className="radio">
              <input
                type="radio"
                name="reason"
                value="off-topic"
                checked={formValues.chosenReason === "off-topic"}
                onChange={reasonChanged}
              />{" "}
              {t("message is off-topic")}
            </label>

            <label className="radio">
              <input
                type="radio"
                name="reason"
                value="not-constructive"
                checked={formValues.chosenReason === "not-constructive"}
                onChange={reasonChanged}
              />{" "}
              {t("message is not constructive")}
            </label>

            <label className="radio">
              <input
                type="radio"
                name="reason"
                value="illegal"
                checked={formValues.chosenReason === "illegal"}
                onChange={reasonChanged}
              />{" "}
              {t("message is illegal")}
            </label>

            <label className="radio">
              <input
                type="radio"
                name="reason"
                value="duplicate"
                checked={formValues.chosenReason === "duplicate"}
                onChange={reasonChanged}
              />{" "}
              {t("message is a duplicate")}
            </label>

            <label className="radio">
              <input
                type="radio"
                name="reason"
                value="spam"
                checked={formValues.chosenReason === "spam"}
                onChange={reasonChanged}
              />{" "}
              {t("message is spam")}
            </label>

            <label className="radio">
              <input
                type="radio"
                name="reason"
                value="custom"
                checked={formValues.chosenReason === "custom"}
                onChange={reasonChanged}
              />{" "}
              {t("custom reason")}
            </label>
          </div>

          {formValues.chosenReason === "custom" && (
            <div className="cf-cgroup">
              <label htmlFor="delete-message-custom-reason">{t("custom reason")}</label>
              <textarea
                name="custom_reason"
                id="delete-message-custom-reason"
                value={formValues.customReason}
                onChange={customReasonChanged}
              />
            </div>
          )}

          <p>
            {window.currentUser.admin && (
              <>
                <button type="button" className="cf-primary-btn" onClick={noReasonAction}>
                  {props.noReasonActionText}
                </button>{" "}
              </>
            )}
            <button type="button" className="cf-primary-btn" onClick={checkDeleteMessage} disabled={!isValid()}>
              {props.reasonActionText}
            </button>{" "}
            <button type="button" className="cf-btn" onClick={closeModal}>
              {t("cancel")}
            </button>
          </p>
        </div>
      </Modal>
    </Boundary>
  );
}
