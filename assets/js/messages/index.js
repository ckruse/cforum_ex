if (document.body.dataset.controller === "MessageController") {
  if (document.body.dataset.action === "show") {
    import(/* webpackChunkName: "messages" */ "./inline_forms").then(({ default: showInlineForm }) => {
      document.querySelectorAll('[data-action="answer"]').forEach(el => el.addEventListener("click", showInlineForm));
    });
  }

  if (document.body.classList.contains("nested-view")) {
    import(/* webpackChunkName: "messages" */ "./nested_view").then(({ default: initNestedView }) => initNestedView());
  }
}

if (["MessageController", "ThreadController"].includes(document.body.dataset.controller)) {
  if (["new", "edit", "update", "create"].includes(document.body.dataset.action)) {
    import(/* webpackChunkName: "messages" */ "./postingform").then(({ default: setupContentForms }) =>
      setupContentForms()
    );
  }
}

if (document.body.dataset.controller === "Messages.RetagController") {
  import(/* webpackChunkName: "messages" */ "./retag").then(({ default: setupTaglist }) => setupTaglist());
}
