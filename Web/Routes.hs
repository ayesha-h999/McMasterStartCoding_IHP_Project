module Web.Routes where
import IHP.RouterPrelude
import Generated.Types
import Web.Types

-- The welcome page at '/' is served by the static controller below.
-- Additional [routes|...|] blocks get appended by `new-controller`.
[routes|StaticController
GET /    WelcomeAction
|]

[routes|PostsController
GET /Posts PostsAction
GET /NewPost NewPostAction
POST /CreatePost CreatePostAction
GET /ShowPost?postId ShowPostAction
GET /EditPost?postId EditPostAction
POST /UpdatePost?postId UpdatePostAction
DELETE /DeletePost?postId DeletePostAction
|]

