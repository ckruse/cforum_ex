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
    this.setState({ ...this.state, tags: [...this.state.tags, tag] });
  }

  removeTag(tagToRemove) {
    this.setState({ ...this.state, tags: this.state.tags.filter(t => t != tagToRemove) });
  }

  render() {
    return (
      <ul className="cf-cgroup cf-form-tagslist cf-tags-list" aria-live="polite">
        {this.state.tags.map(t => (
          <Tag key={t} tag={t} onClick={() => this.removeTag(t)} />
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
      .map(t => t.value)
      .filter(t => !!t);

    render(<TagList tags={tags} maxTags={maxTags} minTags={minTags} />, el.parentNode);
  });
});
