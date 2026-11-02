module Web.Controller.Comments where

import Web.Controller.Prelude
import Web.View.Comments.Index
import Web.View.Comments.New
import Web.View.Comments.Edit
import Web.View.Comments.Show

instance Controller CommentsController where
    action CommentsAction = do
        comments <- query @Comment 
            |> orderByDesc #createdAt
            |> fetch
        render IndexView { .. }

    action NewCommentAction { postId } = do
        let comment = newRecord
                |> set #postId postId
        post <- fetch postId
        render NewView { .. }

    action ShowCommentAction { commentId } = do
        comment <- fetch commentId
        render ShowView { .. }

    action EditCommentAction { commentId } = do
        ensureIsUser
        comment <- fetch commentId
        if comment.userId == unpackId currentUser.id
            then render EditView { .. }
            else redirectTo ShowPostAction { postId = comment.postId }
        render EditView { .. }

    action UpdateCommentAction { commentId } = do
        ensureIsUser
        comment <- fetch commentId
        if comment.userId == unpackId currentUser.id
            then
                comment
                    |> buildComment
                    |> ifValid \case
                        Left comment -> render EditView { .. }
                        Right comment -> do
                            comment <- comment |> updateRecord
                            setSuccessMessage "Comment updated"
                            redirectTo ShowPostAction { postId = comment.postId }
            else
                redirectTo ShowPostAction { postId = comment.postId }

    action CreateCommentAction = do
        ensureIsUser
        let comment = newRecord @Comment
        comment
            |> set #userId (unpackId currentUser.id)
            |> buildComment
            |> ifValid \case
                Left comment -> do
                    post <- fetch comment.postId
                    render NewView { .. } 
                Right comment -> do
                    comment <- comment |> createRecord
                    setSuccessMessage "Comment created"
                    redirectTo ShowPostAction { postId = comment.postId }

    action DeleteCommentAction { commentId } = do
        ensureIsUser
        comment <- fetch commentId
        if comment.userId == unpackId currentUser.id
            then do
                deleteRecord comment
                setSuccessMessage "Comment deleted"
                redirectTo CommentsAction
            else do
                redirectTo ShowPostAction { postId = comment.postId }

    action VoteCommentAction { commentId } = do
        ensureIsUser
        comment <- fetch commentId

        let vote = param @Int "vote"

        if vote /= 1 && vote /= -1
            then redirectTo ShowPostAction { postId = comment.postId }
            else do
                existingVote <- query @CommentVote
                    |> filterWhere (#commentId, commentId)
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
                        newRecord @CommentVote
                            |> set #commentId commentId
                            |> set #userId currentUser.id
                            |> set #vote vote
                            |> createRecord
                        pure ()

                setSuccessMessage "Vote saved!"
                redirectTo ShowPostAction { postId = comment.postId }

    action ReactToCommentAction { commentId } = do
        ensureIsUser

        comment <- fetch commentId
        let emoji = param @Text "emoji"

        if emoji `notElem` ["❤️", "😂", "😮", "😢", "🎉", "🙏"]
            then redirectTo ShowPostAction { postId = comment.postId }
            else do
                existingReaction <- query @CommentReaction
                    |> filterWhere (#commentId, commentId)
                    |> filterWhere (#userId, currentUser.id)
                    |> filterWhere (#emoji, emoji)
                    |> fetchOneOrNothing

                case existingReaction of
                    Just existingReaction ->
                        deleteRecord existingReaction

                    Nothing -> do
                        newRecord @CommentReaction
                            |> set #commentId commentId
                            |> set #userId currentUser.id
                            |> set #emoji emoji
                            |> createRecord
                        pure ()

                setSuccessMessage "Reaction saved!"
                redirectTo ShowPostAction { postId = comment.postId }



buildComment comment = comment
    |> fill @'["postId", "title", "body"]
    |> validateField #title nonEmpty
    |> validateField #body nonEmpty
