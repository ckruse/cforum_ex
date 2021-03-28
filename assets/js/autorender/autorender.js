import React from "react";
import { render } from "react-dom";

import CfEditor from "../components/editor";

const setupEditors = (nodes) => {
  nodes.forEach((el) => {
    const area = el.querySelector("textarea");
    const mentions = el.dataset.mentions == "yes" || false;
    const images = el.dataset.images == "yes";
    const preview = el.dataset.preview != "no";
    const counter = el.dataset.counter != "no";

    render(
      <CfEditor
        text={area.value}
        name={area.name}
        id={area.id}
        withMentions={mentions}
        withImages={images}
        withPreview={preview}
        withCounter={counter}
        errors={{}}
      />,
      el
    );
  });
};

export default setupEditors;
