module Web.Controller.Posts where

import Web.Controller.Prelude
import Web.View.Posts.Index
import Web.View.Posts.New
import Web.View.Posts.Edit
import Web.View.Posts.Show
import qualified Text.MMark as MMark


instance Controller PostsController where
    action PostsAction = do
        posts <- query @Post 
            |> orderByDesc #createdAt
            |> fetch
        posts <- posts
            |> collectionFetchRelated #userId
        render IndexView { .. }

    action NewPostAction = do
        ensureIsUser
        let post = newRecord
        render NewView { .. }

    action ShowPostAction { postId } = do
        post <- fetch postId
            >>= pure . modify #comments (orderByDesc #createdAt)
            >>= fetchRelated #comments
        render ShowView { .. }


    action EditPostAction { postId } = do
        ensureIsUser
        post <- fetch postId
        if post.userId == currentUser.id
            then render EditView { .. }
            else redirectTo PostsAction

    action UpdatePostAction { postId } = do
        ensureIsUser
        post <- fetch postId
        if post.userId /= currentUser.id
            then redirectTo PostsAction
        else do
            post
                |> buildPost
                |> ifValid \case
                    Left post -> render EditView { .. }
                    Right post -> do
                        post <- post |> updateRecord
                        setSuccessMessage "Post updated"
                        redirectTo EditPostAction { .. }

    action CreatePostAction = do
        ensureIsUser
        let post = newRecord @Post |> set #userId (get #id currentUser)
        post
            |> buildPost
            |> ifValid \case
                Left post -> render NewView { .. } 
                Right post -> do
                    post <- post |> createRecord
                    setSuccessMessage "Post created"
                    redirectTo PostsAction

    action DeletePostAction { postId } = do
        ensureIsUser
        post <- fetch postId
        if post.userId == currentUser.id
        then do
            deleteRecord post
            setSuccessMessage "Post deleted"
            redirectTo PostsAction
        else redirectTo PostsAction

buildPost post = post
    |> fill @'["title", "body"]
    |> validateField #title nonEmpty
    |> validateField #body nonEmpty
    |> validateField #body isMarkdown


isMarkdown :: Text -> ValidatorResult
isMarkdown text =
    case MMark.parse "" text of
        Left _ -> Failure "Please provide valid Markdown"
        Right _ -> Success

