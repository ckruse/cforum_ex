export const queryString = function (params) {
  return Object.keys(params)
    .map((k) => {
      if (Array.isArray(params[k])) {
        return params[k].map((val) => `${encodeURIComponent(k)}[]=${encodeURIComponent(val)}`).join("&");
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
    return finder(ary, elem) === pos;
  });
};

export const clearChildren = (element) => {
  while (element.firstChild) {
    element.firstChild.remove();
  }

  return element;
};

export const parse = (markup) => {
  const fragment = document.createDocumentFragment();
  const div = document.createElement("div");

  div.innerHTML = markup;
  Array.from(div.childNodes).forEach((child) => fragment.appendChild(child));

  return fragment;
};

export const parseMessageUrl = (url) => {
  try {
    url = new URL(url);
  } catch (e) {
    return null;
  }

  const path = url.pathname;
  const ret = {};

  if (path.match(/^(?:\/(\w+))?(\/\d{4}\/\w{3}\/\d{1,2}\/[\w-]+)(?:\/(\d+))?(?:\/([\w-]+))?$/)) {
    ret.forum = RegExp.$1;
    ret.slug = RegExp.$2;
    ret.messageId = RegExp.$3;
    ret.action = RegExp.$4;

    return ret;
  }

  return null;
};

export const conf = (nam) => (window.currentConfig && window.currentConfig[nam]) || null;

export const uniqueId = (len = 5) => Math.random().toString(36).substr(2, len);

export const isInAdminView = () =>
  document.location.search.indexOf("view_all=yes") !== -1 && !!document.querySelector("#admin-view");
