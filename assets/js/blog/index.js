const isBlogpost = document.body.dataset.controller === "BlogpostController";
const action = document.body.dataset.action;

if (isBlogpost && ["new", "create"].includes(action)) {
  import("./postingform");
}
