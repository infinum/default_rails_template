# Prerequisites
Before you start working on the project, you need to get access to project-related items.

Project manager can give you access to:
* project in the project management software (productive, jira, etc) **LINK-TO-PROJECT** <!-- https://app.productive.io/path-to-project --> <!-- DEVELOPER -->
* project Slack channels **LINK-TO-SLACK-CHANNELS** <!-- https://infinum.slack.com/path-to-project --> <!-- DEVELOPER -->
* project Google Drive **LINK-TO-GOOGLE-DRIVE** <!-- https://drive.google.com//path-to-project --> <!-- DEVELOPER -->
* project design (Figma, Sketch, etc) **LINK-TO-DESIGN** <!-- https://www.figma.com/path-to-project --> <!-- DEVELOPER -->
* 1password vault - **VAULT-NAME** <!-- DEVELOPER -->

<!-- if project has a project specific email such as accounts.{client}@infinum.com or support.{client}@infinum.com -->
Project manager will ask Google Workspace account manager to add you to the email group.

Devops can give you access to:
* git repository - **LINK-TO-GIT-REPO** <!-- https://github.com/path-to-project --> <!-- DEVELOPER -->
* development and staging secrets - **LINK-TO-GIT-REPO** <!-- https://github.com/path-to-project --> <!-- DEVELOPER -->
* bugsnag project - **LINK-TO-BUGSNAG** <!-- https://bugsnag.com/path-to-project --> <!-- DEVELOPER -->
* semaphore project - **LINK-TO-SEMAPHORE** <!-- https://semaphoreci.com/path-to-project --> <!-- DEVELOPER -->
* staging and/or UAT server
<!-- any other project specific services that are required for development -->

# Type of tasks:
* Documentation
* Hotfixes (needs to be on production asap)
* Change of existing feature
* Bugfix
* Security updates
* Refactors
* New features

# Workflow

<!-- With Staging and UAT -->
![Workflow](https://lucid.app/publicSegments/view/41abf00b-4ffa-40ed-9082-32ae8f5ddfde/image.png)

```
Legend:

[] -> Developer action
() -> prerequisite
<> -> push to branch

* [confirm] -> confirm that the code is fine, update the Productive task with a proof [screenshoot, request/response, console queries, ...]
** -> <master> -- this needs to be in one of the defined deploy slots
```

```
Documentation / just Rubocop
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm] -> <uat> -> [confirm] -> <master> -> [confirm]

Hotfixes / Security updates
[WriteCode] -> [Open PullRequest] -> <staging> -> [confirm] -> <uat> -> [confirm] -> (QA approved)(PR approved)[unless :fire:] -> <master> -> [confirm](QA approved)

Change of existing feature / Bugfix / Refactors
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm] -> (QA approved) -> <uat> -> [confirm](Qa approved) -> <master> -> [confirm](QA approved)

New features
Architecture
<master> -> <architecture branch>
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm] -> <uat> -> [confirm] -> <master>

Frontend / API
<architecture branch> -> <dashboard branch>
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm] -> <uat> -> [confirm](Qa approved) -> <master> -> [confirm](QA approved)
```

<!-- With Staging -->
![Workflow](https://lucid.app/publicSegments/view/99e8ab13-078f-41d8-b73d-9f7c4d7f26c9/image.png)

```
Legend:

[] -> Developer action
() -> prerequisite
<> -> push to branch

* [confirm] -> confirm that the code is fine, update the Productive task with a proof [screenshoot, request/response, console queries, ...]
** -> <master> -- this needs to be in one of the defined deploy slots
```

```
Documentation / just Rubocop
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm] -> <master> -> [confirm]

Hotfixes / Security updates
[WriteCode] -> [Open PullRequest] -> <staging> -> [confirm] -> (QA approved)(PR approved)[unless :fire:] -> <master> -> [confirm](QA approved)

Change of existing feature / Bugfix / Refactors
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm] -> (QA approved) -> <uat> -> [confirm](Qa approved) -> <master> -> [confirm](QA approved)

New features
Architecture
<master> -> <architecture branch>
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm] -> <master>

Frontend / API
<architecture branch> -> <dashboard branch>
[WriteCode] -> [Open PullRequest] -> (PR approved) -> <staging> -> [confirm](Qa approved) -> <master> -> [confirm](QA approved)
```

