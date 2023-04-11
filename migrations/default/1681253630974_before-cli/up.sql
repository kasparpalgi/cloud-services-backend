SET check_function_bodies = false;
CREATE FUNCTION public.check_banned_emails() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    inserted_email text; -- Declare a variable to store the email address from the new record
BEGIN
    SELECT -- Get the email address from the new record (the record being inserted)
        NEW.email INTO inserted_email;
    IF EXISTS( -- Check if the email address exists in the banned_emails table
        SELECT 
            b.email 
        FROM 
            banned_emails b 
        WHERE
            b.email = inserted_email
    ) THEN
        -- If the email is found in the banned_emails table, raise an exception with a custom message
        Raise exception 'The email address % is banned!', inserted_email;
    END IF;
    RETURN NEW; -- If the email is not found in the banned_emails table, continue with the operation
END;
$$;
CREATE TABLE public.companies (
    id integer NOT NULL,
    company_name text NOT NULL,
    phone text NOT NULL
);
CREATE FUNCTION public.companies_total_revenue(company_row public.companies) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    total_revenue NUMERIC;
  BEGIN
    SELECT SUM(invoices.amount) INTO total_revenue
    FROM invoices
    JOIN users ON users.id = invoices.user_id
    WHERE users.company_id = company_row.id;
    RETURN total_revenue;
  END;
$$;
CREATE FUNCTION public.company_total_revenue_by(company_id_input integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
  DECLARE
    total_amount NUMERIC;
  BEGIN
    SELECT SUM(invoices.amount) INTO total_amount
    FROM invoices
    JOIN users ON users.id = invoices.user_id
    WHERE users.company_id = company_id_input;
    RETURN total_amount;
  END;
$$;
CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE FUNCTION public.total_revenue_by_company(company_id_input integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
  DECLARE
    total_revenue NUMERIC;
  BEGIN
    SELECT SUM(invoices.amount) INTO total_revenue
    FROM invoices
    JOIN users ON users.id = invoices.user_id
    WHERE users.company_id = company_id_input;
    RETURN total_revenue;
  END;
$$;
CREATE FUNCTION public.total_revenue_by_company(company_row public.companies) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    total_revenue NUMERIC;
  BEGIN
    SELECT SUM(invoices.amount) INTO total_revenue
    FROM invoices
    JOIN users ON users.id = invoices.user_id
    WHERE users.company_id = company_row.id;
    RETURN total_revenue;
  END;
$$;
CREATE FUNCTION public.total_revenue_company(company_row public.companies) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
  DECLARE
    total_revenue NUMERIC;
  BEGIN
    SELECT SUM(invoices.amount) INTO total_revenue
    FROM invoices
    JOIN users ON users.id = invoices.user_id
    WHERE users.company_id = company_row.id;
    RETURN total_revenue;
  END;
$$;
CREATE TABLE public.banned_emails (
    id integer NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE SEQUENCE public.banned_emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.banned_emails_id_seq OWNED BY public.banned_emails.id;
CREATE TABLE public.chat_messages (
    id integer NOT NULL,
    sender_id integer NOT NULL,
    receiver_id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.chat_messages IS 'Live chat messages';
CREATE SEQUENCE public.chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;
CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;
CREATE TABLE public.emails (
    id integer NOT NULL,
    email text NOT NULL,
    subject text NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE SEQUENCE public.emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;
CREATE TABLE public.invoices (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    date date NOT NULL,
    status text NOT NULL,
    amount numeric NOT NULL,
    company_id integer NOT NULL,
    user_id integer
);
CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;
CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.reservations (
    id integer NOT NULL,
    company_id integer NOT NULL,
    room_id integer NOT NULL,
    date date DEFAULT now() NOT NULL,
    "time" time with time zone DEFAULT '13:00:00+02'::time with time zone NOT NULL,
    length_minutes integer DEFAULT 60 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT length CHECK (((length_minutes = 60) OR (length_minutes = 120)))
);
CREATE SEQUENCE public.reservations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.reservations_id_seq OWNED BY public.reservations.id;
CREATE TABLE public.reviews (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    rating_stars integer,
    review_text text,
    CONSTRAINT ratingstars CHECK ((((rating_stars)::numeric > (0)::numeric) AND ((rating_stars)::numeric < (6)::numeric)))
);
CREATE TABLE public.roles (
    role text NOT NULL
);
CREATE TABLE public.rooms (
    id integer NOT NULL,
    name text NOT NULL
);
CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;
CREATE TABLE public.users (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    first_name text,
    last_name text DEFAULT 'NoSurname'::text,
    email text NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    role text DEFAULT 'employee'::text NOT NULL,
    company_id integer,
    mobile_number text,
    uid text,
    photo_url text,
    CONSTRAINT email CHECK (((char_length(email) >= 5) AND (char_length(email) <= 255) AND (POSITION(('@'::text) IN (email)) > 1) AND (POSITION(('.'::text) IN (SUBSTRING(email FROM POSITION(('@'::text) IN (email)) FOR 255))) > 1))),
    CONSTRAINT mobile_number CHECK (((char_length(mobile_number) >= 7) AND (mobile_number ~ '^[\d\-\+\(\)]+$'::text)))
);
COMMENT ON TABLE public.users IS 'Customer users only. Internal users are in a separate table.';
COMMENT ON COLUMN public.users.last_name IS 'Nullable';
COMMENT ON COLUMN public.users.uid IS 'Firebase UID';
CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
ALTER TABLE ONLY public.banned_emails ALTER COLUMN id SET DEFAULT nextval('public.banned_emails_id_seq'::regclass);
ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);
ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);
ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);
ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);
ALTER TABLE ONLY public.reservations ALTER COLUMN id SET DEFAULT nextval('public.reservations_id_seq'::regclass);
ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);
ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
ALTER TABLE ONLY public.banned_emails
    ADD CONSTRAINT banned_emails_email_key UNIQUE (email);
ALTER TABLE ONLY public.banned_emails
    ADD CONSTRAINT banned_emails_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role);
ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_mobile_number_key UNIQUE (mobile_number);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE TRIGGER insert_user BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.check_banned_emails();
CREATE TRIGGER set_public_chat_messages_updated_at BEFORE UPDATE ON public.chat_messages FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_chat_messages_updated_at ON public.chat_messages IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_invoices_updated_at BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_invoices_updated_at ON public.invoices IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_reservations_updated_at BEFORE UPDATE ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_reservations_updated_at ON public.reservations IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_reviews_updated_at BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_reviews_updated_at ON public.reviews IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_users_updated_at ON public.users IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_id_fkey FOREIGN KEY (id) REFERENCES public.reservations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_fkey FOREIGN KEY (role) REFERENCES public.roles(role) ON UPDATE CASCADE ON DELETE SET DEFAULT;
