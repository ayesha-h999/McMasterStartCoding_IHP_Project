module Web.View.Posts.Show where
import Web.View.Prelude
import qualified Text.MMark as MMark


data ShowView = ShowView { post :: Include "comments" Post }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>{post.title}</h1>
        <p>{post.createdAt |> timeAgo}</p>
        <div>{post.body |> renderMarkdown}</div>
        <h4>Comments:</h4>

        {addCommentButton post.id}

        <div>{forEach post.comments renderComment}</div>



        
        
   
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


renderComment comment = [hsx|
        <div class="mt-4">
            <h5>{comment.title}</h5>
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
