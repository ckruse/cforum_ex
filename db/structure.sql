--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: cforum; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA cforum;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = cforum, pg_catalog;

--
-- Name: counter_table__delete_trigger(); Type: FUNCTION; Schema: cforum; Owner: -
--

CREATE FUNCTION counter_table__delete_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE field_val_v BIGINT;
BEGIN
  RAISE NOTICE 'col: %, val: %', TG_ARGV[0], TG_ARGV[1];

  EXECUTE 'SELECT (' || quote_literal(OLD) || '::' || TG_RELID::regclass || ').' || quote_ident(TG_ARGV[0]) INTO field_val_v;

  IF field_val_v = TG_ARGV[1]::bigint THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      (TG_TABLE_NAME, -1, TG_ARGV[1]::bigint);
  END IF;

  RETURN NULL;
END;
$$;


--
-- Name: counter_table__insert_trigger(); Type: FUNCTION; Schema: cforum; Owner: -
--

CREATE FUNCTION counter_table__insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE field_val_v BIGINT;
BEGIN
  EXECUTE 'SELECT (' || quote_literal(NEW) || '::' || TG_RELID::regclass || ').' || quote_ident(TG_ARGV[0]) INTO field_val_v;

  IF field_val_v = TG_ARGV[1]::bigint THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      (TG_TABLE_NAME, +1, TG_ARGV[1]::bigint);
  END IF;

  RETURN NULL;
END;
$$;


--
-- Name: counter_table__truncate_trigger(); Type: FUNCTION; Schema: cforum; Owner: -
--

CREATE FUNCTION counter_table__truncate_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM
    cforum.counter_table
  WHERE
    table_name = TG_TABLE_NAME AND (TG_ARGV[0] IS NULL OR group_crit = TG_ARGV[0]::bigint);

  INSERT INTO
    cforum.counter_table(table_name, difference, group_crit)
  VALUES
    (TG_TABLE_NAME, 0, TG_ARGV[0]::bigint);

  RETURN NULL;
END;
$$;


--
-- Name: counter_table_create_count_trigger(name, name, bigint); Type: FUNCTION; Schema: cforum; Owner: -
--

CREATE FUNCTION counter_table_create_count_trigger(v_table_name name, v_crit_column name, v_group_crit bigint) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_table_n name := quote_ident(v_table_name);
  v_crit_column_n name := quote_ident(v_crit_column);
BEGIN
  EXECUTE
    'CREATE TRIGGER "' || v_table_n || '__count_insert__' || v_crit_column || '"
      AFTER INSERT
      ON ' || v_table_n || '
      FOR EACH ROW
      EXECUTE PROCEDURE cforum.counter_table__insert_trigger(''' || v_crit_column || ''', ' || v_group_crit ||')';

  EXECUTE
    'CREATE TRIGGER "' || v_table_n || '__count_delete__' || v_crit_column || '"
      AFTER DELETE
      ON ' || v_table_n || '
      FOR EACH ROW
      EXECUTE PROCEDURE cforum.counter_table__delete_trigger(''' || v_crit_column || ''', ' || v_group_crit ||')';

  EXECUTE
    'CREATE TRIGGER "' || v_table_n || '__count_truncate__' || v_crit_column || '"
      AFTER TRUNCATE
      ON ' || v_table_n || '
      FOR EACH STATEMENT
      EXECUTE PROCEDURE cforum.counter_table__truncate_trigger(''' || v_crit_column || ''', ' || v_group_crit ||')';

  /*
   * If the function was dropped without cleaning the content for that table
   * we would end up with old content + a new count
   */
  DELETE FROM cforum.counter_table WHERE table_name = v_table_name AND (v_group_crit IS NULL OR v_group_crit = group_crit);
  EXECUTE
    'INSERT INTO cforum.counter_table(table_name, difference, group_crit)
        SELECT $1, COUNT(*), $2 FROM ' || v_table_n || ' WHERE $2 IS NULL OR $2 = ' || v_crit_column_n USING v_table_name, v_group_crit;
END
$_$;


--
-- Name: counter_table_get_count(name, bigint); Type: FUNCTION; Schema: cforum; Owner: -
--

CREATE FUNCTION counter_table_get_count(v_table_name name, v_group_crit bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_table_n NAME := quote_ident(v_table_name);
  v_sum BIGINT;
  v_nr BIGINT;
BEGIN
  SELECT
    COUNT(*), SUM(difference)
  FROM
    cforum.counter_table
  WHERE
      table_name = v_table_name
    AND
      (v_group_crit IS NULL OR group_crit = v_group_crit)
  INTO v_nr, v_sum;

  IF v_sum IS NULL THEN
    RAISE EXCEPTION 'table_count: count on uncounted table';
  END IF;

  /*
   * We only sum up if we encounter a big enough amount of rows so summing
   * is a real benefit.
   */
  IF v_nr > 100 THEN
    DECLARE
      v_cur_id BIGINT;
      v_cur_difference BIGINT;
      v_new_sum BIGINT := 0;
      v_delete_ids BIGINT[];

    BEGIN
      RAISE NOTICE 'table_count: summing counter';

      FOR v_cur_id, v_cur_difference IN
        SELECT
          id, difference
          FROM
            cforum.counter_table
          WHERE
              table_name = v_table_name
            AND
              (v_group_crit IS NULL OR group_crit = v_group_crit)
          ORDER BY
            count_id
          FOR UPDATE NOWAIT
      LOOP
        --collecting ids instead of doing every single delete is more efficient
        v_delete_ids := v_delete_ids || v_cur_id;
        v_new_sum := v_new_sum + v_cur_difference;

        IF array_length(v_delete_ids, 1) > 100 THEN
          DELETE FROM cforum.counter_table WHERE id = ANY(v_delete_ids);
          v_delete_ids = '{}';
        END IF;

      END LOOP;

      DELETE FROM cforum.counter_table WHERE id = ANY(v_delete_ids);
      INSERT INTO cforum.counter_table(table_name, group_crit, difference) VALUES(v_table_name, v_group_crit, v_new_sum);

    EXCEPTION
      --if somebody else summed up in a transaction which was open at the
      --same time we ran the above statement
      WHEN lock_not_available THEN
        RAISE NOTICE 'table_count: locking failed';
      --if somebody else summed up in a transaction which has committed
      --successfully
      WHEN serialization_failure THEN
        RAISE NOTICE 'table_count: serialization failed';
      --summing up won't work in a readonly transaction. One could check
      --that explicitly
      WHEN read_only_sql_transaction THEN
        RAISE NOTICE 'table_count: not summing because in read only txn';
    END;
  END IF;

  RETURN v_sum;
END;
$$;


--
-- Name: counter_table_remove_count_trigger(name, name, bigint); Type: FUNCTION; Schema: cforum; Owner: -
--

CREATE FUNCTION counter_table_remove_count_trigger(v_table_name name, v_crit_column name, v_group_crit bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_table_n name := quote_ident(v_table_name);
  v_crit_column_n name := quote_ident(v_crit_column);
BEGIN
  EXECUTE 'DROP TRIGGER IF EXISTS ' || v_table_n || '__count_insert__' || v_crit_column || ' ON ' || v_table_n;
  EXECUTE 'DROP TRIGGER IF EXISTS ' || v_table_n || '__count_delete__' || v_crit_column || ' ON ' || v_table_n;
  EXECUTE 'DROP TRIGGER IF EXISTS ' || v_table_n || '__count_truncate__' || v_crit_column || ' ON ' || v_table_n;

  DELETE FROM cforum.counter_table WHERE table_name = v_table_name AND (v_group_crit IS NULL OR group_crit = v_group_crit);
END
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE access (
    user_id bigint,
    forum_id bigint,
    access_id bigint NOT NULL
);


--
-- Name: access_access_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE access_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_access_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE access_access_id_seq OWNED BY access.access_id;


--
-- Name: counter_table; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE counter_table (
    count_id bigint NOT NULL,
    table_name name NOT NULL,
    group_crit bigint,
    difference bigint NOT NULL
);


--
-- Name: counter_table_count_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE counter_table_count_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: counter_table_count_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE counter_table_count_id_seq OWNED BY counter_table.count_id;


--
-- Name: forums; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE forums (
    slug character varying(255) NOT NULL,
    name character varying(255),
    short_name character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    forum_id bigint NOT NULL,
    public boolean
);


--
-- Name: forums_forum_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE forums_forum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forums_forum_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE forums_forum_id_seq OWNED BY forums.forum_id;


--
-- Name: message_flags; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE message_flags (
    message_id bigint,
    flag character varying(255) NOT NULL,
    value character varying(255),
    flag_id bigint NOT NULL
);


--
-- Name: message_flags_flag_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE message_flags_flag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_flags_flag_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE message_flags_flag_id_seq OWNED BY message_flags.flag_id;


--
-- Name: messages; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    thread_id bigint NOT NULL,
    mid bigint,
    subject text NOT NULL,
    content text NOT NULL,
    author text NOT NULL,
    email text,
    homepage text,
    upvotes integer DEFAULT 0 NOT NULL,
    downvotes integer DEFAULT 0 NOT NULL,
    user_id bigint,
    parent_id bigint,
    deleted boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    message_id bigint NOT NULL,
    forum_id bigint NOT NULL
);


--
-- Name: messages_message_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE messages_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE messages_message_id_seq OWNED BY messages.message_id;


--
-- Name: moderators; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE moderators (
    user_id bigint,
    forum_id bigint,
    moderator_id bigint NOT NULL
);


--
-- Name: moderators_moderator_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE moderators_moderator_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderators_moderator_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE moderators_moderator_id_seq OWNED BY moderators.moderator_id;


--
-- Name: settings; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    forum_id bigint,
    user_id bigint,
    name character varying(255) NOT NULL,
    value character varying(255),
    setting_id bigint NOT NULL
);


--
-- Name: settings_setting_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE settings_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_setting_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE settings_setting_id_seq OWNED BY settings.setting_id;


--
-- Name: threads; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE threads (
    slug character varying(255) NOT NULL,
    forum_id bigint NOT NULL,
    tid bigint,
    archived boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    thread_id bigint NOT NULL,
    message_id integer
);


--
-- Name: threads_thread_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE threads_thread_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: threads_thread_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE threads_thread_id_seq OWNED BY threads.thread_id;


--
-- Name: users; Type: TABLE; Schema: cforum; Owner: -; Tablespace: 
--

CREATE TABLE users (
    username character varying(255) NOT NULL,
    email character varying(255),
    crypted_password character varying(255),
    salt character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_login_at timestamp without time zone,
    last_logout_at timestamp without time zone,
    user_id bigint NOT NULL,
    admin character varying(255),
    active boolean
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: cforum; Owner: -
--

CREATE SEQUENCE users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: cforum; Owner: -
--

ALTER SEQUENCE users_user_id_seq OWNED BY users.user_id;


SET search_path = public, pg_catalog;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


SET search_path = cforum, pg_catalog;

--
-- Name: access_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY access ALTER COLUMN access_id SET DEFAULT nextval('access_access_id_seq'::regclass);


--
-- Name: count_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY counter_table ALTER COLUMN count_id SET DEFAULT nextval('counter_table_count_id_seq'::regclass);


--
-- Name: forum_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY forums ALTER COLUMN forum_id SET DEFAULT nextval('forums_forum_id_seq'::regclass);


--
-- Name: flag_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY message_flags ALTER COLUMN flag_id SET DEFAULT nextval('message_flags_flag_id_seq'::regclass);


--
-- Name: message_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN message_id SET DEFAULT nextval('messages_message_id_seq'::regclass);


--
-- Name: moderator_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY moderators ALTER COLUMN moderator_id SET DEFAULT nextval('moderators_moderator_id_seq'::regclass);


--
-- Name: setting_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN setting_id SET DEFAULT nextval('settings_setting_id_seq'::regclass);


--
-- Name: thread_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY threads ALTER COLUMN thread_id SET DEFAULT nextval('threads_thread_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq'::regclass);


--
-- Name: access_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY access
    ADD CONSTRAINT access_pkey PRIMARY KEY (access_id);


--
-- Name: counter_table_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY counter_table
    ADD CONSTRAINT counter_table_pkey PRIMARY KEY (count_id);


--
-- Name: forums_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (forum_id);


--
-- Name: message_flags_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY message_flags
    ADD CONSTRAINT message_flags_pkey PRIMARY KEY (flag_id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- Name: moderators_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY moderators
    ADD CONSTRAINT moderators_pkey PRIMARY KEY (moderator_id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (setting_id);


--
-- Name: threads_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (thread_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: cforum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: counter_table_table_name_group_crit_idx; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX counter_table_table_name_group_crit_idx ON counter_table USING btree (table_name, group_crit);


--
-- Name: index_cforum.forums_on_slug; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_cforum.forums_on_slug" ON forums USING btree (slug);


--
-- Name: index_cforum.messages_on_forum_id_and_updated_at; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.messages_on_forum_id_and_updated_at" ON messages USING btree (forum_id, updated_at);


--
-- Name: index_cforum.messages_on_mid; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.messages_on_mid" ON messages USING btree (mid);


--
-- Name: index_cforum.messages_on_thread_id; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.messages_on_thread_id" ON messages USING btree (thread_id);


--
-- Name: index_cforum.settings_on_forum_id; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.settings_on_forum_id" ON settings USING btree (forum_id);


--
-- Name: index_cforum.settings_on_name; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.settings_on_name" ON settings USING btree (name);


--
-- Name: index_cforum.settings_on_user_id; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.settings_on_user_id" ON settings USING btree (user_id);


--
-- Name: index_cforum.threads_on_archived; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.threads_on_archived" ON threads USING btree (archived);


--
-- Name: index_cforum.threads_on_created_at; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.threads_on_created_at" ON threads USING btree (created_at);


--
-- Name: index_cforum.threads_on_forum_id; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.threads_on_forum_id" ON threads USING btree (forum_id);


--
-- Name: index_cforum.threads_on_slug; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_cforum.threads_on_slug" ON threads USING btree (slug);


--
-- Name: index_cforum.threads_on_tid; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE INDEX "index_cforum.threads_on_tid" ON threads USING btree (tid);


--
-- Name: index_cforum.users_on_username; Type: INDEX; Schema: cforum; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_cforum.users_on_username" ON users USING btree (username);


SET search_path = public, pg_catalog;

--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = cforum, pg_catalog;

--
-- Name: forum_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT forum_id_fkey FOREIGN KEY (forum_id) REFERENCES forums(forum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: forum_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY moderators
    ADD CONSTRAINT forum_id_fkey FOREIGN KEY (forum_id) REFERENCES forums(forum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: forum_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY access
    ADD CONSTRAINT forum_id_fkey FOREIGN KEY (forum_id) REFERENCES forums(forum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: forum_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT forum_id_fkey FOREIGN KEY (forum_id) REFERENCES forums(forum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(message_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY message_flags
    ADD CONSTRAINT message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(message_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parent_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT parent_id_fkey FOREIGN KEY (parent_id) REFERENCES messages(message_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: thread_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT thread_id_fkey FOREIGN KEY (thread_id) REFERENCES threads(thread_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY moderators
    ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_id_fkey; Type: FK CONSTRAINT; Schema: cforum; Owner: -
--

ALTER TABLE ONLY access
    ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--



SET search_path = public, pg_catalog;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');