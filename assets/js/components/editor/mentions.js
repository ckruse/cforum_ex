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

    tm = window.setTimeout(async () => {
      const qs = queryString({ s: term.substring(1), self: "no", prefix: "yes" });
      const rsp = await fetch(`/api/v1/users?${qs}`, { credentials: "same-origin" });
      const json = await rsp.json();
      const users = json.map((u) => ({ id: u.user_id, display: "@" + u.username }));
      callback(users);
    }, 400);
  },

  render: ({ id, display }) => display,
  complete: ({ id, display }) => display,
};

export default MentionsReplacements;
