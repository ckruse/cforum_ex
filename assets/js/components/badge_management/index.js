const elements = document.querySelectorAll("[data-js='badge-management']");

if (elements.length > 0) {
  import(/* webpackChunkName: "badge_manager" */ "./badge_manager").then(({ default: setupBadgeManager }) => {
    elements.forEach(element => setupBadgeManager(element));
  });
}
