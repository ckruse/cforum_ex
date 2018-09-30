import React from "react";
import Autosuggest from "react-autosuggest";

import { t } from "../../modules/i18n";

export default class NewTagInput extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: "", suggestions: [], tags: [] };

    this.keyDown = this.keyDown.bind(this);
    this.onSuggestionsFetchRequested = this.onSuggestionsFetchRequested.bind(this);
    this.onSuggestionsClearRequested = this.onSuggestionsClearRequested.bind(this);
    this.onSuggestionSelected = this.onSuggestionSelected.bind(this);
    this.onChange = this.onChange.bind(this);

    const slug = document.location.pathname.split("/")[1];
    fetch(`/api/v1/tags?f=${slug}`, { credentials: "same-origin" })
      .then(json => json.json())
      .then(json => {
        json.sort((a, b) => b.num_messages - a.num_messages);

        const newState = { ...this.state, tags: json };
        if (this.state.value == "") {
          newState.suggestions = newState.tags;
        }

        this.setState(newState);
      })
      .catch(e => console.log(e));
  }

  getSuggestions(value) {
    const inputValue = value.trim().toLowerCase();
    const rx = new RegExp("^" + inputValue, "i");

    return this.state.tags
      .filter(tag => !this.props.existingTags.includes(tag.tag_name) && rx.test(tag.tag_name))
      .slice(0, 25);
  }

  keyDown(event) {
    if (["Tab", ","].includes(event.key) && this.state.value.trim() != "") {
      event.preventDefault();
      this.props.onChoose(this.state.value);
      this.setState({ ...this.state, value: "", suggestions: this.getSuggestions("") });
    }
  }

  onSuggestionsFetchRequested({ value }) {
    this.setState({
      suggestions: this.getSuggestions(value)
    });
  }

  onSuggestionsClearRequested() {
    this.setState({
      suggestions: []
    });
  }

  onSuggestionSelected(event, { suggestion, suggestionValue, suggestionIndex, sectionIndex, method }) {
    this.props.onChoose(suggestionValue);
    this.setState({ ...this.state, value: "", suggestions: this.getSuggestions("") });
    event.preventDefault();
  }

  onChange(event, { newValue }) {
    this.setState({
      value: newValue
    });
  }

  render() {
    const { value, suggestions } = this.state;

    return (
      <li className="">
        <label htmlFor="new-tag-input">{t("enter new tag")}</label>
        <Autosuggest
          suggestions={suggestions}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          getSuggestionValue={item => item.tag_name}
          renderSuggestion={item => item.tag_name}
          onSuggestionSelected={this.onSuggestionSelected}
          highlightFirstSuggestion={this.state.value != ""}
          inputProps={{
            onKeyDown: ev => this.keyDown(ev),
            type: "text",
            id: "new-tag-input",
            value,
            onChange: this.onChange
          }}
          shouldRenderSuggestions={() => true}
        />
      </li>
    );
  }
}
