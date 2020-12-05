import React from "react";
import Modal from "react-modal";
import Autosuggest from "react-autosuggest";

import { t } from "../../../modules/i18n";

const LANGUAGES = ["HTML", "CSS", "JavaScript", "Ruby", "PHP", "SQL", "Perl", "SVG"];

class CodeModal extends React.Component {
  constructor(props) {
    super(props);

    this.state = { lang: "", code: this.props.code, suggestions: [...LANGUAGES] };
  }

  componentDidUpdate(prevProps) {
    if (prevProps.code !== this.props.code) {
      this.setState({ code: this.props.code, lang: "" });
    }
  }

  handleLanguageChosen = (event, { suggestionValue }) => {
    this.setState({ lang: suggestionValue });
  };

  handleLanguageChange = (event, { newValue }) => {
    this.setState({ lang: newValue });
  };

  handleCodeKeyPressed = (event) => {
    this.setState({ code: event.target.value });
  };

  okPressed = () => {
    this.props.onOk(this.state.lang, this.state.code);
  };

  onAfterOpen = () => {
    if (this.focusElement) {
      this.focusElement.focus();
    }
  };

  onSuggestionsFetchRequested = ({ value }) => {
    const inputValue = value.trim().toLowerCase();
    const inputLength = inputValue.length;

    const suggestions =
      inputLength === 0
        ? [...LANGUAGES]
        : LANGUAGES.filter((lang) => lang.toLowerCase().slice(0, inputLength) === inputValue);

    this.setState({ suggestions });
  };

  onSuggestionsClearRequested = () => {
    this.setState({ suggestions: [...LANGUAGES] });
  };

  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        appElement={document.body}
        contentLabel={t("Add code block")}
        onRequestClose={this.props.onCancel}
        onAfterOpen={this.onAfterOpen}
        closeTimeoutMS={300}
        shouldReturnFocusAfterClose={false}
      >
        <div className="cf-form">
          <div className="cf-cgroup">
            <label htmlFor="add-code-block-modal-lang">{t("code language")}</label>
            <Autosuggest
              suggestions={this.state.suggestions}
              onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
              onSuggestionsClearRequested={this.onSuggestionsClearRequested}
              getSuggestionValue={(item) => item}
              renderSuggestion={(item) => item}
              inputProps={{
                type: "text",
                id: "add-code-block-modal-lang",
                value: this.state.lang,
                onChange: this.handleLanguageChange,
              }}
              shouldRenderSuggestions={() => true}
              onSuggestionSelected={this.handleLanguageChosen}
            />
          </div>
          <div className="cf-cgroup">
            <label htmlFor="add-code-block-modal-code">{t("code")}</label>
            <textarea id="add-code-block-modal-code" onChange={this.handleCodeKeyPressed} value={this.state.code} />
          </div>
          <button className="cf-primary-btn" type="button" onClick={this.okPressed}>
            {t("add code block")}
          </button>{" "}
          <button className="cf-btn" type="button" onClick={this.props.onCancel}>
            {t("cancel")}
          </button>
        </div>
      </Modal>
    );
  }
}

export default CodeModal;
