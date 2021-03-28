import React, { useState } from "react";

import Boundary from "../Boundary";
import CfEditor from "../components/editor";
import TagList from "../components/taglist";
import { t } from "../modules/i18n";
import LivePreview from "./live_preview";
import Meta from "./meta";

export default function CfBlogForm(props) {
  const { csrfInfo, method, email, subject, homepage, errors, excerpt, text, tags, globalTagsError } = props;
  const [meta, setMeta] = useState({ email, subject, homepage });
  const [contents, setContents] = useState({ text, excerpt });
  const [tagsList, setTagsList] = useState(tags);

  function updateMeta(ev) {
    const name = ev.target.name.replace(/message\[(\w+)\]/, "$1");

    const value = name === "thumbnail" ? ev.target.files[0] : ev.target.value;

    setMeta({ ...meta, [name]: value });
  }

  function updateExcerpt(excerpt) {
    setContents({ ...contents, excerpt });
  }

  function updateText(text) {
    setContents({ ...contents, text });
  }

  function onTagChange(tags) {
    setTagsList(tags);
  }

  return (
    <Boundary>
      <input type="hidden" name={csrfInfo.param} value={csrfInfo.token} />
      {method.toUpperCase() !== "POST" && <input type="hidden" name="_method" value={method} />}

      <Meta subject={meta.subject} email={meta.email} homepage={meta.homepage} onChange={updateMeta} errors={errors} />

      <div className="cf-content-form">
        <CfEditor
          text={excerpt}
          name="message[excerpt]"
          id="message_excerpt"
          labelText={t("excerpt content")}
          withMentions={true}
          withImages={false}
          withPreview={false}
          errors={errors}
          onChange={updateExcerpt}
          withCounter={false}
        />

        <CfEditor
          text={text}
          name="message[content]"
          id="message_content"
          withMentions={true}
          withImages={true}
          withPreview={false}
          errors={errors}
          onChange={updateText}
        />

        <TagList tags={tagsList} postingText={contents.text} globalTagsError={globalTagsError} onChange={onTagChange} />
      </div>

      <LivePreview excerpt={contents.excerpt} content={contents.text} thumbnail={meta.thumbnail} />

      <p className="form-actions">
        <button className="cf-primary-btn" type="submit">
          {t("save message")}
        </button>{" "}
        <a href="/" className="cf-btn">
          {t("discard")}
        </a>
      </p>
    </Boundary>
  );
}
