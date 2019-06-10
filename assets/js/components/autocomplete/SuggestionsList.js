import React from "react";
import getCaretCoordinates from "textarea-caret";

export default class SuggestionsList extends React.Component {
  constructor(props) {
    super(props);

    this.buttons = [];
  }

  isActive(idx) {
    return this.props.active === idx ? "active" : null;
  }

  componentDidUpdate(props) {
    if (this.buttons[this.props.active]) {
      this.buttons[this.props.active].focus();
    }
  }

  render() {
    const caret = getCaretCoordinates(this.props.textarea, this.props.textarea.selectionStart, { debug: true });
    const top = caret.top + caret.height + 5;

    return (
      <ul
        className="cf-autocomplete-suggestionslist"
        style={{ top: `${top}px`, left: `${caret.left}px` }}
        onKeyDown={this.props.onKeyDown}
      >
        {this.props.suggestions.map(({ matching, suggestion }, idx) => (
          <li key={suggestion.id} className={this.isActive(idx)}>
            <button
              type="button"
              ref={ref => (this.buttons[idx] = ref)}
              onClick={ev => this.props.onTrigger(ev, matching, suggestion)}
            >
              {matching.render(suggestion)}
            </button>
          </li>
        ))}
      </ul>
    );
  }
}
