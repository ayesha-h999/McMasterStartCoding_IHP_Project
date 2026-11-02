module Web.View.Posts.Show where
import Web.View.Prelude
import qualified Text.MMark as MMark


data ShowView = ShowView 
    { post :: Include "comments" Post
    , author :: User
    , commentsWithUsers :: [(Comment, User, Int, Int, [CommentReaction])]
    , upvoteCount :: Int
    , downvoteCount :: Int
    , postReactions :: [PostReaction]
    }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <div class="post-card">
    <h1>{post.title}</h1>
    <div class="post-meta">
        <span>Posted by: {author.name}</span>
        <span>{post.createdAt |> timeAgo}</span>
    </div>
    <div class="post-body">
        {post.body |> renderMarkdown}
    </div>
    <div class="post-voting">
        <span>👍 {upvoteCount}</span>
        <span>👎 {downvoteCount}</span>
        {voteButtons post.id}
    </div>
    <div class="post-reactions">
        {postReactionButtons post.id postReactions}
    </div>
</div>
        <h4 id="ctitle">Comments:</h4>

        {addCommentButton post.id}

        <div>{forEach commentsWithUsers renderComment}</div>



        
        
   
        |] 

        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Posts" PostsAction
                            , breadcrumbText "Show Post"
                            ]

renderMarkdown text =
    case text |> MMark.parse "" of
        Left error -> "Something went wrong"
        Right markdown -> MMark.render markdown |> tshow |> preEscapedToHtml


renderComment (comment, commenter, upvotes, downvotes, commentReactions) = [hsx|
    <div class="comment-card">
        <h5>{comment.title}</h5>
        <small>Commented by: {commenter.name}</small>
        <p>{comment.body}</p>

        <div class="comment-voting">
            <span>👍 {upvotes}</span>
            <span>👎 {downvotes}</span>
            {commentVoteButtons comment.id}
        </div>
        <div class="comment-reactions">
            {commentReactionButtons comment.id commentReactions}
        </div>
    </div>
|]

addCommentButton :: Id Post -> Html
addCommentButton postId =
    case currentUserOrNothing of
        Just _ -> [hsx|
            <a href={NewCommentAction postId}>Add Comment</a>
        |]
        Nothing -> mempty

voteButtons :: Id Post -> Html
voteButtons postId =
    case currentUserOrNothing of
        Just _ -> [hsx|
            <form method="POST" action={VotePostAction postId}>
                <button type="submit" name="vote" value="1">
                    👍 Upvote
                </button>
                <button type="submit" name="vote" value="-1">
                    👎 Downvote
                </button>
            </form>
        |]
        Nothing -> [hsx|
            
        |]

commentVoteButtons :: Id Comment -> Html
commentVoteButtons commentId =
    case currentUserOrNothing of
        Just _ -> [hsx|
            <form method="POST" action={VoteCommentAction commentId}>
                <button type="submit" name="vote" value="1">
                    👍 Upvote
                </button>
                <button type="submit" name="vote" value="-1">
                    👎 Downvote
                </button>
            </form>
        |]
        Nothing -> mempty

postReactionButtons :: Id Post -> [PostReaction] -> Html
postReactionButtons postId reactions =
    case currentUserOrNothing of
        Just _ -> [hsx|
            <div class="post-reaction-buttons">
                {forEach ["❤️", "😂", "😮", "😢", "🎉", "🙏"] (renderReactionButton postId reactions)}
            </div>
        |]
        Nothing -> mempty

renderReactionButton :: Id Post -> [PostReaction] -> Text -> Html
renderReactionButton postId reactions emoji = [hsx|
    <form method="POST" action={ReactToPostAction postId}>
        <button type="submit" name="emoji" value={emoji}>
            {emoji} {reactionCount reactions emoji}
        </button>
    </form>
|]

commentReactionButtons :: Id Comment -> [CommentReaction] -> Html
commentReactionButtons commentId reactions =
    case currentUserOrNothing of
        Just _ -> [hsx|
            <div class="comment-reaction-buttons">
                {forEach ["❤️", "😂", "😮", "😢", "🎉", "🙏"] (renderCommentReactionButton commentId reactions)}
            </div>
        |]
        Nothing -> mempty

renderCommentReactionButton :: Id Comment -> [CommentReaction] -> Text -> Html
renderCommentReactionButton commentId reactions emoji = [hsx|
    <form method="POST" action={ReactToCommentAction commentId}>
        <button type="submit" name="emoji" value={emoji}>
            {emoji} {commentReactionCount reactions emoji}
        </button>
    </form>
|]

reactionCount :: [PostReaction] -> Text -> Int
reactionCount reactions emoji =
    length (filter (\reaction -> reaction.emoji == emoji) reactions)

commentReactionCount :: [CommentReaction] -> Text -> Int
commentReactionCount reactions emoji =
    length (filter (\reaction -> reaction.emoji == emoji) reactions)


