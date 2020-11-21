if (!document.body.dataset.userId) {
  import(/* webpackChunkName: "anonymous" */ "./init");
}
