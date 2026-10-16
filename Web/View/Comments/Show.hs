module Web.View.Comments.Show where
import Web.View.Prelude

data ShowView = ShowView { comment :: Comment }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Comment</h1>
        <dl>
            <dt>Post Id</dt><dd>{comment.postId}</dd>
            <dt>Author</dt><dd>{comment.author}</dd>
            <dt>Body</dt><dd>{comment.body}</dd>
        </dl>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Comments" CommentsAction
                            , breadcrumbText "Show Comment"
                            ]