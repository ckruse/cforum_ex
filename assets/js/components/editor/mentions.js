import { queryString } from "../../modules/helpers";

let tm = null;

const MentionsReplacements = {
  trigger: "@",
  type: "mention",
  data: (term, callback) => {
    if (tm) {
      window.clearTimeout(tm);
    }

    if (term.length <= 0) {
      return [];
    }

    tm = window.setTimeout(() => {
      const qs = queryString({ s: term, self: "no", prefix: "yes" });
      fetch(`/api/v1/users?${qs}`, { credentials: "same-origin" })
        .then(response => response.json())
        .then(json => {
          const users = json.map(u => ({ id: u.user_id, display: "@" + u.username }));
          callback(users);
        });
    }, 400);
  }
};

export default MentionsReplacements;
