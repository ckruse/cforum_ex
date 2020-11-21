const ACTIVE_CONTROLLERS = ["ThreadController", "MessageController"];

if (ACTIVE_CONTROLLERS.includes(document.body.dataset.controller)) {
  import(/* webpackChunkName: "autoload-threads" */ "./autoloading");
}
