import "./read_status";
import "./scoring";

export const getMessageTreeElement = (id) => {
  return document.querySelector(`.cf-thread-list #tree-m${id}, .cf-thread-list #m${id}`);
};
