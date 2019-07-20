if (document.body.dataset.controller === "CiteController") {
  if (document.body.dataset.action === "index_voting") {
    import(/* webpackChunkName: "cites" */ "./voting.js").then(({ default: setupVoting }) => setupVoting());
  }

  if (document.body.dataset.action === "new") {
    import(/* webpackChunkName: "cites" */ "./new-cite.js").then(({ default: setupNewCite }) => setupNewCite());
  }
}
