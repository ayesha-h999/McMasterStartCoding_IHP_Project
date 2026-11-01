ALTER TABLE comment_votes DROP COLUMN vote;
ALTER TABLE comment_votes ADD COLUMN vote vote_type NOT NULL;
ALTER TABLE post_votes DROP COLUMN vote;
ALTER TABLE post_votes ADD COLUMN vote vote_type NOT NULL;
CREATE TYPE vote_type AS ENUM ('upvote', 'downvote');
