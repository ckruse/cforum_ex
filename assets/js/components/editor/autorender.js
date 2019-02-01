import React from "react";
import { render } from "react-dom";

import CfEditor from "./";

document.querySelectorAll(".cf-editor-form").forEach(el => {
  const area = el.querySelector("textarea");

  render(<CfEditor text={area.value} name={area.name} mentions={false} />, el);
});
