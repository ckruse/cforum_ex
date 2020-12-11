import React from "react";
import { ErrorBoundary } from "@appsignal/react";

import SingleUserSelector from "./single_user_selector";
import MultiUserSelector from "./multi_user_selector";
import appsignal, { FallbackComponent } from "../../appsignal";

export default function UserSelector(props) {
  const Component = props.single ? SingleUserSelector : MultiUserSelector;

  return (
    <ErrorBoundary instance={appsignal} fallback={(error) => <FallbackComponent />}>
      <Component {...props} />
    </ErrorBoundary>
  );
}
