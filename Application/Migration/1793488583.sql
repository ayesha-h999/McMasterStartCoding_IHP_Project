ALTER TABLE comments DROP COLUMN author;
ALTER TABLE comments ADD COLUMN user_id UUID NOT NULL;
ALTER TABLE posts DROP COLUMN author;
ALTER TABLE posts ADD COLUMN user_id UUID NOT NULL;
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE DEFAULT null,
    failed_login_attempts INT DEFAULT 0 NOT NULL,
    name TEXT NOT NULL
);
