--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: project_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.project_role AS ENUM (
    'dev',
    'manager',
    'contractor'
);


ALTER TYPE public.project_role OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assigments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assigments (
    assigmentid integer NOT NULL,
    kanbanid integer
);


ALTER TABLE public.assigments OWNER TO postgres;

--
-- Name: assigments_assigmentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assigments_assigmentid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.assigments_assigmentid_seq OWNER TO postgres;

--
-- Name: assigments_assigmentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assigments_assigmentid_seq OWNED BY public.assigments.assigmentid;


--
-- Name: chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chats (
    chatid integer NOT NULL,
    profileid integer
);


ALTER TABLE public.chats OWNER TO postgres;

--
-- Name: chats_chatid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chats_chatid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chats_chatid_seq OWNER TO postgres;

--
-- Name: chats_chatid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chats_chatid_seq OWNED BY public.chats.chatid;


--
-- Name: datasets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.datasets (
    datasetid integer NOT NULL,
    workerid integer
);


ALTER TABLE public.datasets OWNER TO postgres;

--
-- Name: datasets_datasetid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.datasets_datasetid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.datasets_datasetid_seq OWNER TO postgres;

--
-- Name: datasets_datasetid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.datasets_datasetid_seq OWNED BY public.datasets.datasetid;


--
-- Name: kanbans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kanbans (
    kanbanid integer NOT NULL,
    workerid integer
);


ALTER TABLE public.kanbans OWNER TO postgres;

--
-- Name: kanbans_kananid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kanbans_kananid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kanbans_kananid_seq OWNER TO postgres;

--
-- Name: kanbans_kananid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kanbans_kananid_seq OWNED BY public.kanbans.kanbanid;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    projectid integer NOT NULL,
    kanbanid integer
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: projects_projectid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.projects_projectid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.projects_projectid_seq OWNER TO postgres;

--
-- Name: projects_projectid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.projects_projectid_seq OWNED BY public.projects.projectid;


--
-- Name: shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shifts (
    shiftid integer NOT NULL,
    s_begintime timestamp without time zone NOT NULL,
    s_endtime timestamp without time zone NOT NULL,
    workerid integer,
    kananid integer
);


ALTER TABLE public.shifts OWNER TO postgres;

--
-- Name: shifts_shiftid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shifts_shiftid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shifts_shiftid_seq OWNER TO postgres;

--
-- Name: shifts_shiftid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shifts_shiftid_seq OWNED BY public.shifts.shiftid;


--
-- Name: useprofiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useprofiles (
    profileid integer NOT NULL,
    p_image character varying(255) NOT NULL,
    p_preference_islightmode boolean,
    kanbanids integer[],
    workerid integer
);


ALTER TABLE public.useprofiles OWNER TO postgres;

--
-- Name: useprofiles_profileid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.useprofiles_profileid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.useprofiles_profileid_seq OWNER TO postgres;

--
-- Name: useprofiles_profileid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.useprofiles_profileid_seq OWNED BY public.useprofiles.profileid;


--
-- Name: workers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workers (
    workerid integer NOT NULL,
    w_passwordkey character varying(50) NOT NULL,
    w_fullname character varying(50),
    status public.project_role DEFAULT 'dev'::public.project_role NOT NULL
);


ALTER TABLE public.workers OWNER TO postgres;

--
-- Name: workers_workerid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workers_workerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workers_workerid_seq OWNER TO postgres;

--
-- Name: workers_workerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workers_workerid_seq OWNED BY public.workers.workerid;


--
-- Name: assigments assigmentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assigments ALTER COLUMN assigmentid SET DEFAULT nextval('public.assigments_assigmentid_seq'::regclass);


--
-- Name: chats chatid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats ALTER COLUMN chatid SET DEFAULT nextval('public.chats_chatid_seq'::regclass);


--
-- Name: datasets datasetid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datasets ALTER COLUMN datasetid SET DEFAULT nextval('public.datasets_datasetid_seq'::regclass);


--
-- Name: kanbans kanbanid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kanbans ALTER COLUMN kanbanid SET DEFAULT nextval('public.kanbans_kananid_seq'::regclass);


--
-- Name: projects projectid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects ALTER COLUMN projectid SET DEFAULT nextval('public.projects_projectid_seq'::regclass);


--
-- Name: shifts shiftid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts ALTER COLUMN shiftid SET DEFAULT nextval('public.shifts_shiftid_seq'::regclass);


--
-- Name: useprofiles profileid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useprofiles ALTER COLUMN profileid SET DEFAULT nextval('public.useprofiles_profileid_seq'::regclass);


--
-- Name: workers workerid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workers ALTER COLUMN workerid SET DEFAULT nextval('public.workers_workerid_seq'::regclass);


--
-- Data for Name: assigments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assigments (assigmentid, kanbanid) FROM stdin;
\.


--
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chats (chatid, profileid) FROM stdin;
\.


--
-- Data for Name: datasets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.datasets (datasetid, workerid) FROM stdin;
\.


--
-- Data for Name: kanbans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kanbans (kanbanid, workerid) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (projectid, kanbanid) FROM stdin;
\.


--
-- Data for Name: shifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shifts (shiftid, s_begintime, s_endtime, workerid, kananid) FROM stdin;
\.


--
-- Data for Name: useprofiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.useprofiles (profileid, p_image, p_preference_islightmode, kanbanids, workerid) FROM stdin;
\.


--
-- Data for Name: workers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workers (workerid, w_passwordkey, w_fullname, status) FROM stdin;
\.


--
-- Name: assigments_assigmentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assigments_assigmentid_seq', 1, false);


--
-- Name: chats_chatid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chats_chatid_seq', 1, false);


--
-- Name: datasets_datasetid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datasets_datasetid_seq', 1, false);


--
-- Name: kanbans_kananid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kanbans_kananid_seq', 1, false);


--
-- Name: projects_projectid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.projects_projectid_seq', 1, false);


--
-- Name: shifts_shiftid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shifts_shiftid_seq', 1, false);


--
-- Name: useprofiles_profileid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.useprofiles_profileid_seq', 1, false);


--
-- Name: workers_workerid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workers_workerid_seq', 1, false);


--
-- Name: assigments assigments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assigments
    ADD CONSTRAINT assigments_pkey PRIMARY KEY (assigmentid);


--
-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (chatid);


--
-- Name: datasets datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (datasetid);


--
-- Name: kanbans kanbans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kanbans
    ADD CONSTRAINT kanbans_pkey PRIMARY KEY (kanbanid);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (projectid);


--
-- Name: shifts shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (shiftid);


--
-- Name: useprofiles useprofiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useprofiles
    ADD CONSTRAINT useprofiles_pkey PRIMARY KEY (profileid);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (workerid);


--
-- Name: assigments assigments_kanbanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assigments
    ADD CONSTRAINT assigments_kanbanid_fkey FOREIGN KEY (kanbanid) REFERENCES public.kanbans(kanbanid);


--
-- Name: chats chats_profileid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_profileid_fkey FOREIGN KEY (profileid) REFERENCES public.useprofiles(profileid);


--
-- Name: datasets datasets_workerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT datasets_workerid_fkey FOREIGN KEY (workerid) REFERENCES public.workers(workerid);


--
-- Name: kanbans kanbans_workerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kanbans
    ADD CONSTRAINT kanbans_workerid_fkey FOREIGN KEY (workerid) REFERENCES public.workers(workerid);


--
-- Name: projects projects_kanbanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_kanbanid_fkey FOREIGN KEY (kanbanid) REFERENCES public.kanbans(kanbanid);


--
-- Name: shifts shifts_kananid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_kananid_fkey FOREIGN KEY (kananid) REFERENCES public.kanbans(kanbanid);


--
-- Name: shifts shifts_workerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_workerid_fkey FOREIGN KEY (workerid) REFERENCES public.workers(workerid);


--
-- Name: useprofiles useprofiles_workerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useprofiles
    ADD CONSTRAINT useprofiles_workerid_fkey FOREIGN KEY (workerid) REFERENCES public.workers(workerid);


--
-- PostgreSQL database dump complete
--

