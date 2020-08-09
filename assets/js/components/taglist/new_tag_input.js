import React, { useState, useEffect } from "react";
import Autosuggest from "react-autosuggest";

import { t } from "../../modules/i18n";
import SuggestionItem from "./suggestion_item";

const tagMatches = (tag, rx) => rx.test(tag.tag_name) || tag.synonyms.find((syn) => rx.test(syn));

const getSuggestions = (value, allTags, existingTags) => {
  const inputValue = value.trim().toLowerCase();
  const rx = new RegExp("^" + inputValue, "i");

  return allTags.filter((tag) => !existingTags.includes(tag.tag_name) && tagMatches(tag, rx)).slice(0, 25);
};

export default function NewTagInput({ allTags, existingTags, onChoose }) {
  const [suggestions, setSuggestions] = useState([]);
  const [value, setValue] = useState("");

  useEffect(() => {
    if (value === "") {
      setSuggestions(allTags.slice(0, 25));
    }
  }, [value, allTags, existingTags]);

  function keyDown(event) {
    if (["Tab", ","].includes(event.key) && value.trim() !== "") {
      event.preventDefault();
      onChoose(value);
      setValue("");
      setSuggestions(getSuggestions("", allTags, existingTags));
    }
  }

  function onSuggestionsFetchRequested({ value }) {
    setSuggestions(getSuggestions(value, allTags, existingTags));
  }

  function onSuggestionsClearRequested() {
    setSuggestions([]);
  }

  function onSuggestionSelected(event, { suggestion, suggestionValue, suggestionIndex, sectionIndex, method }) {
    onChoose(suggestionValue);
    setValue("");
    setSuggestions(getSuggestions("", allTags, existingTags));
    event.preventDefault();
  }

  function onChange(event, { newValue }) {
    setValue(newValue);
  }

  return (
    <>
      <label htmlFor="new-tag-input">{t("enter new tag")}</label>
      <Autosuggest
        suggestions={suggestions}
        onSuggestionsFetchRequested={onSuggestionsFetchRequested}
        onSuggestionsClearRequested={onSuggestionsClearRequested}
        getSuggestionValue={(item) => item.tag_name}
        renderSuggestion={(tag) => <SuggestionItem tag={tag} />}
        onSuggestionSelected={onSuggestionSelected}
        inputProps={{
          onKeyDown: (ev) => keyDown(ev),
          type: "text",
          id: "new-tag-input",
          value,
          onChange: onChange,
        }}
        shouldRenderSuggestions={() => true}
      />
    </>
  );
}
