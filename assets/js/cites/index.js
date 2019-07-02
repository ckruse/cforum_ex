if(document.body.dataset.controller === "CiteController" && document.body.dataset.action === "index_voting") {
  import(/* webpackChunkName: "cites" */ "./voting.js").then(({ default: setupVoting }) => setupVoting());
}
