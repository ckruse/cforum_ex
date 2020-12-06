import React, { useEffect, useRef, useState } from "react";
import Modal from "react-modal";
import Autosuggest from "react-autosuggest";

import { t } from "../../../modules/i18n";

const LANGUAGES = ["HTML", "CSS", "JavaScript", "Ruby", "PHP", "SQL", "Perl", "SVG"];

export default function CodeModal(props) {
  const [lang, setLang] = useState("");
  const [code, setCode] = useState(props.code || "");
  const [suggestions, setSuggestions] = useState([...LANGUAGES]);
  const focusElement = useRef();

  useEffect(() => {
    setCode(props.code);
    setLang("");
  }, [props.code]);

  function handleLanguageChosen(event, { suggestionValue }) {
    setLang(suggestionValue);
  }

  function handleLanguageChange(event, { newValue }) {
    setLang(newValue);
  }

  function handleCodeKeyPressed(event) {
    setCode(event.target.value);
  }

  function okPressed() {
    props.onOk(lang, code);
  }

  function onAfterOpen() {
    if (focusElement.current) {
      focusElement.current.focus();
    }
  }

  function onSuggestionsFetchRequested({ value }) {
    const inputValue = value.trim().toLowerCase();
    const inputLength = inputValue.length;

    const newSuggestions =
      inputLength === 0
        ? [...LANGUAGES]
        : LANGUAGES.filter((lang) => lang.toLowerCase().slice(0, inputLength) === inputValue);

    setSuggestions(newSuggestions);
  }

  function onSuggestionsClearRequested() {
    setSuggestions([...LANGUAGES]);
  }

  return (
    <Modal
      isOpen={props.isOpen}
      appElement={document.body}
      contentLabel={t("Add code block")}
      onRequestClose={props.onCancel}
      onAfterOpen={onAfterOpen}
      closeTimeoutMS={300}
      shouldReturnFocusAfterClose={false}
    >
      <div className="cf-form">
        <div className="cf-cgroup">
          <label htmlFor="add-code-block-modal-lang">{t("code language")}</label>
          <Autosuggest
            suggestions={suggestions}
            onSuggestionsFetchRequested={onSuggestionsFetchRequested}
            onSuggestionsClearRequested={onSuggestionsClearRequested}
            getSuggestionValue={(item) => item}
            renderSuggestion={(item) => item}
            inputProps={{
              type: "text",
              id: "add-code-block-modal-lang",
              value: lang,
              onChange: handleLanguageChange,
            }}
            shouldRenderSuggestions={() => true}
            onSuggestionSelected={handleLanguageChosen}
          />
        </div>

        <div className="cf-cgroup">
          <label htmlFor="add-code-block-modal-code">{t("code")}</label>
          <textarea ref={focusElement} id="add-code-block-modal-code" onChange={handleCodeKeyPressed} value={code} />
        </div>

        <button className="cf-primary-btn" type="button" onClick={okPressed}>
          {t("add code block")}
        </button>

        <button className="cf-btn" type="button" onClick={props.onCancel}>
          {t("cancel")}
        </button>
      </div>
    </Modal>
  );
}
