-- Your database schema. Use the Schema Designer at http://localhost:8001/ to add some tables.
CREATE TYPE vote_type AS ENUM ('upvote', 'downvote');
CREATE TABLE comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    post_id UUID NOT NULL,
    user_id UUID NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    title TEXT DEFAULT '' NOT NULL,
    parent_comment_id UUID DEFAULT NULL
);
CREATE INDEX comments_post_id_index ON comments (post_id);
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    failed_login_attempts INT DEFAULT 0 NOT NULL,
    name TEXT NOT NULL
);
CREATE TABLE post_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    post_id UUID NOT NULL,
    user_id UUID NOT NULL,
    vote vote_type NOT NULL,
    UNIQUE(user_id, post_id)
);
CREATE INDEX post_votes_post_id_index ON post_votes (post_id);
CREATE INDEX post_votes_user_id_index ON post_votes (user_id);
CREATE TABLE comment_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    comment_id UUID NOT NULL,
    user_id UUID NOT NULL,
    vote vote_type NOT NULL,
    UNIQUE(user_id, comment_id)
);
CREATE INDEX comment_votes_comment_id_index ON comment_votes (comment_id);
CREATE INDEX comment_votes_user_id_index ON comment_votes (user_id);
CREATE TABLE post_reactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    post_id UUID NOT NULL,
    user_id UUID NOT NULL,
    emoji TEXT NOT NULL,
    UNIQUE(user_id, post_id, emoji)
);
CREATE TABLE comment_reactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    comment_id UUID NOT NULL,
    user_id UUID NOT NULL,
    emoji TEXT NOT NULL,
    UNIQUE(user_id, comment_id, emoji)
);
CREATE INDEX post_reactions_post_id_index ON post_reactions (post_id);
CREATE INDEX post_reactions_user_id_index ON post_reactions (user_id);
CREATE INDEX comment_reactions_comment_id_index ON comment_reactions (comment_id);
CREATE INDEX comment_reactions_user_id_index ON comment_reactions (user_id);
CREATE TABLE posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
CREATE INDEX posts_user_id_index ON posts (user_id);
ALTER TABLE comment_reactions ADD CONSTRAINT comment_reactions_ref_comment_id FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE;
ALTER TABLE comment_reactions ADD CONSTRAINT comment_reactions_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE comment_votes ADD CONSTRAINT comment_votes_ref_comment_id FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE;
ALTER TABLE comment_votes ADD CONSTRAINT comment_votes_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE comments ADD CONSTRAINT comments_ref_parent_comment_id FOREIGN KEY (parent_comment_id) REFERENCES comments (id) ON DELETE NO ACTION;
ALTER TABLE comments ADD CONSTRAINT comments_ref_post_id FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE;
ALTER TABLE post_reactions ADD CONSTRAINT post_reactions_ref_post_id FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE;
ALTER TABLE post_reactions ADD CONSTRAINT post_reactions_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE post_votes ADD CONSTRAINT post_votes_ref_post_id FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE;
ALTER TABLE post_votes ADD CONSTRAINT post_votes_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE posts ADD CONSTRAINT posts_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
