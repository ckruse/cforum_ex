import React from "react";

import SuggestionsList from "./SuggestionsList";

const IGNORED_KEYS = ["Control", "Meta", "Alt", "Shift", "ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"];

const NAV_KEYS = ["ArrowUp", "ArrowDown"];
const TRIGGER_KEYS = ["Tab", "Enter"];

class AutocompleteTextarea extends React.Component {
  constructor(props) {
    super(props);

    this.state = { suggestions: [], matching: [], active: null };

    this.handleKeyUp = this.handleKeyUp.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.onTrigger = this.onTrigger.bind(this);
    this.handleSuggestions = this.handleSuggestions.bind(this);
  }

  resetSuggestions() {
    this.setState({ suggestions: [], matching: [], active: null });
  }

  navigate(key) {
    if (key === "ArrowDown") {
      this.setState((oldState) => {
        let active;

        if (oldState.active === null) {
          active = 0;
        } else {
          active = oldState.active + 1;
          if (active >= oldState.suggestions.length) {
            active = 0;
          }
        }

        return { active };
      });
    } else {
      this.setState((oldState) => {
        let active = oldState.active - 1;
        if (active < 0) {
          active = oldState.suggestions.length - 1;
        }

        return { active };
      });
    }
  }

  triggerCompletion(matching, suggestion) {
    const cursorPosition = this.props.textarea.current.selectionStart;
    const currentSubstring = this.props.value.substring(0, cursorPosition);
    const rest = this.props.value.substring(cursorPosition);
    const matchData = currentSubstring.match(matching.trigger);
    const suggestionValue = matching.complete(suggestion);
    const newValue = currentSubstring.substr(0, currentSubstring.length - matchData[0].length) + suggestionValue + rest;

    this.props.onComplete(newValue);

    let cursorPositionStart = cursorPosition + suggestionValue.length - matchData[0].length;
    let cursorPositionEnd = cursorPositionStart;

    if (matching.cursorPosition) {
      const { start, end } = matching.cursorPosition(
        { start: cursorPositionStart, end: cursorPositionEnd },
        suggestionValue
      );

      cursorPositionStart = start;
      cursorPositionEnd = end;
    }

    window.setTimeout(() => this.props.textarea.current.setSelectionRange(cursorPositionStart, cursorPositionEnd), 0);
  }

  shouldComplete(event) {
    if (TRIGGER_KEYS.includes(event.key) && typeof this.state.active === "number") {
      return this.state.active;
    }

    if (event.key === "Tab" && this.state.active === null) {
      return 0;
    }

    return false;
  }

  handleKeyDown(ev) {
    if (this.state.suggestions.length > 0) {
      if (NAV_KEYS.includes(ev.key)) {
        ev.preventDefault();
        this.navigate(ev.key);
        return;
      }

      const shouldComplete = this.shouldComplete(ev);
      if (shouldComplete !== false) {
        ev.preventDefault();
        this.resetSuggestions();
        this.props.textarea.current.focus();
        const { matching, suggestion } = this.state.suggestions[shouldComplete];
        this.triggerCompletion(matching, suggestion);
      }
    }

    if (!IGNORED_KEYS.includes(ev.key)) {
      this.resetSuggestions();
      this.props.textarea.current.focus();
    }
  }

  handleKeyUp(ev) {
    if (IGNORED_KEYS.includes(ev.key) || ev.key === "Escape") {
      return;
    }

    const triggers = this.props.triggers;
    const cursorPosition = this.props.textarea.current.selectionStart;
    const currentSubstring = this.props.value.substring(0, cursorPosition);

    const matching = triggers.filter((trg) => currentSubstring.match(trg.trigger));
    if (matching.length === 0) {
      this.resetSuggestions();
      return;
    }

    this.setState({ matching, active: null, suggestions: [] });
    matching.forEach((element) => {
      return element.suggestions(RegExp.lastMatch, (suggestions) => this.handleSuggestions(element, suggestions));
    });
  }

  handleSuggestions(matching, suggestions) {
    const tuples = suggestions.map((suggestion) => ({ matching, suggestion }));
    this.setState((prevState) => ({ suggestions: [...prevState.suggestions, ...tuples] }));
  }

  onTrigger(event, matching, suggestion) {
    event.preventDefault();

    this.resetSuggestions();
    this.props.textarea.current.focus();
    this.triggerCompletion(matching, suggestion);
  }

  render() {
    return (
      <div className="cf-autocomplete-wrapper">
        <textarea
          name={this.props.name}
          ref={this.props.textarea}
          value={this.props.value}
          onChange={this.props.onChange}
          onKeyUp={this.handleKeyUp}
          onKeyDown={this.handleKeyDown}
        />
        {this.state.suggestions.length > 0 && (
          <SuggestionsList
            suggestions={this.state.suggestions}
            // matching={this.state.matching}
            textarea={this.props.textarea}
            active={this.state.active}
            onKeyDown={this.handleKeyDown}
            onTrigger={this.onTrigger}
          />
        )}
      </div>
    );
  }
}

export default React.forwardRef((props, ref) => <AutocompleteTextarea {...props} textarea={ref} />);
