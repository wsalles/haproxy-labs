# haproxy-labs

A simple project to create an architecture with High Availability.

---

![ha-proxy](https://www.haproxy.org/img/HAProxyCommunityEdition_60px.png)

# Requirements

- [VirtualBox v7](https://www.virtualbox.org/wiki/Downloads) *(**not recommended** for M1/M2 users)*
- [VMware Fusion Player v13](https://customerconnect.vmware.com/en/evalcenter?p=fusion-player-personal-13) *(**recommended** for M1/M2 users)*
- [Vagrant v2.3.6](https://developer.hashicorp.com/vagrant/downloads?product_intent=vagrant)
- [Wireshark](https://www.wireshark.org/download.html)

---

# Getting Started

## How does HA Proxy work?

[**HAProxy**](https://www.haproxy.org/) is a free, very fast and reliable Reverse-Proxy offering High Availability, Load Balancing, and proxying for TCP and HTTP-based applications.

---

### Diagram

| ![ha-proxy-diagram](assets/haprxoy-load-balancing-diagram.png) | 
|:--:| 
| *A simple point of view on what is Load Balance* |

---

### Architecture

| ![ha-proxy-arch](assets/ha-proxy-lb-setup.jpeg) | 
|:--:| 
| *HA-Proxy + KeepAlived* |

---

### Algorithms

**HAProxy** has load balancing algorithms, below I will talk a little bit about them. So, you can define many strategies to balance your workload:

- **[Round-robin](https://en.wikipedia.org/wiki/Round-robin_scheduling)** has no validation, it just sends the same requests to each server. Perfect for stateless application. Simple to manage:
  ```
  ...
  backend back-nginxes
    balance roundrobin
    server nginx1 172.10.10.101:80
    server nginx2 172.10.10.102:80
    server nginx3 172.10.10.103:80
  ```
- **Weight Robin:** As the name says, it's the weighted Round-robin. The node that has more weight will receive more requests.
  ```
  ...
  backend back-nginxes
    balance roundrobin
    server nginx1 172.10.10.101:80 weight 3
    server nginx2 172.10.10.102:80 weight 2
    server nginx3 172.10.10.103:80 weight 1
  ```
- **Least Connection**: Most used for long-term Layer 4 (TCP) communication, for example, a database connection.
  ```
  ...
  backend back-nginxes
    balance leastconn
    server nginx1 172.10.10.101:80
    server nginx2 172.10.10.102:80
    server nginx3 172.10.10.103:80
  ```

  - with weight:
    ```
    ...
    backend back-nginxes
      balance roundrobin
      server nginx1 172.10.10.101:80 weight 5
      server nginx2 172.10.10.102:80 weight 3
      server nginx3 172.10.10.103:80 weight 1
    ```
- **Hash URI**: Ideal for load balancing caching servers such as Squid.
  ```
  ...
  backend back-nginxes
    balance uri
    server nginx1 172.10.10.101:80
    server nginx2 172.10.10.102:80
    server nginx3 172.10.10.103:80
  ```
- **First Available**: Not very interesting, but it makes the list. Basically, you can define a maximum number of connections (maxconn) for the first server and when it overflows, the requests would be directed to the others.
  ```
  ...
  backend back-nginxes
    balance first
    server nginx1 172.10.10.101:80 maxconn 2
    server nginx2 172.10.10.102:80 maxconn 2
    server nginx3 172.10.10.103:80 maxconn 5
  ```

---
## How to setup the Virtual Machines

1. First of all, choose your favorite provider according to the recommendation above.
1. If the choice was VirtualBox, you need to make sure that you have a **private network** on VirtualBox. For that, just do:
   1. Open the VirtualBox and go to: **File > Tools > Network Manager > Host-only Networks**
1. However, here we will be using **VMWare Fusion Player**. For that, just do:
   ```shell
   make setup
   make up
   ```

   StdOut:
   ```shell
   ...
   ==> ubuntu-nginx-3: Running provisioner: shell...
       ubuntu-nginx-3: Running: inline script
       ubuntu-nginx-3: INSTALLER: Installation complete and ready to use!
   ```

1. Test the connection to verify that everything is OK:
   ```shell
   make test
   ```

   StdOut:
   ```shell
   > make test
   ansible all -m ping -o
   172.10.10.103 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   172.10.10.102 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   172.10.10.101 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   172.10.10.201 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   172.10.10.202 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   ```

---

## How to setup HA Proxy

You can customize your [**haproxy.cfg**](vagrantfiles/haproxy/haproxy.cfg) using filtering rules, redirection, etc.

Let's see some examples below.

---

### ACL

ACL is used for decision-making, it uses conditionals to return **TRUE** or **FALSE** and based on the result of ACL, we can make a decision.

You can check the [**ACL documentation**](https://cbonte.github.io/haproxy-dconv/2.3/configuration.html#7) written by HAProxy team.

#### Usage Examples

- Declaration:
  ```
  acl is_private_network src 172.10.10.0/24
  ```
- Explanation:
  | Declare | ACL name           | Method (fetching sample) | Compare values |
  | ------- | ------------------ | ------------------------ | -------------- |
  | acl     | is_private_network | src                      | 172.10.10.0/24 |
#### Use Cases

- PATH

  | Line | Explanation |
  | ---- | ----------- |
  | `acl is_post_jan path -i /posts/janeiro/15` | Compare if the full `path` is `/posts/janeiro/15` |
  | `acl is_post path_beg -i /posts` | Compare if the starting path is `/posts` |
  | `acl is_post_subdir path_dir -i /posts` | Compare if it is a subdirectory of path with `/something/posts/january` |
  | `acl is_image path_end -i .jpg .png` | Compare if the path ends with `/blabla.jpg` |
  | `acl is_4_digit path_len 4` | If the number of digits in the path is equal to 4 |
  | `acl is_gt_4 path_len gt 4` | If the number of difits in the path is greater than 4 |
  | `acl is_image_regex pathreg (png|jpg|jpeg|gif)$` | Just using RegEx |
  | `acl is_substring path_sub -i posts` | If contains a string as `posts` |

- PARAMETER
  | Line | Explanation |
  | ---- | ----------- |
  | `acl is_region_rj url_param(region) -i -m str rio rj` | Compare if the Region parameter exists with value "rio" |

- HEADER
  | Line | Explanation |
  | ---- | ----------- |
  | `acl is_header_region_rj req.hdr(Region) -i -m str rio rj` | Compare if the Region header exists with value "rio" |
  | `acl is_my_old_domain req.hdr(Host) -i -m str old.domain.net` | Compare if the request with Host header is equals "old.domain.net" |

---

### Control-Cache

If the application doesn't have a shared **Session management** using Redis or MemCached for example, we end up being dependent on the session **Stickiness** feature.

#### Cookies

With **Cookies** it's possible to keep the client session for a backend for a while (until the session lasts).

##### Usage Example:

```ini
defaults
  option redispatch

...
backend back-nginxes
  cookie BACKENDUSED insert indirect nocache
  option httpchk HEAD /
  server nginx1 172.10.10.101:80 check cookie nginx1
  server nginx2 172.10.10.102:80 check cookie nginx2
  server nginx3 172.10.10.103:80 check cookie nginx3

```

#### Stick Tables

**Sticky Session** works great in L7 load balancing, however if you want to assign a client on a server using L4 load balancing, you will need to use another feature as there is no cookie.

A great feature is the use of **Stick Tables**. With this it is possible to create a key-value data table. Based on this table, we can make decisions.

##### Usage Example:
```ini
...
backend back-nginxes
  option httpchk HEAD /
  server nginx1 172.10.10.101:80 check
  server nginx2 172.10.10.102:80 check
  server nginx3 172.10.10.103:80 check
  stick-table type ip size 1m expire 30m
  stick match src
  stick store-request src

```

### HTTPS (TLS)

You can use the [**CertBot (by Lets Encrypt)**](https://certbot.eff.org/instructions?ws=haproxy&os=ubuntufocal) and follow the steps given by them.

> Note: Change the Operation System according what you are using.

#### Usage Example

```ini
...
frontend front-nginxes
  bind *:80
  bind *:443 ssl crt /etc/haproxy/certs/nginx.pem
  option forwardfor
  default_backend back-nginxes
```

Other configurations:

- To ensure requests are HTTPS, use:
  ```ini
  ...
    redirect scheme https if !{ ssl_fc }
  ```
- To restrict the use of TLS versions **(ssl-min-ver / ssl-max-ver)**, use:
  ```ini
  ...
  frontend front-nginxes
    bind *:443 ssl crt /etc/ssl/certs/nginx.pem ssl-min-ver TLSv1.1 ssl-max-ver TLSv1.3
    default_backend back-nginxes
  ```
- To force the use of specific TLS version (TLS1.2), use:
  ```ini
  ...
  frontend front-nginxes
    bind *:443 ssl crt /etc/ssl/certs/nginx.pem force-tlsv12
    default_backend back-nginxes
  ```
- Global SSL rules (all backends):
  ```ini
  global
    ssl-default-bind-options ssl-min-ver TLSv1.1 ssl-max-ver TLSv1.3
  ```

---

# Troubleshooting & Tip Sessions

1. If you are not using Apple M1/M2, you need to change to another AMD64 BOX for example.
   1. You can use [Vagrant Cloud](https://app.vagrantup.com/boxes/search) to search the boxes according to your provider (vmware, virtualbox, etc).
1. DHCP:
   1. To release the current IP address: `dhclient -r`
   1. To obtain a fresh lease: `dhclient`
1. Testing the SSL connections:
   ```shell
   openssl s_client -tls1_1 -connect <ip>:<port> -debug -msg
   ```
