ALTER TABLE comment_votes DROP CONSTRAINT comment_votes_user_id_key;
ALTER TABLE post_votes DROP CONSTRAINT post_votes_user_id_key;
ALTER TABLE comments ADD CONSTRAINT comments_ref_parent_comment_id FOREIGN KEY (parent_comment_id) REFERENCES comments (id) ON DELETE NO ACTION;
