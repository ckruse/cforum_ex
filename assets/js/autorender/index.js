const nodes = document.querySelectorAll(".cf-editor-form");
if (nodes.length > 0) {
  import(/* webpackChunkName: "autorender" */ "./autorender").then(({ default: setupEditors }) => setupEditors(nodes));
}
