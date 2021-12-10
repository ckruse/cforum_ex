import React from "react";
import { render } from "react-dom";

import CfBlogForm from "./blog_form";

const gatherErrors = (element) => {
  const errors = {};

  element.querySelectorAll("label .help.error").forEach((err) => {
    errors[err.closest("label").getAttribute("for")] = err.textContent;
  });

  return errors;
};

const getMethod = (form) => {
  const input = form.querySelector("[name='_method']");
  if (input) {
    return input.value;
  }

  return form.method;
};

document.querySelectorAll(".cf-posting-form").forEach(async (frm) => {
  const excerptArea = frm.querySelector("textarea[name='message[excerpt]']");
  const postingArea = frm.querySelector("textarea[name='message[content]']");
  const method = getMethod(frm);
  const tags = Array.from(frm.querySelectorAll('input[data-tag="yes"]'))
    .filter((t) => !!t.value)
    .map((t) => {
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

  const csrfInfo = document.querySelector("meta[name='csrf-token']");
  const subject = frm.querySelector("[name='message[subject]']").value;
  const email = frm.querySelector("[name='message[email]']").value;
  const homepage = frm.querySelector("[name='message[homepage]']").value;
  const thumbnailAlt = frm.querySelector("[name='message[thumbnail_alt]']").value;
  const draftElement = frm.querySelector("#message_draft");
  const draft = draftElement ? draftElement.checked : undefined;

  const errors = gatherErrors(frm);

  render(
    <CfBlogForm
      draft={draft}
      form={frm}
      subject={subject}
      email={email}
      homepage={homepage}
      thumbnailAlt={thumbnailAlt}
      excerpt={excerptArea.value}
      text={postingArea.value}
      tags={tags}
      globalTagsError={globalTagsError}
      method={method}
      csrfInfo={{
        param: csrfInfo.getAttribute("csrf-param"),
        token: csrfInfo.getAttribute("content"),
      }}
      errors={errors}
    />,
    frm
  );
});
