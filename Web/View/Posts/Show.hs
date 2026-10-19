module Web.View.Posts.Show where
import Web.View.Prelude
import qualified Text.MMark as MMark


data ShowView = ShowView { post :: Post }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>{post.title}</h1>
        <p>{post.createdAt |> timeAgo}</p>
        <div>{post.body |> renderMarkdown}</div>
        <!-- <dl>
            <dt>Title</dt><dd>{post.title}</dd>
            <dt>Body</dt><dd>{post.body}</dd>
        </dl> -->
        <a href={NewCommentAction post.id}>Add Comment</a>

        


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

