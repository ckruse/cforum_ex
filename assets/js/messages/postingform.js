import React from "react";
import { render } from "react-dom";

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

document.querySelectorAll(".cf-posting-form").forEach(async (el) => {
  const { default: CfPostingForm } = await import(/* webpackChunkName: "postingform" */ "../components/postingform");

  const area = el.querySelector("textarea");
  const method = getMethod(el);
  const tags = Array.from(el.querySelectorAll('input[data-tag="yes"]'))
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

  const forumIdNode = el.querySelector("[name='message[forum_id]']");
  const options = [];
  if (forumIdNode) {
    forumIdNode.querySelectorAll("option").forEach((opt) => options.push({ value: opt.value, text: opt.textContent }));
  }

  const csrfInfo = document.querySelector("meta[name='csrf-token']");
  const forumId = forumIdNode ? forumIdNode.value : undefined;
  const subject = el.querySelector("[name='message[subject]']").value;
  const authorNode = el.querySelector("[name='message[author]']");
  const author = authorNode ? authorNode.value : "";
  const email = el.querySelector("[name='message[email]']").value;
  const homepage = el.querySelector("[name='message[homepage]']").value;
  const problematicSiteElement = el.querySelector("[name='message[problematic_site]']");
  const problematicSite = problematicSiteElement?.value;
  const saveIdentityElement = el.querySelector("#message_save_identity");
  const saveIdentity = saveIdentityElement ? saveIdentityElement.checked : undefined;

  const errors = gatherErrors(el);

  render(
    <CfPostingForm
      form={el}
      forumId={forumId}
      forumOptions={options}
      subject={subject}
      author={author}
      email={email}
      homepage={homepage}
      text={area.value}
      tags={tags}
      globalTagsError={globalTagsError}
      problematicSite={problematicSite}
      withProblematicSite={!!problematicSiteElement}
      saveIdentity={saveIdentity}
      method={method}
      csrfInfo={{
        param: csrfInfo.getAttribute("csrf-param"),
        token: csrfInfo.getAttribute("content"),
      }}
      errors={errors}
      onCancel={() => window.history.go(-1)}
    />,
    el
  );
});
