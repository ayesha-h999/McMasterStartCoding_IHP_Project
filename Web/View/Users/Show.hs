module Web.View.Users.Show where
import Web.View.Prelude

data ShowView = ShowView { user :: User }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show User</h1>
        <dl>
            <dt>Email</dt><dd>{user.email}</dd>
            <dt>Password Hash</dt><dd>{user.passwordHash}</dd>
            <dt>Failed Login Attempts</dt><dd>{user.failedLoginAttempts}</dd>
            <dt>Name</dt><dd>{user.name}</dd>
        </dl>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Users" UsersAction
                            , breadcrumbText "Show User"
                            ]