const SmileyReplacements = {
  trigger: /((:-?\)|;-?\)|:-?D|:-?P|:-?\(|:-?O|:-?\||:-?\/|:-?x|m\()$)/i,
  type: "smiley",
  data: term => {
    if (term.length <= 0) {
      return [];
    }

    let found = [];
    term = term.toUpperCase();

    switch (term) {
      case ":-)":
      case ":)":
        found = [{ id: "😀", display: "😀" }];
        break;
      case ";-)":
      case ";)":
        found = [{ id: "😉", display: "😉" }];
        break;
      case ":-D":
      case ":D":
        found = [{ id: "😂", display: "😂" }];
        break;
      case ":-P":
      case ":P":
        found = [{ id: "😝", display: "😝" }, { id: "😛", display: "😛" }, { id: "😜", display: "😜" }];
        break;
      case ":-(":
      case ":(":
        found = [{ id: "😟", display: "😟" }];
        break;
      case ":-O":
      case ":O":
        found = [{ id: "😱", display: "😱" }, { id: "😨", display: "😨" }];
        break;
      case ":-|":
      case ":|":
        found = [{ id: "😐", display: "😐" }, { id: "😑", display: "😑" }];
        break;
      case ":-/":
      case ":/":
        found = [{ id: "😕", display: "😕" }, { id: "😏", display: "😏" }];
        break;
      case "M(":
        found = [{ id: "🤦", display: "🤦" }];
        break;
      case ":-X":
      case ":X":
        found = [
          { id: "😘", display: "😘" },
          { id: "😗", display: "😗" },
          { id: "😙", display: "😙" },
          { id: "😚", display: "😚" }
        ];
        break;

      default:
        found = [];
    }

    return found;
  }
};

export default SmileyReplacements;
