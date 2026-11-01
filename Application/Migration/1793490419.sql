ALTER TABLE comments ADD COLUMN parent_comment_id UUID DEFAULT null;
CREATE TABLE post_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    post_id UUID NOT NULL,
    user_id UUID NOT NULL,
    vote INT NOT NULL
);
ALTER TABLE post_votes ADD CONSTRAINT post_votes_user_id_key UNIQUE(user_id);
CREATE INDEX post_votes_post_id_index ON post_votes (post_id);
CREATE INDEX post_votes_user_id_index ON post_votes (user_id);
CREATE TABLE comment_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    comment_id UUID NOT NULL,
    user_id UUID NOT NULL,
    vote INT NOT NULL
);
ALTER TABLE comment_votes ADD CONSTRAINT comment_votes_user_id_key UNIQUE(user_id);
CREATE INDEX comment_votes_comment_id_index ON comment_votes (comment_id);
CREATE INDEX comment_votes_user_id_index ON comment_votes (user_id);
CREATE TABLE post_reactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    post_id UUID NOT NULL,
    user_id UUID NOT NULL,
    emoji TEXT NOT NULL
);
CREATE TABLE comment_reactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    comment_id UUID NOT NULL,
    user_id UUID NOT NULL,
    emoji TEXT NOT NULL
);
CREATE INDEX post_reactions_post_id_index ON post_reactions (post_id);
CREATE INDEX post_reactions_user_id_index ON post_reactions (user_id);
CREATE INDEX comment_reactions_comment_id_index ON comment_reactions (comment_id);
CREATE INDEX comment_reactions_user_id_index ON comment_reactions (user_id);
CREATE INDEX posts_user_id_index ON posts (user_id);
ALTER TABLE comment_reactions ADD CONSTRAINT comment_reactions_ref_comment_id FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE;
ALTER TABLE comment_reactions ADD CONSTRAINT comment_reactions_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE comment_votes ADD CONSTRAINT comment_votes_ref_comment_id FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE;
ALTER TABLE comment_votes ADD CONSTRAINT comment_votes_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE post_reactions ADD CONSTRAINT post_reactions_ref_post_id FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE;
ALTER TABLE post_reactions ADD CONSTRAINT post_reactions_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE post_votes ADD CONSTRAINT post_votes_ref_post_id FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE;
ALTER TABLE post_votes ADD CONSTRAINT post_votes_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE posts ADD CONSTRAINT posts_ref_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
