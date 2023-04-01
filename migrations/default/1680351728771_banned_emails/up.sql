CREATE OR REPLACE FUNCTION check_banned_emails()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
inserted_email text;
BEGIN
SELECT NEW.email INTO inserted_email;
IF EXISTS(SELECT b.email FROM banned_emails b WHERE
b.email = inserted_email)
THEN
Raise exception 'The email address % is banned!',
inserted_email;
END IF;
RETURN NEW;
END;
$$;
