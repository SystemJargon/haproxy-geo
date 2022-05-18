#POC 

DNS test, LB, HAProxy.

Since decomissioned because NFLX blocks proxies by known Data Centres.

## Roles

## Poisoned DNS

Hijacks various ‘geo-sensitive’ domains and inserts false A records pointing to an IP in the NAT Cluster

## Load Balancer

This cluster rewrites HTTP/HTTPS user traffic for ‘geo-sensitive’ domains to a specified port on the HAProxy cluster. Traffic is rewritten
based off of destination IP and as such the cluster needs to have a large number of Addresses available. There is no requirement for this
cluster to be located within real-country or to use public address space.

## HAProxy Cluster

Receives rewritten traffic from the NAT Cluster and opens connections to the relevant service. 

If a service is HTTP only it is proxied by
reading the HTTP GET and opening a connection to the relevant host. 

If HTTP and HTTPS are required, the proxy is configured with an
individual service per port as no discernible information is available within an HTTPS stream.