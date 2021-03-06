## Aws Account

* ACCOUNT-NAME (ACCOUNT-ID) <!-- infinum-dev (7021-9251-8610) -->

## Server

### General

* type: **EC2** <!-- EC2 / ECS / Baremetal -->
* hostname: **HOSTNAME** <!-- rovinj -->
* size: **EC2-SIZE** <!-- t3.large -->
* ip: **SERVER-IP** <!-- 127.0.0.1 -->
* domain: **SERVER-DOMAIN** <!-- cekila.byinfinum.co -->
* application dependencies
  * none
  <!-- * vips (v. 8.7.3) -->
* monitoring
  * sensu
  * node_exporter
    * systemd name: **node_exporter.service**
    * port: **9100**
  * process_exporter
    * systemd name: **process_exporter.service**
    * port: **9256**
  * promtail
    * systemd name: **promtail.service**
  * prometheus_exporter
    * systemd name: **prometheus_exporter-APP-staging.service** <!-- prometheus_exporter-cekila-staging.service -->
    * port: **9394**

### Application
* domain: **APP-DOMAIN** <!-- cekila.byinfinum.co -->
* user: **DEPLOY-USER** <!-- cekila_deploy -->
* ruby version: **RUBY VERSION** <!-- 2.7.1 -->
* node version: **NODE VERSION** <!-- 14.0.1 -->
* redis:
  * url: **redis://URL OR unix:/SOCKET** <!-- unix:/var/run/redis/redis-cekila.sock -->
  * type: local <!-- local / AWS ElasticCache -->
* sidekiq
  * systemd name: **sidekiq-APP-staging.service** <!-- sidekiq-cekila-staging.service -->
* ssh access
  * semaphore
  <!-- * stjepan.hadjic@infinum.hr -->

## Database

* type: **RDS**
* database: **Postgresql**
* name: **DB-NAME** <!-- cekila-staging -->
* url: **DB-URL** <!-- cekila.abcdefghij.eu-west-1.rds.amazonaws.com -->
* version: **DB-VERSION** <!-- 12.0 -->
* extensions:
  * plpgsql
* Maintance and Backups:
  * Auto minor version upgrade: enabled
  * maintenance window: wed:03:33-wed:04:03 UTC (GMT)
  * Automated backups: Enabled (7 Days)

## AWS

### Buckets

* BUCKET-NAME<span id="s3-APP-staging"></span> <!-- cekila-staging<span id="s3-cekila-staging"></span> -->
  * private
  * lifecycles:
    * prefix: "cache"; expire after 2 days; delete after 1 day;
    * <details>
      <summary> CORS </summary>

      ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
        <CORSRule>
            <AllowedOrigin>*</AllowedOrigin>
            <AllowedMethod>GET</AllowedMethod>
            <AllowedMethod>POST</AllowedMethod>
            <AllowedMethod>PUT</AllowedMethod>
            <MaxAgeSeconds>3000</MaxAgeSeconds>
            <ExposeHeader>ETag</ExposeHeader>
            <AllowedHeader>content-type</AllowedHeader>
            <AllowedHeader>x-amz-date</AllowedHeader>
            <AllowedHeader>x-amz-content-sha256</AllowedHeader>
        </CORSRule>
        </CORSConfiguration>
      ```
    </details>

### CDN

* CDN-DOMAIN -> [BUCKET-NAME](#s3-APP-staging) (S3 bucket) <!-- fewfwegwfe.cloudfront.net -> [cekila-staging](#s3-cekila-staging) (S3 bucket) -->
