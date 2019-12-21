if (document.body.dataset.controller === "AdventController") {
  import(/* webpackChunkName: "advent" */ "./advent.js");
}

const ADMIN_ACTIONS = ["new", "create", "edit", "update"];
const { controller, action } = document.body.dataset;

if (controller === "Admin.AdventCalendarController" && ADMIN_ACTIONS.includes(action)) {
  import(/* webpackChunkName: "advent" */ "./admin.js");
}
