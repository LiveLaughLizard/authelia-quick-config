### Authelia Quick Config

A minimal values file with sane defaults to get up and running quickly.

These values does **NOT** enable Redis, you must install and configure that yourself (especially now that Bitnami is not free).

These values does **NOT** deploy Postgres, you must configure the chart to deploy it, or connect it to a pre-existing Postgres server.

These values use filesystem authentication unless you enable LDAP. If you continue with filesystem authentication, you can exec into the pod and modify `/config/users_database.yml` to add users.

Once deployed your OIDC endpoints can be found at:
https://auth.example.com/.well-known/openid-configuration
