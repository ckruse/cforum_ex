import React from "react";

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
      this.setState({ value: this.props.text });
    }
  }

  render() {
    const { tags, id, name } = this.props;

    return (
      <>
        <CfEditor
          text={this.state.value}
          name={name}
          id={id}
          mentions={true}
          onChange={this.refreshSuggestions}
          withImages={true}
          errors={this.props.errors}
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
