module Web.View.Users.Index where
import Web.View.Prelude

data IndexView = IndexView { users :: [User] }

instance View IndexView where
    html IndexView { .. } = [hsx|
        {breadcrumb}

        <h1>Index<a href={pathTo NewUserAction} class="btn btn-primary ms-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Email</th>
                        <th>Password Hash</th>
                        <th>Failed Login Attempts</th>
                        <th>Name</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach users renderUser}</tbody>
            </table>
            
        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Users" UsersAction
                ]

renderUser :: User -> Html
renderUser user = [hsx|
    <tr>
        <td>{user.email}</td>
        <td>{user.passwordHash}</td>
        <td>{user.failedLoginAttempts}</td>
        <td>{user.name}</td>
        <td><a href={ShowUserAction user.id}>Show</a></td>
        <td><a href={EditUserAction user.id} class="text-muted">Edit</a></td>
        <td><a href={DeleteUserAction user.id} class="js-delete text-muted">Delete</a></td>
    </tr>
|]