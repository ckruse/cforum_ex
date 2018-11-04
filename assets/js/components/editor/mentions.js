import { queryString } from "../../modules/helpers";

const MentionsReplacements = {
  trigger: "@",
  type: "mention",
  data: (term, callback) => {
    if (term.length <= 0) {
      return [];
    }

    const qs = queryString({ s: term, self: "no", prefix: "yes" });
    fetch(`/api/v1/users?${qs}`, { credentials: "same-origin" })
      .then(response => response.json())
      .then(json => {
        const users = json.map(u => ({ id: u.user_id, display: "@" + u.username }));
        callback(users);
      });
  }
};

export default MentionsReplacements;
