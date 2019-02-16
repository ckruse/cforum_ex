import React from "react";
import { render } from "react-dom";

import { parseMessageUrl } from "./modules/helpers";
import CfPostingForm from "./components/postingform";

const showInlineForm = ev => {
  ev.preventDefault();

  const messageElement = ev.target.closest(".cf-thread-message");

  const parsedUrl = parseMessageUrl(document.location.href);
  const messageId = messageElement.querySelector(".cf-message-header").id;
  const url = new URL("/api/v1/messages/quote", document.location.origin);
  url.searchParams.append("forum", document.body.dataset.currentForum);
  url.searchParams.append("slug", parsedUrl.slug);
  url.searchParams.append("message_id", messageId.replace(/^m/, ""));

  if (ev.target.dataset.quote === "yes") {
    url.searchParams.append("with_quote", "yes");
  }

  fetch(url, {
    method: "GET",
    credentials: "same-origin",
    cache: "no-cache",
    headers: { "Content-Type": "application/json; charset=utf-8" }
  })
    .then(response => response.json())
    .then(json => showForm(messageElement, json));
};

const transformNewlines = text => text.replace(/\015\012|\015|\012/g, "\n");

const showForm = (messageElement, json) => {
  const selector = ".posting-header > .cf-message-header > h2 > a, .posting-header > .cf-message-header > h3 > a";
  const href = messageElement.querySelector(selector).href;
  const parsedUrl = parseMessageUrl(href);

  const csrfInfo = document.querySelector("meta[name='csrf-token']");

  document.querySelectorAll(".cf-posting-form").forEach(el => el.remove());

  const node = document.createElement("form");
  node.classList.add("cf-form");
  node.classList.add("cf-posting-form");
  node.action = "/" + parsedUrl.forum + parsedUrl.slug + "/" + parsedUrl.messageId + "/new";
  node.method = "POST";

  messageElement.parentNode.insertBefore(node, messageElement.nextSibling);

  const tags = json.tags.map(t => [t, null]);

  render(
    <CfPostingForm
      subject={json.subject}
      text={transformNewlines(json.content)}
      author={json.author}
      tags={tags}
      problematicSite={json.problematic_site}
      email={json.email}
      homepage={json.homepage}
      csrfInfo={{
        param: csrfInfo.getAttribute("csrf-param"),
        token: csrfInfo.getAttribute("content")
      }}
      onCancel={() => node.remove()}
    />,
    node,
    () => {
      const el = document.querySelector("[name='message[author]'][value=''], [name='message[content]']");
      el.focus();
      setCursorInTextarea(el);
    }
  );
};

const setCursorInTextarea = el => {
  if (el.nodeName !== "TEXTAREA" || !el.value) {
    return;
  }

  if (el.value.match(/^(.*\n\n?)/)) {
    el.setSelectionRange(RegExp.$1.length, RegExp.$1.length);
  }
};

if (document.body.dataset.controller === "MessageController" && document.body.dataset.action === "show") {
  document.querySelectorAll('[data-action="answer"]').forEach(el => el.addEventListener("click", showInlineForm));
}
