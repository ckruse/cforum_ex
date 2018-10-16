import React from "react";
import { render } from "react-dom";
import { CSSTransitionGroup } from "react-transition-group";

import Tag from "./tag";
import NewTagInput from "./new_tag_input";
import { conf } from "../../modules/helpers";
import { t } from "../../modules/i18n";

class TagList extends React.Component {
  constructor(props) {
    super(props);

    document.addEventListener("cf:configDidLoad", () => {
      const minTags = conf("min_tags_per_message") || 1;
      const maxTags = conf("max_tags_per_message") || 3;
      this.setState({ minTags, maxTags });
    });

    const minTags = conf("min_tags_per_message") || 1;
    const maxTags = conf("max_tags_per_message") || 3;

    this.state = {
      tags: [...this.props.tags],
      allTags: [],
      minTags,
      maxTags
    };

    this.addTag = this.addTag.bind(this);
    this.checkForError = this.checkForError.bind(this);

    const slug = document.location.pathname.split("/")[1];
    fetch(`/api/v1/tags?f=${slug}`, { credentials: "same-origin" })
      .then(json => json.json())
      .then(json => {
        json.sort((a, b) => b.num_messages - a.num_messages);
        this.setState({ allTags: json });
      })
      .catch(e => console.log(e));
  }

  checkForError(tag) {
    if (!this.state.allTags.find(tg => tg.tag_name == tag)) {
      return t("is unknown");
    }

    return null;
  }

  addTag(tag) {
    this.setState({ tags: [...this.state.tags, [tag, this.checkForError(tag)]] });
  }

  removeTag(tagToRemove) {
    this.setState({ tags: this.state.tags.filter(([t, _]) => t != tagToRemove) });
  }

  render() {
    return (
      <CSSTransitionGroup
        component="ul"
        className="cf-cgroup cf-form-tagslist cf-tags-list"
        aria-live="polite"
        transitionName="fade-in"
        transitionEnterTimeout={300}
        transitionLeaveTimeout={300}
      >
        {this.state.tags.map(([tag, err]) => (
          <Tag key={tag} tag={tag} error={err} onClick={() => this.removeTag(tag)} />
        ))}

        {this.state.tags.length < this.state.maxTags && (
          <NewTagInput onChoose={this.addTag} existingTags={this.state.tags} allTags={this.state.allTags} />
        )}
      </CSSTransitionGroup>
    );
  }
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll('[data-tags-list="form"]').forEach(el => {
    const tags = Array.from(el.querySelectorAll('input[data-tag="yes"]'))
      .filter(t => !!t.value)
      .map(t => {
        const elem = t.previousElementSibling.querySelector(".error");
        return [t.value, elem ? elem.textContent : null];
      });

    render(<TagList tags={tags} />, el.parentNode);
  });
});
