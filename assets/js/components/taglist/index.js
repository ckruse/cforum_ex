import React, { useEffect, useState, useCallback } from "react";
import { TransitionGroup } from "react-transition-group";
import { FadeTransition } from "../transitions";

import Tag from "./tag";
import NewTagInput from "./new_tag_input";
import { conf } from "../../modules/helpers";
import { t } from "../../modules/i18n";
import Suggestions from "./suggestions";

const wordsFromText = (text) => {
  const tokens = text.split(/[^a-z0-9äöüß-]+/i);
  const words = {};

  tokens
    .filter((tok) => tok.match(/^[a-z0-9äöüß-]+$/i))
    .forEach((tok) => {
      words[tok.toLowerCase()] = 1;
    });

  return Object.keys(words);
};

const removeSomeMarkup = (text) => {
  return text
    .replace(/^([\s\t]*)([*+-]|\d\.)\s+/gm, "$1")
    .replace(/<(.*?)>/g, "$1")
    .replace(/^[=-]{2,}\s*$/g, "")
    .replace(/\[\^.+?\](: .*?$)?/g, "")
    .replace(/\s{0,2}\[.*?\]: .*?$/g, "")
    .replace(/!\[.*?\][[(].*?[\])]/g, "")
    .replace(/\[(.*?)\][[(].*?[\])]/g, "$1")
    .replace(/^\s{1,2}\[(.*?)\]: (\S+)( ".*?")?\s*$/g, "")
    .replace(/^#{1,6}\s*/g, "")
    .replace(/([*_]{1,2})(\S.*?\S)\1/g, "$2")
    .replace(/(`{3,})(.*?)\1/gm, "$2")
    .replace(/^-{3,}\s*$/g, "")
    .replace(/`(.+)`/g, "$1")
    .replace(/\n{2,}/g, "\n\n")
    .replace(/^-- \n(.*)/m, "");
};

const tagMatches = (tag_name, words) => {
  tag_name = tag_name.toLowerCase();
  for (let i = 0; i < words.length; ++i) {
    if (tag_name.match(words[i])) {
      return true;
    }
  }

  return false;
};

export default function TagList({ tags: propsTags, postingText, onChange, globalTagsError }) {
  const [tags, setTags] = useState(propsTags);
  const [allTags, setAllTags] = useState([]);
  const [suggestions, setSuggestions] = useState([]);
  const [{ minTags, maxTags }, setMinMaxTags] = useState({
    minTags: conf("min_tags_per_message") || 1,
    maxTags: conf("max_tags_per_message") || 3,
  });

  useEffect(() => {
    document.addEventListener("cf:configDidLoad", () => {
      const minTags = conf("min_tags_per_message") || 1;
      const maxTags = conf("max_tags_per_message") || 3;
      setMinMaxTags({ minTags, maxTags });
    });
  }, []);

  const refreshSuggestions = useCallback(() => {
    const words = wordsFromText(removeSomeMarkup(postingText)).map((w) => new RegExp("^" + w));
    const foundTags = allTags
      .filter((tag) => tagMatches(tag.tag_name, words) && !tags.find(([t, _]) => t === tag.tag_name))
      .slice(0, 3);

    setSuggestions(foundTags);
  }, [setSuggestions, allTags, postingText, tags]);

  useEffect(() => {
    (async () => {
      try {
        const rsp = await fetch(`/api/v1/tags`, { credentials: "same-origin" });
        const json = await rsp.json();
        const allTags = json.sort((a, b) => b.num_messages - a.num_messages);
        setAllTags(allTags);

        refreshSuggestions();
      } catch (e) {
        console.log(e);
      }
    })();
  }, [refreshSuggestions]);

  useEffect(() => {
    const timer = window.setTimeout(refreshSuggestions, 500);

    return () => {
      window.clearTimeout(timer);
    };
  }, [postingText, refreshSuggestions]);

  useEffect(() => {
    refreshSuggestions();
  }, [tags, refreshSuggestions]);

  function checkForError(tag) {
    if (!allTags.find((tg) => tg.tag_name === tag)) {
      return t("is unknown");
    }

    return null;
  }

  function addTag(tag) {
    if (!tags.find(([tag1, _]) => tag1 === tag)) {
      const newTags = [...tags, [tag, checkForError(tag)]];
      setTags(newTags);

      if (onChange) {
        onChange(newTags);
      }
    }
  }

  function removeTag(tagToRemove) {
    const newTags = tags.filter(([t, _]) => t !== tagToRemove);
    setTags(newTags);

    if (onChange) {
      onChange(newTags);
    }
  }

  const svg = (
    <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
      <use xlinkHref="/images/icons.svg#svg-remove" />
    </svg>
  );

  return (
    <fieldset>
      {tags.length < maxTags && <Suggestions suggestions={suggestions} onClick={addTag} />}

      <h3 className="cf-posting-form-section-header">{t("chosen tags")}</h3>
      <div id="remove-chosen-tag-help" className="cf-form-block-help-text">
        {svg} {t("klick to remove chosen tag")}
      </div>

      {globalTagsError && <span className="help error">{globalTagsError}</span>}
      {tags.length < minTags && minTags > 0 && (
        <span className="help error">
          {t(minTags === 1 ? "please choose at least {count} tag" : "please choose at least {count} tags", {
            count: minTags,
          })}
        </span>
      )}

      <div className="cf-cgroup">
        <TransitionGroup component="ul" className="cf-form-tagslist cf-tags-list" aria-live="polite">
          {tags.map(([tag, err]) => (
            <FadeTransition key={tag}>
              <Tag tag={tag} error={err} onClick={() => removeTag(tag)} />
            </FadeTransition>
          ))}
        </TransitionGroup>
      </div>

      <div className="cf-cgroup">
        {tags.length < maxTags && <NewTagInput onChoose={addTag} existingTags={tags} allTags={allTags} />}
      </div>
    </fieldset>
  );
}
