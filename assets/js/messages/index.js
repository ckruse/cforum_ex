import { isInAdminView } from "../modules/helpers";

const controllers = ["Blog.ArticleController", "MessageController"];

if (controllers.includes(document.body.dataset.controller)) {
  if (document.body.dataset.action === "show") {
    import(/* webpackChunkName: "messages-show" */ "./inline_forms").then(({ default: showInlineForm }) => {
      document.querySelectorAll('[data-action="answer"]').forEach((el) => el.addEventListener("click", showInlineForm));
    });

    import(/* webpackChunkName: "messages-show" */ "./voting");
    import(/* webpackChunkName: "messages-show" */ "./message_actions");
  }

  if (document.body.classList.contains("nested-view")) {
    import(/* webpackChunkName: "messages-show-nested" */ "./nested_view");
  }
}

if (["MessageController", "ThreadController", "Blog.CommentController"].includes(document.body.dataset.controller)) {
  if (["new", "edit", "update", "create"].includes(document.body.dataset.action)) {
    import(/* webpackChunkName: "messages-threads" */ "./postingform");
  }
}

if (document.body.dataset.controller === "Messages.RetagController") {
  import(/* webpackChunkName: "messages" */ "./retag");
}

const ACTIVE_CONTROLLERS = ["MessageController", "ThreadController"];
if (isInAdminView() && ACTIVE_CONTROLLERS.includes(document.body.dataset.controller)) {
  import(/* webpackChunkName: "message-admin-actions" */ "./admin");
}
