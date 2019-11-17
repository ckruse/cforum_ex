import React from "react";
import { render } from "react-dom";

import { parse } from "../../modules/helpers";
import { t } from "../../modules/i18n";
import AdminModal from "./admin_modal";

export default function showDeleteMessage(ev, button) {
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
      heading={t("delete message")}
      noReasonActionText={t("delete message without public reason")}
      reasonActionText={t("delete message")}
      noReasonAction={() => deleteMessage(slug, mid, true)}
      reasonAction={(reason, customReason) => deleteMessage(slug, mid, false, reason, customReason)}
    />,
    el
  );
}

async function deleteMessage(slug, messageId, completelyDelete, reason = null, customReason = null) {
  const response = await fetch("/api/v1/messages/delete", {
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
      no_reason: completelyDelete
    })
  });

  const html = await response.text();
  const node = parse(html);
  const message = document.getElementById("tree-m" + messageId) || document.getElementById("m" + messageId);
  message.closest(".cf-thread").replaceWith(node);
}
