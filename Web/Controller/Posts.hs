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
        author <- fetch post.userId

        allComments <- query @Comment
            |> filterWhere (#postId, postId)
            |> orderByDesc #createdAt
            |> fetch

        let buildCommentTree comment = do
                commenter <- fetch (Id comment.userId :: Id' "users")

                commentVotes <- query @CommentVote
                    |> filterWhere (#commentId, comment.id)
                    |> fetch

                let upvotes = length (filter (\vote -> vote.vote == 1) commentVotes)
                let downvotes = length (filter (\vote -> vote.vote == -1) commentVotes)

                commentReactions <- query @CommentReaction
                    |> filterWhere (#commentId, comment.id)
                    |> fetch

                let children = filter (\child -> child.parentCommentId == Just comment.id) allComments
                childComments <- forM children buildCommentTree

                pure CommentWithDetails
                    { commentDetails = comment
                    , commenterDetails = commenter
                    , commentUpvotes = upvotes
                    , commentDownvotes = downvotes
                    , commentReactionDetails = commentReactions
                    , childComments = childComments
                    }

        let rootComments = filter (\comment -> comment.parentCommentId == Nothing) allComments
        commentsWithUsers <- forM rootComments buildCommentTree

        postVotes <- query @PostVote
            |> filterWhere (#postId, postId)
            |> fetch
        let upvoteCount = length (filter (\vote -> vote.vote == 1) postVotes)
        let downvoteCount = length (filter (\vote -> vote.vote == -1) postVotes)
        postReactions <- query @PostReaction
            |> filterWhere (#postId, postId)
            |> fetch
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

    action VotePostAction { postId } = do
        ensureIsUser

        let vote = param @Int "vote"

        if vote /= 1 && vote /= -1
            then redirectTo (ShowPostAction { postId })
            else do
                existingVote <- query @PostVote
                    |> filterWhere (#postId, postId)
                    |> filterWhere (#userId, currentUser.id)
                    |> fetchOneOrNothing

                case existingVote of
                    Just existingVote ->
                        if existingVote.vote == vote
                            then deleteRecord existingVote
                            else do
                                existingVote
                                    |> set #vote vote
                                    |> updateRecord
                                pure ()

                    Nothing -> do
                        newRecord @PostVote
                            |> set #postId postId
                            |> set #userId currentUser.id
                            |> set #vote vote
                            |> createRecord
                        pure ()

                setSuccessMessage "Vote saved!"
                redirectTo (ShowPostAction { postId })

    action ReactToPostAction { postId } = do
        ensureIsUser

        let emoji = param @Text "emoji"

        if emoji `notElem` ["❤️", "😂", "😮", "😢", "🎉", "🙏"]
            then redirectTo (ShowPostAction { postId })
            else do
                existingReaction <- query @PostReaction
                    |> filterWhere (#postId, postId)
                    |> filterWhere (#userId, currentUser.id)
                    |> filterWhere (#emoji, emoji)
                    |> fetchOneOrNothing

                case existingReaction of
                    Just existingReaction -> do
                        deleteRecord existingReaction

                    Nothing -> do
                        newRecord @PostReaction
                            |> set #postId postId
                            |> set #userId currentUser.id
                            |> set #emoji emoji
                            |> createRecord
                        pure ()

                setSuccessMessage "Reaction saved!"
                redirectTo (ShowPostAction { postId })
    
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

