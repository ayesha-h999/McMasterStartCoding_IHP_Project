module Web.View.Posts.Index where
import Web.View.Prelude

data IndexView = IndexView { posts :: [Include "userId" Post] }

instance View IndexView where
    html IndexView { .. } = [hsx|
        {breadcrumb}

        <h1>Index {newPostButton}</h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Post Title</th>
                        <!-- <th>Body</th> -->
                        <th></th>
                        <th></th>
                        <!-- <th></th> -->
                    </tr>
                </thead>
                <tbody>{forEach posts renderPost}</tbody>
            </table>
            
        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Posts" PostsAction
                ]

newPostButton :: Html
newPostButton =
    case currentUserOrNothing of
        Just _ -> [hsx|
            <a href={pathTo NewPostAction} class="btn btn-primary ms-4">+ New</a>
        |]
        Nothing -> mempty

renderPost :: Include "userId" Post -> Html
renderPost post = [hsx|
    <tr>
        <td>
            <a href={ShowPostAction post.id}>{post.title}</a>
            <br/>
            <small>Posted by: {post.userId.name}</small>
        </td>
        {postActions}
    </tr>
|]
    where
        postActions = case currentUserOrNothing of
            Just user | user.id == post.userId.id -> [hsx|
                <td><a href={EditPostAction post.id} class="text-muted">Edit</a></td>
                <td><a href={DeletePostAction post.id} class="js-delete text-muted">Delete</a></td>
            |]
            _ -> [hsx|
                <td></td>
                <td></td>
            |]