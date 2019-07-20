document.addEventListener("DOMContentLoaded", () => {
  const nodes = document.querySelectorAll("[data-user-selector='yes'], [data-user-selector='single']");

  if (nodes.length > 0) {
    import(/* webpackChunkName: "user-selector" */ "./user-selector").then(({ default: setupUserSelectors }) =>
      setupUserSelectors(nodes)
    );
  }
});
