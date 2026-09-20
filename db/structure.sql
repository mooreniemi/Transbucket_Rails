--
-- PostgreSQL database dump
--

\restrict t7fhqQvZ3cttV6viQgblNxzWx9ddyX4aYxBJ4qlwjT1kcZue6isG69YpipMn20F

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets (
    id integer NOT NULL,
    asset_file_name character varying,
    asset_content_type character varying,
    asset_file_size integer,
    asset_updated_at timestamp without time zone,
    pin_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone
);


--
-- Name: assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assets_id_seq OWNED BY public.assets.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    commentable_id integer DEFAULT 0,
    commentable_type character varying DEFAULT ''::character varying,
    title character varying DEFAULT ''::character varying,
    body text DEFAULT ''::text,
    subject character varying DEFAULT ''::character varying,
    user_id integer DEFAULT 0 NOT NULL,
    parent_id integer,
    lft integer,
    rgt integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    state character varying
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: content_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_events (
    id integer NOT NULL,
    user_id integer,
    visitor_hash character varying(64),
    network_hash character varying(64),
    content_type character varying NOT NULL,
    content_id integer NOT NULL,
    event_type character varying NOT NULL,
    source character varying DEFAULT 'server'::character varying NOT NULL,
    locale character varying(10),
    occurred_at timestamp without time zone NOT NULL,
    client_context jsonb DEFAULT '{}'::jsonb NOT NULL,
    event_context jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: content_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_events_id_seq OWNED BY public.content_events.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id integer NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: genders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genders (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: genders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genders_id_seq OWNED BY public.genders.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: moderation_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_events (
    id integer NOT NULL,
    user_id integer,
    action character varying NOT NULL,
    content_type character varying NOT NULL,
    content_id integer NOT NULL,
    occurred_at timestamp without time zone NOT NULL
);


--
-- Name: moderation_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_events_id_seq OWNED BY public.moderation_events.id;


--
-- Name: pin_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pin_images (
    id integer NOT NULL,
    caption text,
    pin_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    photo_file_name character varying,
    photo_content_type character varying,
    photo_file_size integer,
    photo_updated_at timestamp without time zone
);


--
-- Name: pin_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pin_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pin_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pin_images_id_seq OWNED BY public.pin_images.id;


--
-- Name: pins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pins (
    id integer NOT NULL,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    procedure_id integer,
    revision boolean,
    surgeon_id integer,
    details text,
    cost integer,
    username character varying,
    state character varying,
    sensation integer,
    satisfaction integer,
    covered_by_insurance boolean
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pins_id_seq OWNED BY public.pins.id;


--
-- Name: preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preferences (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    notification boolean DEFAULT true,
    safe_mode boolean DEFAULT false
);


--
-- Name: preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.preferences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.preferences_id_seq OWNED BY public.preferences.id;


--
-- Name: procedure_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.procedure_translations (
    id integer NOT NULL,
    procedure_id integer NOT NULL,
    locale character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: procedure_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.procedure_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: procedure_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.procedure_translations_id_seq OWNED BY public.procedure_translations.id;


--
-- Name: procedures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.procedures (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    body_type character varying,
    gender character varying,
    avg_sensation integer,
    avg_satisfaction integer,
    slug character varying,
    description character varying
);


--
-- Name: procedures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.procedures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: procedures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.procedures_id_seq OWNED BY public.procedures.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    var character varying NOT NULL,
    value text,
    target_id integer NOT NULL,
    target_type character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: skills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.skills (
    id integer NOT NULL,
    surgeon_id integer,
    procedure_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.skills_id_seq OWNED BY public.skills.id;


--
-- Name: surgeons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.surgeons (
    id integer NOT NULL,
    first_name character varying,
    address character varying,
    city character varying,
    state character varying,
    zip character varying,
    country character varying,
    phone character varying(20),
    email character varying,
    url character varying,
    procedure_list text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_name character varying,
    notes text,
    slug character varying
);


--
-- Name: surgeons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.surgeons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surgeons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.surgeons_id_seq OWNED BY public.surgeons.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying,
    tagger_id integer,
    tagger_type character varying,
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying,
    taggings_count integer DEFAULT 0
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: user_trust_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_trust_grants (
    id integer NOT NULL,
    user_id integer NOT NULL,
    granted_by_user_id integer,
    kind character varying NOT NULL,
    source character varying DEFAULT 'automatic'::character varying NOT NULL,
    internal_note text,
    granted_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_trust_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_trust_grants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_trust_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_trust_grants_id_seq OWNED BY public.user_trust_grants.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying,
    gender_id integer DEFAULT 4 NOT NULL,
    username character varying,
    admin boolean DEFAULT false,
    md5 character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    confirmation_reminder_sent_at timestamp without time zone,
    never_signed_in_outreach_sent_at timestamp without time zone,
    locale character varying,
    pronouns character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    votable_id integer,
    votable_type character varying,
    voter_id integer,
    voter_type character varying,
    vote_flag boolean,
    vote_scope character varying,
    vote_weight integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets ALTER COLUMN id SET DEFAULT nextval('public.assets_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: content_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_events ALTER COLUMN id SET DEFAULT nextval('public.content_events_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: genders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genders ALTER COLUMN id SET DEFAULT nextval('public.genders_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: moderation_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_events ALTER COLUMN id SET DEFAULT nextval('public.moderation_events_id_seq'::regclass);


--
-- Name: pin_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pin_images ALTER COLUMN id SET DEFAULT nextval('public.pin_images_id_seq'::regclass);


--
-- Name: pins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pins ALTER COLUMN id SET DEFAULT nextval('public.pins_id_seq'::regclass);


--
-- Name: preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences ALTER COLUMN id SET DEFAULT nextval('public.preferences_id_seq'::regclass);


--
-- Name: procedure_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedure_translations ALTER COLUMN id SET DEFAULT nextval('public.procedure_translations_id_seq'::regclass);


--
-- Name: procedures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures ALTER COLUMN id SET DEFAULT nextval('public.procedures_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: skills id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills ALTER COLUMN id SET DEFAULT nextval('public.skills_id_seq'::regclass);


--
-- Name: surgeons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surgeons ALTER COLUMN id SET DEFAULT nextval('public.surgeons_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: user_trust_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_trust_grants ALTER COLUMN id SET DEFAULT nextval('public.user_trust_grants_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: content_events content_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_events
    ADD CONSTRAINT content_events_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: genders genders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genders
    ADD CONSTRAINT genders_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: moderation_events moderation_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_events
    ADD CONSTRAINT moderation_events_pkey PRIMARY KEY (id);


--
-- Name: pin_images pin_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pin_images
    ADD CONSTRAINT pin_images_pkey PRIMARY KEY (id);


--
-- Name: pins pins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (id);


--
-- Name: procedure_translations procedure_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedure_translations
    ADD CONSTRAINT procedure_translations_pkey PRIMARY KEY (id);


--
-- Name: procedures procedures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures
    ADD CONSTRAINT procedures_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: surgeons surgeons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surgeons
    ADD CONSTRAINT surgeons_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: user_trust_grants user_trust_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_trust_grants
    ADD CONSTRAINT user_trust_grants_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_comments_on_commentable_id_and_commentable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_id_and_commentable_type ON public.comments USING btree (commentable_id, commentable_type);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_user_id ON public.comments USING btree (user_id);


--
-- Name: index_content_events_on_content_event_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_events_on_content_event_time ON public.content_events USING btree (content_type, content_id, event_type, occurred_at);


--
-- Name: index_content_events_on_network_hash_and_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_events_on_network_hash_and_occurred_at ON public.content_events USING btree (network_hash, occurred_at);


--
-- Name: index_content_events_on_user_deduplication; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_events_on_user_deduplication ON public.content_events USING btree (user_id, content_type, content_id, event_type, occurred_at);


--
-- Name: index_content_events_on_user_id_and_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_events_on_user_id_and_occurred_at ON public.content_events USING btree (user_id, occurred_at);


--
-- Name: index_content_events_on_visitor_deduplication; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_events_on_visitor_deduplication ON public.content_events USING btree (visitor_hash, content_type, content_id, event_type, occurred_at);


--
-- Name: index_content_events_on_visitor_hash_and_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_events_on_visitor_hash_and_occurred_at ON public.content_events USING btree (visitor_hash, occurred_at);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON public.friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_moderation_events_on_action_and_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_events_on_action_and_occurred_at ON public.moderation_events USING btree (action, occurred_at);


--
-- Name: index_moderation_events_on_content_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_events_on_content_time ON public.moderation_events USING btree (content_type, content_id, occurred_at);


--
-- Name: index_moderation_events_on_user_action_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_events_on_user_action_time ON public.moderation_events USING btree (user_id, action, occurred_at);


--
-- Name: index_pin_images_on_pin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pin_images_on_pin_id ON public.pin_images USING btree (pin_id);


--
-- Name: index_pins_on_procedure_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pins_on_procedure_id ON public.pins USING btree (procedure_id);


--
-- Name: index_pins_on_surgeon_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pins_on_surgeon_id ON public.pins USING btree (surgeon_id);


--
-- Name: index_pins_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pins_on_user_id ON public.pins USING btree (user_id);


--
-- Name: index_procedure_translations_on_locale_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_procedure_translations_on_locale_and_name ON public.procedure_translations USING btree (locale, name);


--
-- Name: index_procedure_translations_on_procedure_id_and_locale; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_procedure_translations_on_procedure_id_and_locale ON public.procedure_translations USING btree (procedure_id, locale);


--
-- Name: index_procedures_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_procedures_on_slug ON public.procedures USING btree (slug);


--
-- Name: index_settings_on_target_type_and_target_id_and_var; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_settings_on_target_type_and_target_id_and_var ON public.settings USING btree (target_type, target_id, var);


--
-- Name: index_surgeons_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_surgeons_on_slug ON public.surgeons USING btree (slug);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON public.taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_user_trust_grants_on_granted_by_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_trust_grants_on_granted_by_user_id ON public.user_trust_grants USING btree (granted_by_user_id);


--
-- Name: index_user_trust_grants_on_user_id_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_trust_grants_on_user_id_and_kind ON public.user_trust_grants USING btree (user_id, kind);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_lower_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_lower_email ON public.users USING btree (lower((email)::text));


--
-- Name: index_users_on_lower_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_lower_username ON public.users USING btree (lower((username)::text));


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_votable_id_and_votable_type_and_vote_scope ON public.votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_votes_on_voter_id_and_voter_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_voter_id_and_voter_type_and_vote_scope ON public.votes USING btree (voter_id, voter_type, vote_scope);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX taggings_idx ON public.taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: procedure_translations fk_rails_638de91f37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedure_translations
    ADD CONSTRAINT fk_rails_638de91f37 FOREIGN KEY (procedure_id) REFERENCES public.procedures(id);


--
-- PostgreSQL database dump complete
--

\unrestrict t7fhqQvZ3cttV6viQgblNxzWx9ddyX4aYxBJ4qlwjT1kcZue6isG69YpipMn20F

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20130327232101');

INSERT INTO schema_migrations (version) VALUES ('20130328013531');

INSERT INTO schema_migrations (version) VALUES ('20130328013648');

INSERT INTO schema_migrations (version) VALUES ('20130328023119');

INSERT INTO schema_migrations (version) VALUES ('20130328031252');

INSERT INTO schema_migrations (version) VALUES ('20130328035816');

INSERT INTO schema_migrations (version) VALUES ('20130330031458');

INSERT INTO schema_migrations (version) VALUES ('20130330032947');

INSERT INTO schema_migrations (version) VALUES ('20130330164714');

INSERT INTO schema_migrations (version) VALUES ('20130330164731');

INSERT INTO schema_migrations (version) VALUES ('20130330200217');

INSERT INTO schema_migrations (version) VALUES ('20130505181136');

INSERT INTO schema_migrations (version) VALUES ('20130505230729');

INSERT INTO schema_migrations (version) VALUES ('20130511192635');

INSERT INTO schema_migrations (version) VALUES ('20130511204625');

INSERT INTO schema_migrations (version) VALUES ('20130519204918');

INSERT INTO schema_migrations (version) VALUES ('20130524021220');

INSERT INTO schema_migrations (version) VALUES ('20131014171632');

INSERT INTO schema_migrations (version) VALUES ('20131016185523');

INSERT INTO schema_migrations (version) VALUES ('20131018185449');

INSERT INTO schema_migrations (version) VALUES ('20131018185503');

INSERT INTO schema_migrations (version) VALUES ('20131022001140');

INSERT INTO schema_migrations (version) VALUES ('20131022002201');

INSERT INTO schema_migrations (version) VALUES ('20131026151522');

INSERT INTO schema_migrations (version) VALUES ('20131026205013');

INSERT INTO schema_migrations (version) VALUES ('20131027152024');

INSERT INTO schema_migrations (version) VALUES ('20131107015656');

INSERT INTO schema_migrations (version) VALUES ('20131107020618');

INSERT INTO schema_migrations (version) VALUES ('20131108000150');

INSERT INTO schema_migrations (version) VALUES ('20131108000450');

INSERT INTO schema_migrations (version) VALUES ('20131108000520');

INSERT INTO schema_migrations (version) VALUES ('20131108000702');

INSERT INTO schema_migrations (version) VALUES ('20131110220445');

INSERT INTO schema_migrations (version) VALUES ('20131115020032');

INSERT INTO schema_migrations (version) VALUES ('20131123225440');

INSERT INTO schema_migrations (version) VALUES ('20131124185916');

INSERT INTO schema_migrations (version) VALUES ('20131124194025');

INSERT INTO schema_migrations (version) VALUES ('20131124194211');

INSERT INTO schema_migrations (version) VALUES ('20131124201729');

INSERT INTO schema_migrations (version) VALUES ('20131124202225');

INSERT INTO schema_migrations (version) VALUES ('20131124203329');

INSERT INTO schema_migrations (version) VALUES ('20131126015839');

INSERT INTO schema_migrations (version) VALUES ('20131126020615');

INSERT INTO schema_migrations (version) VALUES ('20131201191656');

INSERT INTO schema_migrations (version) VALUES ('20140303034944');

INSERT INTO schema_migrations (version) VALUES ('20140303040616');

INSERT INTO schema_migrations (version) VALUES ('20140325034834');

INSERT INTO schema_migrations (version) VALUES ('20140325034915');

INSERT INTO schema_migrations (version) VALUES ('20140706034042');

INSERT INTO schema_migrations (version) VALUES ('20141104031256');

INSERT INTO schema_migrations (version) VALUES ('20141104031257');

INSERT INTO schema_migrations (version) VALUES ('20141104031258');

INSERT INTO schema_migrations (version) VALUES ('20150425182913');

INSERT INTO schema_migrations (version) VALUES ('20160614152323');

INSERT INTO schema_migrations (version) VALUES ('20160617214012');

INSERT INTO schema_migrations (version) VALUES ('20160618175431');

INSERT INTO schema_migrations (version) VALUES ('20160618175539');

INSERT INTO schema_migrations (version) VALUES ('20160618181002');

INSERT INTO schema_migrations (version) VALUES ('20160618190824');

INSERT INTO schema_migrations (version) VALUES ('20160618192808');

INSERT INTO schema_migrations (version) VALUES ('20160618193337');

INSERT INTO schema_migrations (version) VALUES ('20160619040925');

INSERT INTO schema_migrations (version) VALUES ('20160619174827');

INSERT INTO schema_migrations (version) VALUES ('20210308075400');

INSERT INTO schema_migrations (version) VALUES ('20260910000000');

INSERT INTO schema_migrations (version) VALUES ('20260911020000');

INSERT INTO schema_migrations (version) VALUES ('20260911030000');

INSERT INTO schema_migrations (version) VALUES ('20260913153501');

INSERT INTO schema_migrations (version) VALUES ('20260913160000');

INSERT INTO schema_migrations (version) VALUES ('20260918120000');

INSERT INTO schema_migrations (version) VALUES ('20260919130000');

INSERT INTO schema_migrations (version) VALUES ('20260919131000');

INSERT INTO schema_migrations (version) VALUES ('20260919132000');

INSERT INTO schema_migrations (version) VALUES ('20260919133000');

INSERT INTO schema_migrations (version) VALUES ('20260919134000');

INSERT INTO schema_migrations (version) VALUES ('20260920060000');

INSERT INTO schema_migrations (version) VALUES ('20260920061000');


INSERT INTO schema_migrations (version) VALUES ('20260920190000');

