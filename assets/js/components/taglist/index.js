import React from "react";
import { render } from "react-dom";

import Tag from "./tag";
import NewTagInput from "./new_tag_input";

class TagList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      tags: [...this.props.tags]
    };

    this.addTag = this.addTag.bind(this);
  }

  addTag(tag) {
    this.setState({ ...this.state, tags: [...this.state.tags, [tag, null]] });
  }

  removeTag(tagToRemove) {
    this.setState({ ...this.state, tags: this.state.tags.filter(([t, _]) => t != tagToRemove) });
  }

  render() {
    return (
      <ul className="cf-cgroup cf-form-tagslist cf-tags-list" aria-live="polite">
        {this.state.tags.map(([tag, err]) => (
          <Tag key={tag} tag={tag} error={err} onClick={() => this.removeTag(tag)} />
        ))}

        {this.state.tags.length < this.props.maxTags && (
          <NewTagInput onChoose={this.addTag} existingTags={this.state.tags} />
        )}
      </ul>
    );
  }
}

document.addEventListener("DOMContentLoaded", () => {
  // TODO get these values from config
  const maxTags = 3;
  const minTags = 1;

  document.querySelectorAll('[data-tags-list="form"]').forEach(el => {
    const tags = Array.from(el.querySelectorAll('input[data-tag="yes"]'))
      .filter(t => !!t.value)
      .map(t => {
        const elem = t.previousElementSibling.querySelector(".error");
        return [t.value, elem ? elem.textContent : null];
      });

    render(<TagList tags={tags} maxTags={maxTags} minTags={minTags} />, el.parentNode);
  });
});
