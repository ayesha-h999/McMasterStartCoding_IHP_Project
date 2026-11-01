module Web.View.Posts.Show where
import Web.View.Prelude
import qualified Text.MMark as MMark


data ShowView = ShowView 
    { post :: Include "comments" Post
    , author :: User
    , commentsWithUsers :: [(Comment, User)]
    , upvoteCount :: Int
    , downvoteCount :: Int
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
        <span>▲ {upvoteCount}</span>
        <span>▼ {downvoteCount}</span>
        {voteButtons post.id}
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


renderComment (comment, commenter) = [hsx|
    <div class="comment-card">
        <h5>{comment.title}</h5>
        <small>Commented by: {commenter.name}</small>
        <p>{comment.body}</p>
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
                    ▲ Upvote
                </button>
                <button type="submit" name="vote" value="-1">
                    ▼ Downvote
                </button>
            </form>
        |]
        Nothing -> [hsx|
            
        |]
