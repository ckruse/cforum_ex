import { queryString } from "../../modules/helpers";

let tm = null;

const MentionsReplacements = {
  trigger: /@[^@\s]+$/,
  type: "mention",
  suggestions: (term, callback) => {
    if (tm) {
      window.clearTimeout(tm);
    }

    if (term.length <= 0) {
      return;
    }

    tm = window.setTimeout(() => {
      const qs = queryString({ s: term.substring(1), self: "no", prefix: "yes" });
      fetch(`/api/v1/users?${qs}`, { credentials: "same-origin" })
        .then((response) => response.json())
        .then((json) => {
          const users = json.map((u) => ({ id: u.user_id, display: "@" + u.username }));
          callback(users);
        });
    }, 400);
  },

  render: ({ id, display }) => display,
  complete: ({ id, display }) => display,
};

export default MentionsReplacements;
