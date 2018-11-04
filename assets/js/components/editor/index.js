import React from "react";

import { MentionsInput, Mention } from "react-mentions";

import DefaultReplacements from "./default_replacements";
import EmojiReplacements from "./emojis";
import MentionsReplacements from "./mentions";
import SmileyReplacements from "./smileys";
import LivePreview from "./live_preview";

class CfEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: props.text };
    this.valueChanged = this.valueChanged.bind(this);
  }

  valueChanged(_ev, _markupVal, value) {
    this.setState({ value: value });

    if (this.props.onChange) {
      this.props.onChange(value);
    }
  }

  render() {
    const { name, mentions } = this.props;

    return (
      <fieldset>
        <div className="cf-cgroup cf-textarea-only cf-editor">
          <MentionsInput
            value={this.state.value}
            name={name}
            className="cf-posting-input"
            onChange={this.valueChanged}
            markup="[__display__](__type__:__id__)"
          >
            <Mention {...SmileyReplacements} />
            <Mention {...DefaultReplacements} />
            <Mention {...EmojiReplacements} />
            {mentions && <Mention {...MentionsReplacements} />}
          </MentionsInput>
        </div>

        <LivePreview content={this.state.value} />
      </fieldset>
    );
  }
}

export default CfEditor;
