import React from "react";
import { render } from "react-dom";

import CfEditor from "../components/editor";

const setupEditors = nodes => {
  nodes.forEach(el => {
    const area = el.querySelector("textarea");

    render(<CfEditor text={area.value} name={area.name} mentions={false} />, el);
  });
};

export default setupEditors;
