import React from "react";
import { render } from "react-dom";
import CfContentForm from "../components/contentform";

const setupContentForms = () => {
  document.querySelectorAll(".cf-content-form").forEach(el => {
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

    render(<CfContentForm text={area.value} name={area.name} tags={tags} globalTagsError={globalTagsError} />, el);
  });
};

export default setupContentForms;
