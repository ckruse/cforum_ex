const isBlogpost = document.body.dataset.controller === "Blog.ArticleController";
const action = document.body.dataset.action;

if (isBlogpost && ["new", "create"].includes(action)) {
  import("./postingform");
}
