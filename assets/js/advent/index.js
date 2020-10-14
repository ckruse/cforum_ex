const ADMIN_ACTIONS = ["new", "create", "edit", "update"];
const { controller, action } = document.body.dataset;

if (controller === "AdventController" && action === "show") {
  import(/* webpackChunkName: "advent" */ "./advent.js");
}

if (controller === "Admin.AdventCalendarController" && ADMIN_ACTIONS.includes(action)) {
  import(/* webpackChunkName: "advent" */ "./admin.js");
}
