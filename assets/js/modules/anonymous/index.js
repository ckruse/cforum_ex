if (!document.body.dataset.userId) {
  import(/* webpackChunkName: "anonymous" */ "./init").then(({ default: setupAnonynmous }) => setupAnonynmous());
}
