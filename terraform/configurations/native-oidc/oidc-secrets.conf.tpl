# OIDC provider configuration with sensitive information
# This file contains sensitive information and should be protected

oidc_provider entra {
    # issuer URL, client_id, client_secret values are obtained from IdP configuration (microsoft entra id in this example)
    issuer ${issuer};
    client_id ${client_id};
    client_secret ${client_secret};
    session_store oidc;
    logout_uri        /logout;
    post_logout_uri  ${post_logout_uri};
    logout_token_hint on;
    userinfo on;
}