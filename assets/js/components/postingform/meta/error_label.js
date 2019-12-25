import React from "react";
import { getError } from "./utils";

export default function ErrorLabel({ errors, field, values, children, touched }) {
  const error = getError(field, errors, values, touched);

  return (
    <label htmlFor={field}>
      {children}
      {error && (
        <>
          {" "}
          <span className="help error">{error}</span>
        </>
      )}
    </label>
  );
}
