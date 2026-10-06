module Web.View.Posts.Show where
import Web.View.Prelude

data ShowView = ShowView { post :: Post }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Post</h1>
        <dl>
            <dt>Title</dt><dd>{post.title}</dd>
            <dt>Body</dt><dd>{post.body}</dd>
        </dl>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Posts" PostsAction
                            , breadcrumbText "Show Post"
                            ]