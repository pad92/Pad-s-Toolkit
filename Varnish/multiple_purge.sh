#!/usr/bin/env sh

SRV_PROD='192.168.1.1:81
192.168.1.2:81'
SRV_PREPROD='10.0.0.1:81
10.0.0.2:81'

if [ "$#" -ne "2" ]; then
    echo "Usage : $0 [prod|preprod] [js|css]"
    exit 1
fi

SRV_ENV=$1
EXTENS=$2

case $SRV_ENV in
    prod)
        for SRV in $SRV_PROD; do
            if [[ "$EXTENS" == "js" || "$EXTENS" == "css" ]]; then
                echo "$SRV : "
                curl -s -I http://$SRV/RidfowHudNanlephOo_purge_$EXTENS | grep ^HTTP
            fi
        done
        ;;
    preprod)
        for SRV in $SRV_PREPROD; do
            if [[ "$EXTENS" == "js" || "$EXTENS" == "css" ]]; then
                echo "$SRV : "
                curl -s -I http://$SRV/RidfowHudNanlephOo_purge_$EXTENS | grep ^HTTP
            fi
        done
        ;;
    *)
        echo "unknow env"
        ;;
esac


## Varnish Configuration ##

# # ADDING ACL ALLOWED
# acl purge {
#     "192.168.1.1";
#     "192.168.1.2";
#     "10.0.0.1";
#     "10.0.0.2";
#     "127.0.0.1";
# }
# 
# # ADD IN VCL_RECV
# if (req.url ~ "^/RidfowHudNanlephOo_purge_") {
#     if (!client.ip ~ purge) {
#         error 405 "Not allowed.";
#     }
#     if (req.url ~ "css$") {
#         ban("req.http.host ~ domaine.ltd$  && req.url ~ \.css");
#         error 200 "css purge";
#     } else if  (req.url ~ "js$") {
#         ban("req.http.host ~ domaine.ltd$ && req.url ~ \.js");
#         error 200 "js purge";
#     } else {
#         error 200 "nothing to do";
#     }
# }
