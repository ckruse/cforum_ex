import { queryString, parse, conf, parseMessageUrl } from "../modules/helpers";
import { setNewFavicon } from "../title_infos";

const NEW_MESSAGES = [];

const insertRenderedThread = (thread, message, html, id_prefix) => {
  const node = parse(html).firstChild;
  const sortThreads = conf("sort_threads");
  const threadlist = document.querySelector(".cf-thread-list");
  const originalNode = document.getElementById(node.id);
  const viewedMessageUrl =
    document.body.dataset.controller === "MessageController" ? parseMessageUrl(document.location.href) : {};
  const messageNode = node.querySelector(`#${id_prefix}m${message.message_id}`);

  if (messageNode) {
    const svgNode = parse(
      '<svg class="new-svg" width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><use xlink:href="/images/icons.svg#svg-new"></use></svg>'
    ).firstChild;

    messageNode.classList.add("new");
    messageNode.querySelector(".details").appendChild(svgNode);
  }

  switch (sortThreads) {
    case "ascending":
    case "descending":
      if (originalNode) {
        originalNode.replaceWith(node);
        return;
      }

      if (sortThreads === "ascending") {
        threadlist.appendChild(node);
      } else {
        threadlist.insertBefore(node, threadlist.querySelector(".cf-thread:not(.sticky)"));
      }

      break;

    // "newest-first" is the default
    default:
      if (originalNode) {
        originalNode.remove();
      }

      threadlist.insertBefore(node, threadlist.querySelector(".cf-thread:not(.sticky)"));
  }

  if (viewedMessageUrl.messageId) {
    const el = document.getElementById("tree-m" + viewedMessageUrl.messageId);
    if (el) {
      el.classList.add("active");
    }
  }
};

const autoloadMessage = async (ev) => {
  const { thread, message, forum } = ev.detail.data;
  const isMsg = document.body.dataset.controller === "MessageController";
  const id_prefix = isMsg ? "tree-" : "";

  if (isMsg && !document.getElementById(thread.thread_id)) {
    return;
  }

  if (!["all", forum.slug].includes(document.body.dataset.currentForum)) {
    return;
  }

  const slug = document.body.dataset.currentForum === "all" ? "all" : forum.slug;

  NEW_MESSAGES.push(message.message_id);

  const qs = queryString({
    message_id: message.message_id,
    invisible: "no",
    id_prefix,
    index: isMsg ? "no" : "yes",
    fold: isMsg ? "no" : "yes",
  });

  const rsp = await fetch(`/${slug}${thread.slug}?${qs}`, { credentials: "same-origin" });

  if (!rsp.ok) {
    return;
  }

  const text = await rsp.text();

  if (!text) {
    return;
  }

  setNewFavicon();
  insertRenderedThread(thread, message, text, id_prefix);
};

export default () => document.addEventListener("cf:newMessage", autoloadMessage);
