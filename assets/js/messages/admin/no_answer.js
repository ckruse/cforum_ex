import React from "react";
import { render } from "react-dom";

import { parse } from "../../modules/helpers";
import AdminModal from "./admin_modal";
import { t } from "../../modules/i18n";

export default function forbidAnswer(ev, button) {
  ev.preventDefault();

  const mid = button.dataset.mid;
  const slug = button.dataset.slug;
  const el = document.createElement("div");

  document.body.appendChild(el);

  const closeDialog = () => {
    document.body.removeChild(el);
  };

  render(
    <AdminModal
      messageId={mid}
      slug={slug}
      onClose={closeDialog}
      heading={t("forbid answering to this message")}
      noReasonActionText={t("forbid answering to this message without public reason")}
      reasonActionText={t("forbid answering to this message")}
      noReasonAction={() => closeMessage(button, slug, mid, true)}
      reasonAction={(reason, customReason) => closeMessage(button, slug, mid, false, reason, customReason)}
    />,
    el
  );
}

async function closeMessage(button, slug, messageId, noPublicReason, reason, customReason) {
  button.classList.add("loading");

  const response = await fetch("/api/v1/messages/no-answer", {
    method: "POST",
    credentials: "same-origin",
    cache: "no-cache",
    headers: { "Content-Type": "application/json; charset=utf-8" },
    body: JSON.stringify({
      slug,
      message_id: messageId,
      forum: document.body.dataset.currentForum,
      reason,
      custom: customReason,
      no_reason: noPublicReason,
    }),
  });

  const html = await response.text();
  const node = parse(html);
  const message = document.getElementById("tree-m" + messageId) || document.getElementById("m" + messageId);
  message.closest(".cf-thread").replaceWith(node);

  button.classList.remove("loading");

  const btt = document.querySelector(`.admin-links button[data-js="no-answer"][data-mid="${messageId}"]`);
  if (btt) {
    btt.dataset.js = "answer";
    btt.textContent = t("allow answering to this message");
  }
}
