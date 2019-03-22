import React from "react";

import { MentionsInput, Mention } from "react-mentions";

import DefaultReplacements from "./default_replacements";
import EmojiReplacements from "./emojis";
import MentionsReplacements from "./mentions";
import SmileyReplacements from "./smileys";
import LivePreview from "./live_preview";
import Toolbar from "./toolbar";
import Dropzone from "./dropzone";
import { alertError } from "../../modules/alerts";
import { t } from "../../modules/i18n";
import { replaceAt, getSelection } from "./helpers";

class CfEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: props.text, dragging: false, loading: false, textarea: null };

    this.valueChanged = this.valueChanged.bind(this);
    this.setValue = this.setValue.bind(this);
    this.dragStart = this.dragStart.bind(this);
    this.dragStop = this.dragStop.bind(this);

    this.fileDropped = this.fileDropped.bind(this);
    this.fileUploadFinished = this.fileUploadFinished.bind(this);
    this.positionCursor = this.positionCursor.bind(this);
  }

  componentDidUpdate(prevProps) {
    if (this.setSelection) {
      this.state.textarea.selectionStart = this.setSelection.start;
      this.state.textarea.selectionEnd = this.setSelection.end;
    }

    this.setSelection = null;

    if (prevProps.text !== this.props.text) {
      this.setState({ value: this.props.text });
    }
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

  dragStart() {
    this.setState({ dragging: true });
  }
  dragStop() {
    this.setState({ dragging: false });
  }
  fileDropped(file, desc, title) {
    const fdata = new FormData();
    fdata.append("image", file);

    fetch("/api/v1/images", {
      method: "POST",
      credentials: "same-origin",
      cache: "no-cache",
      body: fdata
    })
      .then(rsp => rsp.json())
      .then(json => this.fileUploadFinished(json, desc, title));
  }

  fileUploadFinished(rsp, desc, title) {
    this.setState({ loading: false });

    if (rsp.status === "success") {
      const { start, end } = getSelection(this.state.textarea);
      const image = `[![${desc}](${rsp.location}?size=medium${title ? ' "' + title + '"' : ""})](${rsp.location})`;
      const value = replaceAt(this.state.value, image, start, end);

      this.setState({ value });
      this.state.textarea.selectionStart = start;
      this.state.textarea.selectionEnd = start + image.length;
      this.state.textarea.focus();
    } else {
      alertError(t("Oops, something went wrong!"));
    }
  }

  positionCursor(id, display) {
    switch (id) {
      case "„“":
      case '""':
      case "‚‘":
        this.setSelection = {
          start: this.state.textarea.selectionStart,
          end: this.state.textarea.selectionEnd
        };
        return;

      default:
        return;
    }
  }

  render() {
    const { id, name, mentions, errors } = this.props;
    let className = "cf-cgroup cf-textarea-only cf-editor";
    if (this.state.dragging) {
      className += " dragging";
    }

    if (errors[id]) {
      className += " has-error";
    }

    return (
      <fieldset>
        <label htmlFor={id}>
          {t("posting text")}{" "}
          {errors[id] && (
            <>
              <span className="help error">{errors[id]}</span>
            </>
          )}
        </label>

        <div className={className}>
          <Toolbar
            value={this.state.value}
            changeValue={this.setValue}
            textarea={this.state.textarea}
            onImageUpload={this.fileDropped}
            enableImages={this.props.withImages}
          />

          <MentionsInput
            value={this.state.value}
            name={name}
            id={id}
            className="cf-posting-input"
            onChange={this.valueChanged}
            markup=":CF_INT:__display__:CF_INT:__type__:CF_INT:__id__:CF_INT:"
            inputRef={textarea => this.setState({ textarea })}
            allowSpaceInQuery={false}
            style={{ input: { overflow: "auto" } }}
          >
            <Mention {...SmileyReplacements} />
            <Mention {...DefaultReplacements} onAdd={this.positionCursor} />
            <Mention {...EmojiReplacements} />
            {mentions ? <Mention {...MentionsReplacements} /> : null}
          </MentionsInput>
        </div>

        {this.props.withImages && (
          <Dropzone onDragStart={this.dragStart} onDragStop={this.dragStop} onDrop={this.fileDropped} />
        )}

        <LivePreview content={this.state.value} />
      </fieldset>
    );
  }
}

export default CfEditor;
