import React from "react";

import { MentionsInput, Mention } from "react-mentions";

import DefaultReplacements from "./default_replacements";
import EmojiReplacements from "./emojis";
import MentionsReplacements from "./mentions";
import SmileyReplacements from "./smileys";

class CfEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: props.text };
    this.valueChanged = this.valueChanged.bind(this);
  }

  valueChanged(ev) {
    this.setState({ value: ev.target.value });
  }

  render() {
    const { name, mentions } = this.props;

    return (
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
    );
  }
}

export default CfEditor;
