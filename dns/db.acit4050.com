$TTL    604800
@       IN      SOA     ns1.acit4050.com. root.acit4050.com. (
                  3       ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL
;
; name servers - NS records
       IN      NS      ns1.acit4050.com.

; name servers - A records
ns1.acit4050.com.          IN      A      192.168.247.128
goodsite.acit4050.com.        IN      A     192.168.247.128
victim.acit4050.com.        IN      A      192.168.247.129
kali.acit4050.com.        IN      A      192.168.247.130

