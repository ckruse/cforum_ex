import React from "react";

import { t } from "../../modules/i18n";

const DefaultReplacements = {
  trigger: /((=>|<=|<=>|"|\.\.\.|\*|->|<-|-{1,3}|\^|\[tm\]?|=\/=?|=))$/,
  type: "default",
  suggestions: (term, cb) => {
    let found = [];

    switch (term) {
      case '"':
        found = [
          { id: '""', display: '""' },
          { id: "„“", display: "„“" },
          { id: "‚‘", display: "‚‘" },
        ];
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
          { id: "—", display: "—", desc: `— ${t("(em dash sign)")}` },
        ];
        break;

      case "-":
        found = [
          { id: "-", display: "-", desc: `- ${t("(hyphen minus)")}` },
          { id: "−", display: "−", desc: `− ${t("(minus sign)")}` },
          { id: "–", display: "–", desc: `– ${t("(en dash sign)")}` },
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
          { id: "↓", display: "↓" },
        ];
        break;

      case "<-":
        found = [
          { id: "←", display: "←" },
          { id: "→", display: "→" },
          { id: "↑", display: "↑" },
          { id: "↓", display: "↓" },
        ];
        break;

      case "^":
        found = [
          { id: "↑", display: "↑" },
          { id: "▲", display: "▲" },
          { id: "←", display: "←" },
          { id: "→", display: "→" },
          { id: "↓", display: "↓" },
        ];
        break;

      case "=>":
        found = [
          { id: "⇒", display: "⇒" },
          { id: "⇐", display: "⇐" },
          { id: "⇔", display: "⇔" },
        ];
        break;

      case "<=":
        found = [
          { id: "⇐", display: "⇐" },
          { id: "⇒", display: "⇒" },
          { id: "⇔", display: "⇔" },
        ];
        break;

      case "<=>":
        found = [
          { id: "⇔", display: "⇔" },
          { id: "⇐", display: "⇐" },
          { id: "⇒", display: "⇒" },
        ];
        break;

      case "[tm":
      case "[tm]":
        found = [{ id: "™", display: "™" }];
        break;

      case "=":
      case "=/":
      case "=/=":
        found = [
          { id: "≠", display: "≠" },
          { id: "≈", display: "≈" },
        ];
        break;

      default:
        found = [];
    }

    return cb(found);
  },

  render: (suggestion) => {
    if (suggestion.desc) {
      return <>{suggestion.desc}</>;
    }

    return <>{suggestion.display}</>;
  },
  complete: ({ id, display }) => display,
  cursorPosition: ({ start, end }, value) => {
    if (['""', "„“", "‚‘"].includes(value)) {
      return { start: start - 1, end: end - 1 };
    }

    return { start, end };
  },
};

export default DefaultReplacements;
