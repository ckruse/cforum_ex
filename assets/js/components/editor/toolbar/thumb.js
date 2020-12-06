import React, { useEffect, useState } from "react";

export default function Thumb({ file }) {
  const [loading, setLoading] = useState(false);
  const [thumb, setThumb] = useState(undefined);

  useEffect(() => {
    if (file) {
      readFile(file);
    }
  }, [file]);

  function readFile(file) {
    const reader = new FileReader();
    reader.onloadend = () => {
      setLoading(false);
      setThumb(reader.result);
    };
    reader.readAsDataURL(file);
  }

  if (loading || !file || !thumb) {
    return null;
  }

  return <img src={thumb} alt={file.name} className="cf-dropzone-thumbnail" />;
}
