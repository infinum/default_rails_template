# Architecture

## Main info

* Framework: Ruby on Rails
* Language: Ruby

<!-- DEVELOPER -->
<!-- if exists
## Diagram

![diagram](https://lucid.app/publicSegments/view/e1a4ca97-cf28-4b3b-8283-6e76a27f0158/image.png)
-->

## Aws Account

* ACCOUNT-NAME (ACCOUNT-ID) <!-- infinum-dev (7021-9251-8610) --> <!-- DEVOPS -->
<!-- * ACCOUNT-NAME (ACCOUNT-ID) [staging] --> <!-- if multiple AWS account add a [tag]-->

## Infrastructure
[terraform config](https://github.com/infinum/terraform-take-care/tree/master/environments/stage) <!-- DEVOPS -->

<!-- DEVOPS -->
<!-- if exists
## Devops wiki
[wiki](https://devops-wiki.infinum.co/books/projects/chapter/APP)
-->

## Application
* ruby version: **RUBY VERSION** <!-- 2.7.1 --> <!-- DEVELOPER -->
* node version: **NODE VERSION** <!-- 14.0.1 --> <!-- DEVELOPER -->
* application dependencies <!-- DEVELOPER -->
  <!-- * vips -->

## Database
* extensions: <!-- DEVELOPER -->
  <!-- * unaccent -->

## 3rd party services

 <!-- DEVELOPER -->
* [Bugsnag](https://app.bugsnag.com/infinum/APP)
  * notifies to **#project-app-alerts**
* [Semaphore](https://semaphoreci.com/infinum/APP)
  * notifies to **#project-app-alerts**
* [Mailgun](https://mailgun.com)
  * staging account: **mailgun.staging@infinum.hr**
  * production account: **mailgun.APP@infinum.com**
