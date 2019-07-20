import React from "react";

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
import AutocompleteTextarea from "../autocomplete";

class CfEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: props.text, dragging: false, loading: false };
    this.textarea = React.createRef();

    this.valueChanged = this.valueChanged.bind(this);
    this.setValue = this.setValue.bind(this);
    this.dragStart = this.dragStart.bind(this);
    this.dragStop = this.dragStop.bind(this);

    this.fileDropped = this.fileDropped.bind(this);
    this.fileUploadFinished = this.fileUploadFinished.bind(this);
  }

  componentDidUpdate(prevProps) {
    if (prevProps.text !== this.props.text) {
      this.setState({ value: this.props.text });
    }
  }

  componentDidMount() {
    this.textarea.current.focus();
    const found = this.state.value.indexOf("\n\n");
    const pos = found === -1 ? 0 : found + 2;
    this.textarea.current.selectionStart = this.textarea.current.selectionEnd = pos;
  }

  valueChanged(ev) {
    this.setValue(ev.target.value);
  }

  setValue(value, opts = {}) {
    this.setState({ value });

    if (this.props.onChange) {
      this.props.onChange(value);
    }

    if(opts.start && opts.end) {
      window.setTimeout(() => {
        this.textarea.current.selectionStart = opts.start;
        this.textarea.current.selectionEnd = opts.end;
      }, 0)
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
      const { start, end } = getSelection(this.textarea.current);
      const image = `[![${desc}](${rsp.location}?size=medium${title ? ' "' + title + '"' : ""})](${rsp.location})`;
      const value = replaceAt(this.state.value, image, start, end);
      this.setState({ value });
      this.textarea.current.selectionStart = start;
      this.textarea.current.selectionEnd = start + image.length;
      this.textarea.current.focus();
    } else {
      alertError(t("Oops, something went wrong!"));
    }
  }

  render() {
    const { id, name, errors } = this.props;
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
            textarea={this.textarea}
            onImageUpload={this.fileDropped}
            enableImages={this.props.withImages}
          />

          <AutocompleteTextarea
            name={name}
            value={this.state.value}
            onChange={this.valueChanged}
            onComplete={this.setValue}
            triggers={[DefaultReplacements, EmojiReplacements, SmileyReplacements, MentionsReplacements]}
            ref={this.textarea}
          />
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
