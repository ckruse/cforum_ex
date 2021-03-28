import React, { useEffect, useState } from "react";

import CfEditor from "../editor";
import TagList from "../taglist";

export default function CfContentForm({ text, tags, id, name, errors, globalTagsError, onTagChange, onTextChange }) {
  const [value, setValue] = useState(text);

  function refreshSuggestions(newValue) {
    setValue(newValue);

    if (onTextChange) {
      onTextChange(newValue);
    }
  }

  useEffect(() => {
    setValue(text);
  }, [text]);

  return (
    <>
      <CfEditor
        text={value}
        name={name}
        id={id}
        withMentions={true}
        onChange={refreshSuggestions}
        withImages={true}
        errors={errors}
      />
      <TagList tags={tags} postingText={value} globalTagsError={globalTagsError} onChange={onTagChange} />
    </>
  );
}
