import React from "react";

import { t } from "../../modules/i18n";
import CfMarkdown from "cfmarkdown";

class LivePreview extends React.Component {
  constructor(props) {
    super(props);

    this.mdparser = CfMarkdown({
      quotes: "„“‚‘",
      headerStartIndex: 3
    });
  }

  componentDidUpdate(prevProps) {
    if (prevProps.content !== this.props.content && window.MathJax && window.MathJax.Hub) {
      window.MathJax.Hub.Queue(["Typeset", window.MathJax.Hub]);
    }
  }

  render() {
    const fixedContent = CfMarkdown.manualFixes(this.props.content);

    return (
      <article className="cf-thread-message cf-preview">
        <h3>{t("preview")}</h3>

        <div className="cf-posting-content" dangerouslySetInnerHTML={{ __html: this.mdparser.render(fixedContent) }} />
      </article>
    );
  }
}

export default LivePreview;
