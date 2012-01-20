backend default {
    .host = "127.0.0.1";
    .port = "80";
    .probe = {
        .url = "/ping";
        .timeout  = 1s;
        .interval = 10s;
        .window    = 5;
        .threshold = 2;
    }
}

acl purge {
    "127.0.0.1";
    "localhost";
}

sub hotlink_notes {
    if (
            req.http.host == "notes.depad.fr" &&
            req.url ~ "\.(js|css|jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf)$" &&
            req.http.referer !~ "^http://notes.depad.fr/"
       )
    {
        set req.http.New-Location = regsub(req.url,"$","/");
        error 302 "No hot linking please";
    }
}

sub vcl_recv {
    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }
    if (req.request == "PURGE") {
        if (!client.ip ~ purge) {
            error 405 "This IP is not allowed to send PURGE requests.";
        }
        return (lookup);
    }
    if (req.request == "POST") {
        return (pass);
    }
    set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|has_js)=[^;]*", "");
    set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");
    if (req.http.Cookie ~ "^\s*$") {
        unset req.http.Cookie;
    }
    if (req.http.host ~ "(?i)^notes.depad.fr$" ) {
        call hotlink_notes;
        set req.http.host = "notes.depad.fr";
        set req.backend = default;
        if (req.url ~ "/feed") {
            return (pass);
        }
        if ( req.url ~ "^/wp-(login|admin)" || req.http.Cookie ~ "wordpress_logged_in_" ) {
            return (pass);
        }
        set req.http.Cookie = regsuball(req.http.Cookie, "has_js=[^;]+(; )?", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "__qc.=[^;]+(; )?", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-1=[^;]+(; )?", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-time-1=[^;]+(; )?", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "wordpress_test_cookie=[^;]+(; )?", "");
        if (req.http.cookie ~ "^ *$") {
            unset req.http.cookie;
        }
        if (req.url ~ ".(jpeg|jpg|png|gif|ico|js|css|swf|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)$") {
            unset req.http.cookie;
        }
        if (req.http.Accept-Encoding) {
            if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
                remove req.http.Accept-Encoding;
            } elsif (req.http.Accept-Encoding ~ "gzip") {
                set req.http.Accept-Encoding = "gzip";
            } elsif (req.http.Accept-Encoding ~ "deflate") {
                set req.http.Accept-Encoding = "deflate";
            } else {
                remove req.http.Accept-Encoding;
            }
        }
        if (req.http.Cookie ~ "wordpress_" || req.http.Cookie ~ "comment_") {
            return (pass);
        }
        if (!req.http.cookie) {
            unset req.http.cookie;
        }
    } else {
        error 404 "Unknown virtual host";
    }
    if (req.request != "GET" &&
            req.request != "HEAD" &&
            req.request != "PUT" &&
            req.request != "POST" &&
            req.request != "TRACE" &&
            req.request != "OPTIONS" &&
            req.request != "DELETE") {
        return (pipe);
    }
    if (req.request != "GET" && req.request != "HEAD") {
        return (pass);
    }
    if (req.http.Accept-Encoding) {
        if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
            remove req.http.Accept-Encoding;
        } elsif (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate" && req.http.user-agent !~ "Internet Explorer") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            remove req.http.Accept-Encoding;
        }
    }
    if (req.http.Authorization || req.http.Cookie) {
        return (pass);
    }
    return (lookup);
}

sub vcl_pass {
    return (pass);
}

sub vcl_hash {
    hash_data(req.url);
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (hash);
}

sub vcl_hit {
    return (deliver);
}

sub vcl_miss {
    return (fetch);
}

sub vcl_fetch {
    if (req.url ~ "^/w00tw00t") {
        error 403 "Not permitted";
    }
    if ( req.url ~ ".(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)$") {
        set beresp.ttl = 7200s;
        unset beresp.http.set-cookie;
        return (deliver);
    }
    if ( req.http.host == "notes.depad.fr" &&
            ( req.url ~ "^/tag" || req.url ~ "^/category")
       ) {
        set beresp.ttl = 7200s;
        unset beresp.http.set-cookie;
        return (deliver);
    }
    if (beresp.ttl <= 0s ||
            beresp.http.Set-Cookie ||
            beresp.http.Vary == "*") {
        /*
         * Mark as "Hit-For-Pass" for the next 2 minutes
         */
        set beresp.ttl = 120 s;
        return (hit_for_pass);
    }
}

sub vcl_deliver {
    remove resp.http.X-Varnish;
    remove resp.http.Via;
    remove resp.http.Server;
    remove resp.http.X-Powered-By;
    return (deliver);
}

sub vcl_error {
    if (obj.status == 302) {
        set obj.http.Location = "http://notes.depad.fr";
    } else {
        set obj.http.Content-Type = "text/html; charset=utf-8";
        set obj.http.Retry-After = "5";
        synthetic {"<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8">
        <meta autor="MonPoney">
        <meta http-equiv="Pragma" content="no-cache">
        <title>Error "} + obj.status + " " + obj.response + {"</title>
        <style>
            @charset "utf-8";
            body {
                font-family:Arial, Helvetica, sans-serif;
                font-size:16px;
                font-weight:100;
                background-color: #f9f8f8;
            }
            h4 {
                text-align:center;
                margin-top:50px;
            }
            #accueil {
                background-color:white;
                border:1px solid #ccc;
                width:980px;
                height:500px;
                margin-left:auto;
                margin-right:auto;
                margin-top:50px;
            }
            #accueil p {
                font-size:12px;
            }
        </style>
    </head>
    <body>
        <div id="accueil">
            <h4>Error "} + obj.status + {"<span frown>:(</span></h4>
            <p>We're very sorry, but the page could not be loaded properly.</p>
            <p>This should be fixed very soon, and we apologize for any inconvenience.</p>
            <h4>Erreur "} + obj.status + {" <span frown>:(</span></h4>
            <p>D&eacute;sol&eacute; mais la page ne peut etre charg&eacute; correctement.</p>
            <p>Toutes nos escuses, Cela va etre fix&eacute; rapidement.</p>
        </div>
    </body>
</html>"};
    return (deliver);
    }
}

sub vcl_init {
    return (ok);
}

sub vcl_fini {
    return (ok);
}
