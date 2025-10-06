http {
    # make sure your public DNS resolver is specified with the resolver directive, for example using azure dns for resolving the microsoft entra id
    resolver ${resolver} ipv4=on ipv6=off valid=300s;
    keyval_zone zone=oidc:8M     state=/opt/oidc_id_tokens.json     timeout=1h sync;

    # Include OIDC provider configuration from protected file
    include /etc/nginx/oidc-provider.conf;
    server {
        listen 443 ssl;
        server_name demo.example.com;

        ssl_certificate /etc/nginx/certs/fullchain.pem;
        ssl_certificate_key /etc/nginx/private/key.pem;
        location / {
            auth_oidc entra;
            proxy_set_header sub $oidc_claim_sub;
            proxy_set_header email $oidc_claim_email;
            proxy_set_header name $oidc_claim_name;

            proxy_pass http://127.0.0.1:8080;
        }

        # Post-logout endpoint - this example uses /post_logout/ 
        # You can change this path or customize the response as needed
        # Make sure to update the post_logout_uri variable accordingly
        location /post_logout/ {
            return 200 "You have been logged out.\n";
            default_type text/plain;
        }
    }

    server {
        listen 8080;

        location / {
            return 200 "Hello, $http_username!\n Your email is $http_email\n Your unique id is $http_sub\n";
            default_type text/plain;
        }
    }
}
stream {
  resolver 127.0.0.1:49153 valid=20s;

  server {
    listen 9000;
    zone_sync;
    zone_sync_server internal.nginxaas.nginx.com:9000 resolve;
  }
}