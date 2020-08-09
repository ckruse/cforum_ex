import React from "react";

function SuggestionItem({ tag }) {
  return (
    <>
      <span className="cf-tag-suggestion">{tag.tag_name}</span>
      {tag.synonyms.length > 0 && <span className="cf-tag-suggestion-synonyms">({tag.synonyms.join(", ")})</span>}
    </>
  );
}

export default React.memo(SuggestionItem);
