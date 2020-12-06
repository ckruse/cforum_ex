import React, { useEffect, useRef } from "react";
import getCaretCoordinates from "textarea-caret";

export default function SuggestionsList({ active, textarea, onKeyDown, suggestions, onTrigger }) {
  const buttons = useRef([]);

  function isActive(idx) {
    return active === idx ? "active" : null;
  }

  useEffect(() => {
    if (buttons[active]) {
      buttons[active].focus();
    }
  });

  function correctedPosition(coordinates) {
    if (textarea.current.scrollLeft) {
      coordinates.left = coordinates.left - textarea.current.scrollLeft;
    }

    if (textarea.current.scrollHeight) {
      coordinates.top = coordinates.top - textarea.current.scrollTop;
    }

    return coordinates;
  }

  const caret = correctedPosition(getCaretCoordinates(textarea.current, textarea.current.selectionEnd));

  const top = caret.top + caret.height + 5;

  return (
    <ul
      className="cf-autocomplete-suggestionslist"
      style={{ top: `${top}px`, left: `${caret.left}px` }}
      onKeyDown={onKeyDown}
    >
      {suggestions.map(({ matching, suggestion }, idx) => (
        <li key={suggestion.id} className={isActive(idx)}>
          <button
            type="button"
            ref={(ref) => (buttons.current[idx] = ref)}
            onClick={(ev) => onTrigger(ev, matching, suggestion)}
          >
            {matching.render(suggestion)}
          </button>
        </li>
      ))}
    </ul>
  );
}
