## Aws Account

* ACCOUNT-NAME (ACCOUNT-ID) <!-- infinum-dev (7021-9251-8610) --> <!-- DEVOPS -->

## Server

### General

* type: **EC2** <!-- EC2 / ECS / Baremetal --> <!-- DEVOPS -->
* hostname: **HOSTNAME** <!-- rovinj --> <!-- DEVOPS -->
* size: **EC2-SIZE** <!-- t3.large --> <!-- DEVOPS -->
* ip: **SERVER-IP** <!-- 127.0.0.1 --> <!-- DEVOPS -->
* domain: **SERVER-DOMAIN** <!-- cekila.byinfinum.co --> <!-- DEVOPS -->
* application dependencies <!-- DEVELOPER -->
  * none
  <!-- * vips (v. 8.7.3) -->
* monitoring <!-- DEVOPS -->
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
    * systemd name: **prometheus_exporter-APP-production.service** <!-- prometheus_exporter-cekila-production.service -->
    * port: **9394**

### Application
* domain: **APP-DOMAIN** <!-- cekila.byinfinum.co --> <!-- DEVOPS -->
* user: **DEPLOY-USER** <!-- cekila_deploy --> <!-- DEVOPS -->
* ruby version: **RUBY VERSION** <!-- 2.7.1 --> <!-- DEVELOPER -->
* node version: **NODE VERSION** <!-- 14.0.1 --> <!-- DEVELOPER -->
* redis: <!-- DEVOPS -->
  * url: **redis://URL OR unix:/SOCKET** <!-- unix:/var/run/redis/redis-cekila.sock -->
  * type: local <!-- local / AWS ElasticCache -->
* sidekiq <!-- DEVOPS -->
  * systemd name: **sidekiq-APP-production.service** <!-- sidekiq-cekila-production.service -->
* ssh access <!-- DEVOPS -->
  * semaphore
  <!-- * stjepan.hadjic@infinum.hr -->

## Database

* type: **RDS** <!-- DEVOPS -->
* database: **Postgresql** <!-- DEVOPS -->
* name: **DB-NAME** <!-- cekila-production --> <!-- DEVOPS -->
* url: **DB-URL** <!-- cekila.abcdefghij.eu-west-1.rds.amazonaws.com --> <!-- DEVOPS -->
* version: **DB-VERSION** <!-- 12.0 --> <!-- DEVOPS -->
* extensions: <!-- DEVELOPER -->
  * plpgsql
* Maintance and Backups: <!-- DEVOPS -->
  * Auto minor version upgrade: enabled
  * maintenance window: wed:03:33-wed:04:03 UTC (GMT)
  * Automated backups: Enabled (7 Days)

## AWS

### Buckets

* BUCKET-NAME<span id="s3-APP-prod"></span> <!-- cekila-production<span id="s3-cekila-prod"></span> --> <!-- DEVOPS -->
  * private
  * lifecycles:
    * prefix: "cache"; expire after 2 days; delete after 1 day;
    * <details>
      <summary> CORS </summary>

      ```json
      [
        {
          "AllowedHeaders": [
            "content-type",
            "x-amz-date",
            "x-amz-content-sha256"
          ],
          "AllowedMethods": [ "PUT", "POST", "GET" ],
          "AllowedOrigins": [ "*" ],
          "ExposeHeaders": [ "ETag" ],
          "MaxAgeSeconds": 3000
        }
      ]
      ```
    </details>

### CDN

* CDN-DOMAIN -> [BUCKET-NAME](#s3-APP-prod) (S3 bucket) <!-- fewfwegwfe.cloudfront.net -> [cekila-production](#s3-cekila-prod) (S3 bucket) --> <!-- DEVOPS -->
