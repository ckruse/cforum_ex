import React from "react";
import { render } from "react-dom";

import CfEditor from "../editor";
import TagList from "../taglist";

class CfContentForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: this.props.text };

    this.refreshSuggestions = this.refreshSuggestions.bind(this);
  }

  refreshSuggestions(newValue) {
    this.setState({ value: newValue });
  }

  render() {
    const { text, tags, name } = this.props;

    return (
      <>
        <CfEditor text={text} name={name} mentions={true} onChange={this.refreshSuggestions} withImages={true} />
        <TagList tags={tags} postingText={this.state.value} globalTagsError={this.props.globalTagsError} />
      </>
    );
  }
}

export default CfContentForm;

document.querySelectorAll(".cf-content-form").forEach(el => {
  const area = el.querySelector("textarea");
  const tags = Array.from(el.querySelectorAll('input[data-tag="yes"]'))
    .filter(t => !!t.value)
    .map(t => {
      const elem = t.previousElementSibling.querySelector(".error");
      return [t.value, elem ? elem.textContent : null];
    });

  let globalTagsError = null;
  const globalTagsErrorElement = document
    .querySelector(".cf-form-tagslist")
    .closest("fieldset")
    .querySelector(".help.error");

  if (globalTagsErrorElement) {
    globalTagsError = globalTagsErrorElement.textContent;
  }

  render(<CfContentForm text={area.value} name={area.name} tags={tags} globalTagsError={globalTagsError} />, el);
});
