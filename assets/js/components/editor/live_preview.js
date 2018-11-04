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

  render() {
    return (
      <article className="cf-thread-message cf-preview">
        <h3>{t("preview")}</h3>

        <div
          className="cf-posting-content"
          dangerouslySetInnerHTML={{ __html: this.mdparser.render(this.props.content) }}
        />
      </article>
    );
  }
}

export default LivePreview;
