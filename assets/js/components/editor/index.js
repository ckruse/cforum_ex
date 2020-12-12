import React, { useEffect, useRef, useState } from "react";
import { ErrorBoundary } from "@appsignal/react";

import DefaultReplacements from "./default_replacements";
import EmojiReplacements from "./emojis";
import MentionsReplacements from "./mentions";
import SmileyReplacements from "./smileys";
import LivePreview from "./live_preview";
import Toolbar from "./toolbar";
import Dropzone from "./dropzone";
import { alertError } from "../../modules/alerts";
import { t } from "../../modules/i18n";
import { replaceAt, getSelection, escapeText } from "./helpers";
import AutocompleteTextarea from "../autocomplete";
import appsignal, { FallbackComponent } from "../../appsignal";

export default function CfEditor({ text, onChange, id, name, errors, withImages }) {
  const [value, setValue] = useState(text);
  const [dragging, setDragging] = useState(false);
  const [loading, setLoading] = useState(false);
  const [didPosition, setDidPosition] = useState(false);
  const textarea = useRef();

  useEffect(() => {
    setValue(text);
  }, [text]);

  useEffect(
    () => {
      if (textarea.current && !didPosition) {
        textarea.current.focus();
        const found = value.indexOf("\n\n");
        const cite = value.search(/^>/);
        let pos = found === -1 ? 0 : found + 2;

        if (cite !== -1 && found > cite) {
          pos = cite;
        }

        textarea.current.selectionStart = textarea.current.selectionEnd = pos;
        setDidPosition(true);
      }
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [textarea.current]
  );

  function valueChanged(ev) {
    setValue(ev.target.value);
  }

  function doSetValue(value, opts = {}) {
    setValue(value);

    if (onChange) {
      onChange(value);
    }

    if (opts.start && opts.end) {
      window.setTimeout(() => {
        textarea.current.selectionStart = opts.start;
        textarea.current.selectionEnd = opts.end;
      }, 0);
    }
  }

  function dragStart() {
    setDragging(true);
  }
  function dragStop() {
    setDragging(false);
  }
  async function fileDropped(file, desc, title) {
    const fdata = new FormData();
    fdata.append("image", file);

    const rsp = await fetch("/api/v1/images", {
      method: "POST",
      credentials: "same-origin",
      cache: "no-cache",
      body: fdata,
    });

    const json = await rsp.json();
    fileUploadFinished(json, desc, title, file);
  }

  function fileUploadFinished(rsp, desc, title, file) {
    setLoading(false);

    if (rsp.status === "success") {
      const { start, end } = getSelection(textarea.current);
      const size = file.type === "image/svg+xml" ? "" : "?size=medium";
      const escapedTitle = title ? ' "' + escapeText(title, '"') + '"' : "";
      const escapedDesc = escapeText(desc, "\\]");
      const escapedLocation = escapeText(rsp.location, ")");

      const image = `[![${escapedDesc}](${escapedLocation}${size}${escapedTitle})](${escapeText(rsp.location, ")")})`;

      const newValue = replaceAt(value, image, start, end);
      setValue(newValue);
      textarea.current.selectionStart = start;
      textarea.current.selectionEnd = start + image.length;
      textarea.current.focus();
    } else {
      alertError(t("Oops, something went wrong!"));
    }
  }

  let className = "cf-cgroup cf-textarea-only cf-editor";
  if (dragging) {
    className += " dragging";
  }

  if (errors[id]) {
    className += " has-error";
  }

  return (
    <ErrorBoundary instance={appsignal} fallback={(error) => <FallbackComponent />}>
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
            value={value}
            changeValue={doSetValue}
            textarea={textarea}
            onImageUpload={fileDropped}
            enableImages={withImages}
          />

          <AutocompleteTextarea
            name={name}
            value={value}
            onChange={valueChanged}
            onComplete={doSetValue}
            triggers={[DefaultReplacements, EmojiReplacements, SmileyReplacements, MentionsReplacements]}
            ref={textarea}
          />
        </div>

        {withImages && (
          <Dropzone onDragStart={dragStart} onDragStop={dragStop} onDrop={fileDropped} loading={loading} />
        )}

        <LivePreview content={value} />
      </fieldset>
    </ErrorBoundary>
  );
}
