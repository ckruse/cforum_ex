import React from "react";
import { render } from "react-dom";
import CfPostingForm from "../components/postingform";

const cancel = ev => {
  ev.preventDefault();
  document.location.href = "/";
};

const setupContentForms = () => {
  document.querySelectorAll(".cf-posting-form").forEach(el => {
    const area = el.querySelector("textarea");
    const tags = Array.from(el.querySelectorAll('input[data-tag="yes"]'))
      .filter(t => !!t.value)
      .map(t => {
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
    const subject = el.querySelector("input[name='message[subject]']").value;
    const authorNode = el.querySelector("input[name='message[author]']");
    const author = authorNode ? authorNode.value : "";
    const email = el.querySelector("input[name='message[email]']").value;
    const homepage = el.querySelector("input[name='message[homepage]']").value;
    const problematicSite = el.querySelector("input[name='message[problematic_site]']").value;

    render(
      <CfPostingForm
        form={el}
        subject={subject}
        author={author}
        email={email}
        homepage={homepage}
        text={area.value}
        tags={tags}
        globalTagsError={globalTagsError}
        problematicSite={problematicSite}
        csrfInfo={{
          param: csrfInfo.getAttribute("csrf-param"),
          token: csrfInfo.getAttribute("content")
        }}
        onCancel={cancel}
      />,
      el
    );
  });
};

export default setupContentForms;
