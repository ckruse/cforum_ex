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
    return (
      <>
        <CfEditor text={this.props.text} name={this.props.name} mentions={true} onChange={this.refreshSuggestions} />
        <TagList tags={this.props.tags} postingText={this.state.value} />
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

  render(<CfContentForm text={area.value} name={area.name} tags={tags} />, el);
});
