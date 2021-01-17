import React, { useEffect, useState } from "react";
import CfMarkdown from "cfmarkdown";

import { t } from "../modules/i18n";

const mdparser = CfMarkdown({
  quotes: "„“‚‘",
  headerStartIndex: 3,
  html: true,
});

export default function LivePreview({ excerpt, content, thumbnail }) {
  const [thumb, setThumb] = useState(undefined);

  useEffect(() => {
    if (window.MathJax && window.MathJax.Hub) {
      window.MathJax.Hub.Queue(["Typeset", window.MathJax.Hub]);
    }
  }, [excerpt, content]);

  useEffect(() => {
    if (thumbnail) {
      readFile(thumbnail);
    }
  }, [thumbnail]);

  function readFile(file) {
    const reader = new FileReader();
    reader.onloadend = () => setThumb(reader.result);
    reader.readAsDataURL(file);
  }

  const fixedExcerpt = excerpt ? CfMarkdown.manualFixes(excerpt) : null;
  const fixedContent = CfMarkdown.manualFixes(content);

  return (
    <article className="cf-weblog-article cf-preview">
      <h3>{t("preview")}</h3>

      {thumb && <img src={thumb} className="cf-weblog-article-thumbnail" alt="" />}

      <div className="e-content">
        {fixedExcerpt && (
          <div className="excerpt" dangerouslySetInnerHTML={{ __html: mdparser.render(fixedExcerpt) }} />
        )}
        <div dangerouslySetInnerHTML={{ __html: mdparser.render(fixedContent) }} />
      </div>
    </article>
  );
}
