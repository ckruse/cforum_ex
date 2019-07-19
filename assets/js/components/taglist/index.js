import React from "react";
import { TransitionGroup } from "react-transition-group";
import { FadeTransition } from "../transitions";

import Tag from "./tag";
import NewTagInput from "./new_tag_input";
import { conf } from "../../modules/helpers";
import { t } from "../../modules/i18n";
import Suggestions from "./suggestions";

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
      maxTags,
      suggestions: []
    };

    this.addTag = this.addTag.bind(this);
    this.checkForError = this.checkForError.bind(this);
    this.refreshSuggestions = this.refreshSuggestions.bind(this);

    fetch(`/api/v1/tags`, { credentials: "same-origin" })
      .then(json => json.json())
      .then(json => {
        json.sort((a, b) => b.num_messages - a.num_messages);
        this.setState({ allTags: json });
      })
      .then(() => this.refreshSuggestions())
      .catch(e => console.log(e));
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.props.postingText != prevProps.postingText) {
      if (this.timer) {
        window.clearTimeout(this.timer);
      }

      this.timer = window.setTimeout(this.refreshSuggestions, 500);
    }

    if (prevState.tags !== this.state.tags) {
      this.refreshSuggestions();
    }
  }

  checkForError(tag) {
    if (!this.state.allTags.find(tg => tg.tag_name == tag)) {
      return t("is unknown");
    }

    return null;
  }

  addTag(tag) {
    if (!this.state.tags.find(([tag1, _]) => tag1 === tag)) {
      const tags = [...this.state.tags, [tag, this.checkForError(tag)]];
      this.setState({ tags });

      if (this.props.onChange) {
        this.props.onChange(tags);
      }
    }
  }

  removeTag(tagToRemove) {
    const tags = this.state.tags.filter(([t, _]) => t !== tagToRemove);
    this.setState({ tags });

    if (this.props.onChange) {
      this.props.onChange(tags);
    }
  }

  wordsFromText(text) {
    const tokens = text.split(/[^a-z0-9äöüß-]+/i);
    const words = {};

    tokens
      .filter(tok => tok.match(/^[a-z0-9äöüß-]+$/i))
      .forEach(tok => {
        words[tok.toLowerCase()] = 1;
      });

    return Object.keys(words);
  }

  removeSomeMarkup(text) {
    return text
      .replace(/^([\s\t]*)([\*\-\+]|\d\.)\s+/gm, "$1")
      .replace(/<(.*?)>/g, "$1")
      .replace(/^[=\-]{2,}\s*$/g, "")
      .replace(/\[\^.+?\](\: .*?$)?/g, "")
      .replace(/\s{0,2}\[.*?\]: .*?$/g, "")
      .replace(/\!\[.*?\][\[\(].*?[\]\)]/g, "")
      .replace(/\[(.*?)\][\[\(].*?[\]\)]/g, "$1")
      .replace(/^\s{1,2}\[(.*?)\]: (\S+)( ".*?")?\s*$/g, "")
      .replace(/^\#{1,6}\s*/g, "")
      .replace(/([\*_]{1,2})(\S.*?\S)\1/g, "$2")
      .replace(/(`{3,})(.*?)\1/gm, "$2")
      .replace(/^-{3,}\s*$/g, "")
      .replace(/`(.+)`/g, "$1")
      .replace(/\n{2,}/g, "\n\n")
      .replace(/^-- \n(.*)/m, "");
  }

  tagMatches(tag_name, words) {
    tag_name = tag_name.toLowerCase();
    for (let i = 0; i < words.length; ++i) {
      if (tag_name.match(words[i])) {
        return true;
      }
    }

    return false;
  }

  refreshSuggestions() {
    const words = this.wordsFromText(this.removeSomeMarkup(this.props.postingText)).map(w => new RegExp("^" + w));
    const foundTags = this.state.allTags
      .filter(tag => {
        return this.tagMatches(tag.tag_name, words) && !this.state.tags.find(([t, _]) => t === tag.tag_name);
      })
      .slice(0, 3);

    this.setState({ suggestions: foundTags });
  }

  render() {
    const globalTagsError = this.props.globalTagsError;

    const svg = (
      <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
        <use xlinkHref="/images/icons.svg#svg-remove" />
      </svg>
    );

    return (
      <fieldset>
        {this.state.tags.length < this.state.maxTags && (
          <Suggestions suggestions={this.state.suggestions} onClick={this.addTag} />
        )}

        <h3 className="cf-posting-form-section-header">{t("chosen tags")}</h3>
        <div id="remove-chosen-tag-help" className="cf-form-block-help-text">
          {svg} {t("klick to remove chosen tag")}
        </div>

        {globalTagsError && <span className="help error">{globalTagsError}</span>}

        <div className="cf-cgroup">
          <TransitionGroup component="ul" className="cf-form-tagslist cf-tags-list" aria-live="polite">
            {this.state.tags.map(([tag, err]) => (
              <FadeTransition key={tag}>
                <Tag tag={tag} error={err} onClick={() => this.removeTag(tag)} />
              </FadeTransition>
            ))}
          </TransitionGroup>
        </div>

        <div className="cf-cgroup">
          {this.state.tags.length < this.state.maxTags && (
            <NewTagInput onChoose={this.addTag} existingTags={this.state.tags} allTags={this.state.allTags} />
          )}
        </div>
      </fieldset>
    );
  }
}

export default TagList;
