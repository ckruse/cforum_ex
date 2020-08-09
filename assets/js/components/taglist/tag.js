import React from "react";

function Tag({ error, tag, onClick, name }) {
  return (
    <li className={error ? " has-error" : ""}>
      <div className="cf-tag">
        {tag}
        <button type="button" className="remove" aria-labelledby="remove-chosen-tag-help" onClick={onClick}>
          <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
            <use xlinkHref="/images/icons.svg#svg-remove" />
          </svg>
        </button>
        <input type="hidden" name={name || "message[tags][]"} value={tag} />
      </div>

      {error}
    </li>
  );
}

export default React.memo(Tag);
