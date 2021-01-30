import React from "react";

import SingleUserSelector from "./single_user_selector";
import MultiUserSelector from "./multi_user_selector";
import Boundary from "../../Boundary";

export default function UserSelector(props) {
  const Component = props.single ? SingleUserSelector : MultiUserSelector;

  return (
    <Boundary>
      <Component {...props} />
    </Boundary>
  );
}
