import React, { useEffect } from "react";

import { t } from "../../modules/i18n";
import CfMarkdown from "cfmarkdown";

const mdparser = CfMarkdown({
  quotes: "„“‚‘",
  headerStartIndex: 3,
});

export default function LivePreview({ content }) {
  useEffect(() => {
    if (window.MathJax && window.MathJax.Hub) {
      window.MathJax.Hub.Queue(["Typeset", window.MathJax.Hub]);
    }

    if (window?.Prism?.highlightAll) {
      window.setTimeout(window.Prism.highlightAll, 0);
    }
  }, [content]);

  const fixedContent = CfMarkdown.manualFixes(content);

  return (
    <article className="cf-thread-message cf-preview">
      <h3>{t("preview")}</h3>

      <div className="cf-posting-content" dangerouslySetInnerHTML={{ __html: mdparser.render(fixedContent) }} />
    </article>
  );
}
