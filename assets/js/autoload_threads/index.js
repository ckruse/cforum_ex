const ACTIVE_CONTROLLERS = ["ThreadController"];

if (ACTIVE_CONTROLLERS.includes(document.body.dataset.controller)) {
  import(/* webpackChunkName: "autoload-threads" */ "./autoloading").then(({ default: setupAutoloading }) =>
    setupAutoloading()
  );
}
