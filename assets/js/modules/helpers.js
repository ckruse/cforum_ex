export const queryString = function(params) {
  return Object.keys(params)
    .map(k => {
      if (Array.isArray(params[k])) {
        return params[k].map(val => `${encodeURIComponent(k)}[]=${encodeURIComponent(val)}`).join("&");
      }

      return `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`;
    })
    .join("&");
};

export const unique = (list, finder) => {
  if (!finder) {
    finder = (ary, elem) => ary.indexOf(elem);
  }

  return list.filter((elem, pos, ary) => {
    return finder(ary, elem) == pos;
  });
};

export function clearChildren(element) {
  while (element.firstChild) {
    element.firstChild.remove();
  }

  return element;
}

export function parse(markup) {
  const fragment = document.createDocumentFragment();
  const div = document.createElement("div");

  div.innerHTML = markup;
  Array.from(div.childNodes).forEach(child => fragment.appendChild(child));

  return fragment;
}
