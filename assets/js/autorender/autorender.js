import React from "react";
import { render } from "react-dom";

import CfEditor from "../components/editor";

const setupEditors = nodes => {
  nodes.forEach(el => {
    const area = el.querySelector("textarea");

    render(<CfEditor text={area.value} name={area.name} id={area.id} mentions={false} errors={{}} />, el);
  });
};

export default setupEditors;
