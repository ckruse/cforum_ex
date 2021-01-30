import React from "react";
import { ErrorBoundary } from "@appsignal/react";

import appsignal, { FallbackComponent } from "./appsignal";

export default function Boundary({ children }) {
  if (process.env.NODE_ENV === "production") {
    return (
      <ErrorBoundary instance={appsignal} fallback={(error) => <FallbackComponent />}>
        {children}
      </ErrorBoundary>
    );
  }

  return <>{children}</>;
}
