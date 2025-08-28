http {
    resolver 168.63.129.16 ipv4=on ipv6=off valid=300s;
    keyval_zone zone=oidc:8M     state=/opt/oidc_id_tokens.json     timeout=1h sync;

    oidc_provider entra {
        issuer ${issuer};
        client_id ${client_id};
        client_secret ${client_secret};
        session_store oidc;
    }
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