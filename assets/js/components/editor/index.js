import React from "react";

import { MentionsInput, Mention } from "react-mentions";

import DefaultReplacements from "./default_replacements";
import EmojiReplacements from "./emojis";
import MentionsReplacements from "./mentions";
import SmileyReplacements from "./smileys";
import LivePreview from "./live_preview";
import Toolbar from "./toolbar";

class CfEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: props.text };
    this.valueChanged = this.valueChanged.bind(this);
    this.setValue = this.setValue.bind(this);
  }

  componentDidUpdate() {
    if (this.setSelection) {
      this.state.textarea.selectionStart = this.setSelection.start;
      this.state.textarea.selectionEnd = this.setSelection.end;
    }

    this.setSelection = null;
  }

  valueChanged(ev, markupVal, value) {
    this.setValue(value);
  }

  setValue(value, opts = {}) {
    this.setState({ value });

    if (this.props.onChange) {
      this.props.onChange(value);
    }

    if (opts.start && opts.end) {
      this.setSelection = { start: opts.start, end: opts.end };
    }
  }

  render() {
    const { name, mentions } = this.props;

    return (
      <fieldset>
        <div className="cf-cgroup cf-textarea-only cf-editor">
          <Toolbar value={this.state.value} changeValue={this.setValue} textarea={this.state.textarea} />

          <MentionsInput
            value={this.state.value}
            name={name}
            className="cf-posting-input"
            onChange={this.valueChanged}
            markup=":CF_INT:__display__:CF_INT:__type__:CF_INT:__id__:CF_INT:"
            inputRef={textarea => this.setState({ textarea })}
            allowSpaceInQuery={false}
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
