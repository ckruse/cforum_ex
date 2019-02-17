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

    if (this.props.onTextChange) {
      this.props.onTextChange(newValue);
    }
  }

  componentDidUpdate(prevProps) {
    if (prevProps.text !== this.props.text) {
      console.log("change text");
      this.setState({ value: this.props.text });
    }
  }

  render() {
    const { tags, name } = this.props;

    return (
      <>
        <CfEditor
          text={this.state.value}
          name={name}
          mentions={true}
          onChange={this.refreshSuggestions}
          withImages={true}
        />
        <TagList
          tags={tags}
          postingText={this.state.value}
          globalTagsError={this.props.globalTagsError}
          onChange={this.props.onTagChange}
        />
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
