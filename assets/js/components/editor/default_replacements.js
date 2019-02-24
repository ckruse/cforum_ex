import React from "react";

import { t } from "../../modules/i18n";

const DefaultReplacements = {
  trigger: /((=>|<=|<=>|"|\.\.\.|\*|->|<-|-{1,3}|\^|\[tm\]?|=\/=?|=))$/,
  type: "default",
  data: term => {
    let found = [];

    switch (term) {
      case '"':
        found = [{ id: '""', display: '""' }, { id: "„“", display: "„“" }, { id: "‚‘", display: "‚‘" }];
        break;

      case "...":
        found = [{ id: "…", display: "…" }];
        break;

      case "---":
        found = [{ id: "—", display: "—", desc: `— ${t("(em dash sign)")}` }];
        break;
      case "--":
        found = [
          { id: "–", display: "–", desc: `– ${t("(en dash sign)")}` },
          { id: "—", display: "—", desc: `— ${t("(em dash sign)")}` }
        ];
        break;
      case "-":
        found = [
          { id: "-", display: "-", desc: `- ${t("(hyphen minus)")}` },
          { id: "−", display: "−", desc: `− ${t("(minus sign)")}` },
          { id: "–", display: "–", desc: `– ${t("(en dash sign)")}` }
        ];
        break;

      case "*":
        found = [{ id: "×", display: "×" }];
        break;

      case "->":
        found = [
          { id: "→", display: "→" },
          { id: "←", display: "←" },
          { id: "↑", display: "↑" },
          { id: "↓", display: "↓" }
        ];
        break;
      case "<-":
        found = [
          { id: "←", display: "←" },
          { id: "→", display: "→" },
          { id: "↑", display: "↑" },
          { id: "↓", display: "↓" }
        ];
        break;

      case "^":
        found = [
          { id: "↑", display: "↑" },
          { id: "▲", display: "▲" },
          { id: "←", display: "←" },
          { id: "→", display: "→" },
          { id: "↓", display: "↓" }
        ];
        break;

      case "=>":
        found = [{ id: "⇒", display: "⇒" }, { id: "⇐", display: "⇐" }, { id: "⇔", display: "⇔" }];
        break;
      case "<=":
        found = [{ id: "⇐", display: "⇐" }, { id: "⇒", display: "⇒" }, { id: "⇔", display: "⇔" }];
        break;

      case "<=>":
        found = [{ id: "⇔", display: "⇔" }, { id: "⇐", display: "⇐" }, { id: "⇒", display: "⇒" }];
        break;

      case "[tm":
      case "[tm]":
        found = [{ id: "™", display: "™" }];
        break;

      case "=":
      case "=/":
      case "=/=":
        found = [{ id: "≠", display: "≠" }, { id: "≈", display: "≈" }];
        break;

      default:
        found = [];
    }

    return found;
  },

  renderSuggestion: (suggestion, _search, highlightedDisplay, _index, _focused) => {
    if (suggestion.desc) {
      return <span {...highlightedDisplay.props}>{suggestion.desc}</span>;
    }

    return highlightedDisplay;
  }
};

export default DefaultReplacements;
