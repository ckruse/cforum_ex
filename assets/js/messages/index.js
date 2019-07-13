if (document.body.dataset.controller === "MessageController") {
  if (document.body.dataset.action === "show") {
    import(/* webpackChunkName: "vendor" */ "katex/dist/katex.min.css");

    import(/* webpackChunkName: "messages-show" */ "./inline_forms").then(({ default: showInlineForm }) => {
      document.querySelectorAll('[data-action="answer"]').forEach(el => el.addEventListener("click", showInlineForm));
    });

    import(/* webpackChunkName: "messages-show" */ "./voting");
  }

  if (document.body.classList.contains("nested-view")) {
    import(/* webpackChunkName: "messages-show" */ "./nested_view").then(({ default: initNestedView }) =>
      initNestedView()
    );
  }
}

if (["MessageController", "ThreadController"].includes(document.body.dataset.controller)) {
  if (["new", "edit", "update", "create"].includes(document.body.dataset.action)) {
    import(/* webpackChunkName: "messages-threads" */ "./postingform").then(({ default: setupContentForms }) =>
      setupContentForms()
    );
  }
}

if (document.body.dataset.controller === "Messages.RetagController") {
  import(/* webpackChunkName: "messages" */ "./retag").then(({ default: setupTaglist }) => setupTaglist());
}
