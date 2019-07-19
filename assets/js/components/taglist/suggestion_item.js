import React from "react";

export default class SuggestionItem extends React.PureComponent {
  render() {
    const tag = this.props.tag;

    return (
      <>
        <span className="cf-tag-suggestion">{tag.tag_name}</span>
        {tag.synonyms.length > 0 && <span className="cf-tag-suggestion-synonyms">({tag.synonyms.join(", ")})</span>}
      </>
    );
  }
}
