import React from "react";
import { render } from "react-dom";

import SingleUserSelector from "./single_user_selector";
import MultiUserSelector from "./multi_user_selector";

class UserSelector extends React.Component {
  render() {
    if (this.props.single) {
      return <SingleUserSelector {...this.props} />;
    } else {
      return <MultiUserSelector {...this.props} />;
    }
  }
}

const setupSingleSelector = sel => {
  const userId = sel.value;
  const selfSelect = sel.dataset.userSelectorSelf == "yes";
  const root = document.createElement("div");
  const id = sel.getAttribute("id");

  sel.removeAttribute("id");
  sel.setAttribute("type", "hidden");
  sel.parentNode.insertBefore(root, sel);

  return [root, { id, userId, selfSelect, element: sel }];
};

const setupMultiSelector = element => {
  const users = Array.from(element.querySelectorAll("input[type=hidden]")).map(inp => inp.value);
  const selfSelect = element.dataset.userSelectorSelf == "yes";
  const fieldName = element.dataset.fieldName;
  const root = document.createElement("div");

  element.parentNode.insertBefore(root, element);
  element.parentNode.removeChild(element);

  return [root, { users, selfSelect, fieldName }];
};

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-user-selector='yes'], [data-user-selector='single']").forEach(sel => {
    let props, root;
    if (sel.dataset.dataUserSelector == "single") {
      [root, props] = setupSingleSelector(sel);
    } else {
      [root, props] = setupMultiSelector(sel);
    }

    render(<UserSelector {...props} />, root);
  });
});
