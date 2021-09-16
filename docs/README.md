# Technical Documentation

<!-- Main themes -->
### [Architecture](architecture.md)
### [Development workflow](development_workflow.md)

<!-- mostly helpers and stimulus controllers -->
## Components
<!-- ### [Dropdown](components/dropdown.md) -->

## API Documentation

The documentation URL: https://APP-DOMAIN/api/v1/docs/

## Deployment
[Semaphore](https://semaphoreci.com/APP-REPO-NAME)

### Builds
Our continuous integration tool will automatically build the environment upon each push to whatever branch.
The build installs all dependencies and runs all the specs.

### Deploying
The `staging` branch is used for the staging environment and `master` for production.
Whenever a branch or pull request is merged to one of those environments, after the build is finished Semaphore will try to deploy it to the environment.
