# Azure App Service Blue-Green Deployment with Terraform, GitHub Actions & OIDC

A Terraform-managed Azure App Service deployment demonstrating **Infrastructure as Code, GitHub Actions CI/CD, Microsoft Entra ID workload identity federation (OIDC), RBAC, staging slots, health checks, autoscaling, and branch-based deployments**.

The project deploys a Node.js application to Azure App Service using separate identities for staging and production.

---

## Architecture

```text
                         GitHub Repository
                    nodejs-docs-hello-world
                              |
                 +------------+------------+
                 |                         |
            staging branch             main branch
                 |                         |
                 v                         v
        GitHub Actions              GitHub Actions
                 |                         |
            OIDC Token                OIDC Token
                 |                         |
                 v                         v
       Staging App Registration   Production App Registration
                 |                         |
       Staging Service Principal  Production Service Principal
                 |                         |
        Federated Credential       Federated Credential
                 |                         |
        Website Contributor        Website Contributor
                 |                         |
                 v                         v
        Azure App Service         Azure App Service
             /staging              /production
                 |                         |
                 v                         v
          Staging URL              Production URL
```

The production and staging environments use **separate Microsoft Entra identities**.

This provides isolation between the two deployment paths.

---

# Project Goals

The main goals of this project are:

* Deploy a Node.js application to Azure App Service.
* Manage Azure infrastructure using Terraform.
* Create a Linux App Service Plan.
* Create an Azure Linux Web App.
* Create a staging deployment slot.
* Configure autoscaling.
* Configure application health checks.
* Configure separate staging and production identities.
* Implement GitHub Actions authentication using OIDC.
* Avoid storing Azure client secrets in GitHub.
* Use federated credentials instead of long-lived credentials.
* Configure Azure RBAC for GitHub deployment identities.
* Deploy staging from the `staging` branch.
* Deploy production from the `main` branch.
* Build Node.js dependencies during Azure deployment.
* Maintain infrastructure and identity configuration as code.

---

# Technologies Used

| Technology                        | Purpose                             |
| --------------------------------- | ----------------------------------- |
| Azure App Service                 | Application hosting                 |
| Azure App Service Plan            | Compute infrastructure              |
| Azure App Service Deployment Slot | Staging environment                 |
| Terraform                         | Infrastructure as Code              |
| AzureRM Provider                  | Azure resource management           |
| AzureAD Provider                  | Microsoft Entra identity management |
| GitHub Actions                    | CI/CD                               |
| GitHub OIDC                       | Passwordless Azure authentication   |
| Microsoft Entra ID                | Application identities              |
| Azure RBAC                        | Authorization                       |
| Node.js                           | Application runtime                 |
| Express.js                        | Web application framework           |
| Oryx                              | Azure build/deployment system       |

---

# Repository Structure

Example structure:

```text
proj3-azure-appservice-blue-green-terraform/
│
├── terraform/
│   ├── provider.tf
│   ├── backend.tf
│   ├── variables.tf
│   ├── resource_group.tf
│   ├── app_service_plan.tf
│   ├── autoscale.tf
│   ├── webapp.tf
│   ├── staging_slot.tf
│   ├── prod_identity.tf
│   ├── staging_identity.tf
│   └── RBAC.tf
│
└── README.md
```

The application itself is maintained in the Node.js application repository.

---

# Azure Infrastructure

## Resource Group

Terraform creates the resource group:

```text
rg-appservice-lab
```

Region:

```text
Central India
```

---

# App Service Plan

Terraform creates a Linux App Service Plan:

```text
asp-appservice-lab
```

Configuration:

```text
OS       : Linux
SKU      : S1
```

The App Service Plan provides the compute infrastructure used by the production web application and its staging slot.

---

# Web App

The main Azure Web App is:

```text
ivan-appservice-lab
```

The application uses:

```text
Linux
Node.js 24 LTS
HTTPS only
Always On
```

Health check endpoint:

```text
/health
```

The health check allows Azure App Service to determine whether an application instance is healthy.

---

# Staging Slot

A deployment slot is created using Terraform:

```text
staging
```

The resulting resource is conceptually:

```text
ivan-appservice-lab/staging
```

The staging slot uses the same underlying App Service Plan but provides an isolated deployment environment.

Staging is configured with:

```text
Always On : false
Health Check : /health
Node.js : 24 LTS
```

Always On is disabled for staging to reduce unnecessary resource consumption in this lab environment.

---

# Production vs Staging

The application infrastructure is shared, but deployment identities are separated.

| Property             | Staging             | Production              |
| -------------------- | ------------------- | ----------------------- |
| Git branch           | `staging`           | `main`                  |
| Azure target         | `/staging` slot     | Default production slot |
| App Registration     | Staging identity    | Production identity     |
| Service Principal    | Staging SP          | Production SP           |
| Federated Credential | Staging subject     | Production subject      |
| RBAC                 | Website Contributor | Website Contributor     |
| Always On            | Disabled            | Enabled                 |

---

# Autoscaling

Autoscaling is configured for the App Service Plan using:

```text
azurerm_monitor_autoscale_setting
```

Capacity:

```text
Minimum : 1
Default : 1
Maximum : 3
```

## Scale Out

When average CPU usage is greater than:

```text
70%
```

the plan increases the instance count by:

```text
1
```

The rule evaluates CPU over a five-minute window.

---

## Scale In

When average CPU usage falls below:

```text
30%
```

the plan decreases the instance count by:

```text
1
```

This prevents unnecessary compute consumption during low-load periods.

---

# Terraform Remote State

Terraform state is stored remotely in Azure Storage.

Backend:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg01-backend"
    storage_account_name = "rg01st01backend"
    container_name       = "tfstate"
    key                  = "infra.tfstate3"
  }
}
```

Using a remote backend provides:

* Centralized state storage
* State locking
* Collaboration support
* Reduced risk of losing local state

Terraform automatically acquires a state lock during operations such as:

```bash
terraform plan
terraform apply
terraform destroy
```

---

# Terraform Providers

The project uses:

```text
azurerm
azuread
```

The AzureRM provider manages Azure infrastructure.

The AzureAD provider manages Microsoft Entra resources such as:

* App Registrations
* Service Principals
* Federated Identity Credentials

---

# Identity Architecture

One of the key objectives of this project is to avoid storing Azure client secrets in GitHub.

Instead, GitHub Actions uses **OpenID Connect (OIDC)**.

There are two independent identities.

## Staging Identity

```text
nodejs-appservice-staging
```

## Production Identity

```text
nodejs-appservice-prod
```

Each identity has:

```text
App Registration
        |
        v
Service Principal
        |
        v
Federated Identity Credential
        |
        v
Azure RBAC
```

---

# GitHub OIDC Authentication

GitHub Actions can issue a short-lived signed OIDC JWT for a workflow.

The workflow requests an identity token using:

```yaml
permissions:
  id-token: write
  contents: read
```

GitHub generates a JWT containing claims such as:

```text
issuer
subject
audience
job_workflow_ref
```

Example issuer:

```text
https://token.actions.githubusercontent.com
```

Example audience:

```text
api://AzureADTokenExchange
```

The subject identifies the GitHub repository and branch.

---

# Federated Identity Credential

The federated identity credential is created on the Microsoft Entra App Registration.

It defines which GitHub-issued identity token Azure should trust.

For example, the staging credential uses a subject representing:

```text
repo:ivan-saji@283069219/nodejs-docs-hello-world@1324792684:ref:refs/heads/staging
```

The production credential uses:

```text
repo:ivan-saji@283069219/nodejs-docs-hello-world@1324792684:ref:refs/heads/main
```

The important difference is the branch.

Therefore:

```text
staging branch
      ↓
staging federated credential
```

while:

```text
main branch
      ↓
production federated credential
```

---

# How OIDC Authentication Works

The authentication flow is:

```text
1. Developer pushes code
          |
          v
2. GitHub Actions starts
          |
          v
3. GitHub issues a signed OIDC JWT
          |
          v
4. azure/login receives the token
          |
          v
5. Azure Entra ID validates:
       - issuer
       - subject
       - audience
       - federated credential
          |
          v
6. Azure identifies the Service Principal
          |
          v
7. Azure RBAC determines what it can access
          |
          v
8. Azure CLI becomes authenticated
```

No client secret is stored in GitHub.

---

# Authentication vs Authorization

A major concept demonstrated by this project is the difference between authentication and authorization.

## Authentication

OIDC answers:

> "Who is trying to connect?"

The federated credential establishes trust between GitHub and Microsoft Entra ID.

---

## Authorization

RBAC answers:

> "What is this identity allowed to do?"

The Service Principal is assigned:

```text
Website Contributor
```

at the appropriate Azure scope.

Therefore:

```text
OIDC
 ↓
Authentication
 ↓
Service Principal
 ↓
RBAC
 ↓
Authorization
```

Both are required.

---

# Azure RBAC

The GitHub deployment identities are assigned:

```text
Website Contributor
```

This allows the deployment identity to perform the required App Service deployment operations without giving it unnecessary broad permissions such as Owner.

The identities are kept separate:

```text
Production SP
    ↓
Website Contributor
    ↓
Production App Service

Staging SP
    ↓
Website Contributor
    ↓
Staging App Service Slot
```

---

# GitHub Actions

The application repository contains a workflow:

```text
.github/workflows/hello.yml
```

The workflow performs:

```text
Checkout
   ↓
Azure OIDC Login
   ↓
Verify Azure Access
   ↓
Setup Node.js
   ↓
Install Dependencies
   ↓
Lint
   ↓
Create Artifact
   ↓
Download Artifact
   ↓
Deploy to App Service
```

---

# Staging Deployment

The staging deployment is triggered from:

```text
staging
```

The workflow uses the staging Service Principal's client ID.

The deployment target is:

```yaml
app-name: ivan-appservice-lab
slot-name: staging
```

Therefore:

```text
GitHub staging
      ↓
Staging OIDC identity
      ↓
Staging RBAC
      ↓
ivan-appservice-lab/staging
```

---

# Production Deployment

The production deployment is triggered from:

```text
main
```

The workflow uses the production Service Principal's client ID.

The production deployment does not specify a slot:

```yaml
app-name: ivan-appservice-lab
```

Therefore, Azure deploys to the default production slot.

Flow:

```text
GitHub main
      ↓
Production OIDC identity
      ↓
Production RBAC
      ↓
ivan-appservice-lab
```

---

# Application Build During Deployment

One important configuration is:

```hcl
app_settings = {
  SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
}
```

This tells Azure App Service to perform a build during deployment.

The important reason for this is Node.js dependencies.

The repository contains:

```text
package.json
```

with dependencies such as:

```text
express
body-parser
cors
```

The deployment artifact does not need to contain `node_modules`.

Azure's build system, using Oryx, can read `package.json` and install the required dependencies.

Conceptually:

```text
Deployment artifact
        |
        v
Azure App Service
        |
        v
SCM_DO_BUILD_DURING_DEPLOYMENT=true
        |
        v
Oryx build
        |
        v
package.json
        |
        v
npm install
        |
        v
node_modules
        |
        v
npm start
        |
        v
Node.js application
```

---

# Why This Setting Was Required

During troubleshooting, the application initially failed with:

```text
Error: Cannot find module 'express'
```

The container was successfully created, but the application could not start because its runtime dependency was missing.

The startup sequence was effectively:

```text
npm start
   ↓
node index.js
   ↓
require("express")
   ↓
express not found
   ↓
exit code 1
   ↓
ContainerStartupFailure
   ↓
503
```

Enabling:

```text
SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

allowed Azure to build the application and install its dependencies before starting it.

---

# Health Checks

The application exposes:

```text
/health
```

Azure App Service is configured to monitor this endpoint.

Terraform configuration:

```hcl
health_check_path = "/health"
health_check_eviction_time_in_min = 5
```

The health check helps Azure identify unhealthy application instances.

This is particularly useful when autoscaling or running multiple instances.

---

# Deployment Verification

After a deployment, the workflow verifies Azure access using:

```bash
az account show
```

and:

```bash
az webapp show \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab
```

This provides an early indication that:

1. OIDC authentication succeeded.
2. The correct Azure subscription is selected.
3. The Service Principal has sufficient RBAC permissions.
4. The App Service exists.

---

# Troubleshooting Lessons

## 1. `AADSTS700016`

Example:

```text
Application with identifier '...' was not found in the directory
```

Possible causes:

* Wrong client ID
* Deleted App Registration
* Wrong tenant ID
* Production identity accidentally used for staging
* Staging identity accidentally used for production

The client ID in:

```yaml
azure/login@v2
```

must correspond to the intended App Registration / Service Principal.

---

# 2. Resource Not Found for Slot

Example:

```text
Resource .../slots/staging was not found
```

The important distinction is between:

```text
slot resource name
```

and:

```text
slot name
```

The slot was ultimately created as:

```text
staging
```

so CLI commands use:

```bash
--slot staging
```

The full resource ID contains the parent web app and slot.

---

# 3. AuthorizationFailed

Example:

```text
does not have authorization to perform action
Microsoft.Web/sites/read
```

This means authentication succeeded, but authorization failed.

In other words:

```text
OIDC login       ✅
Service Principal identified  ✅
RBAC permission  ❌
```

The solution is to verify the role assignment:

```bash
az role assignment list \
  --assignee <OBJECT-ID> \
  --all \
  -o table
```

---

# 4. `express` Module Not Found

Example:

```text
Error: Cannot find module 'express'
```

This indicates that the application reached the Node.js startup stage but its runtime dependency was not available.

The solution was to ensure Azure performs the application build during deployment:

```text
SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

---

# 5. ContainerStartupFailure

A generic error such as:

```text
Container exited with exit code 1
```

does not necessarily mean Azure infrastructure is broken.

The container logs must be inspected.

Useful commands include:

```bash
az webapp log tail \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab \
  --slot staging
```

For production:

```bash
az webapp log tail \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab
```

The most useful information is usually immediately before:

```text
Container exited with exit code 1
```

---

# Useful Azure CLI Commands

## List deployment slots

```bash
az webapp deployment slot list \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab \
  -o table
```

---

## Show production Web App

```bash
az webapp show \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab \
  -o table
```

---

## Show staging Web App

```bash
az webapp show \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab \
  --slot staging \
  -o table
```

---

## List App Service settings

Production:

```bash
az webapp config appsettings list \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab
```

Staging:

```bash
az webapp config appsettings list \
  --name ivan-appservice-lab \
  --resource-group rg-appservice-lab \
  --slot staging
```

---

## View RBAC assignments

```bash
az role assignment list \
  --assignee <SERVICE-PRINCIPAL-OBJECT-ID> \
  --all \
  -o table
```

---

## View federated credentials

```bash
az ad app federated-credential list \
  --id <APPLICATION-ID> \
  -o table
```

---

# Terraform Workflow

Initialize Terraform:

```bash
terraform init
```

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Review:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Destroy lab infrastructure:

```bash
terraform destroy
```

---

# Infrastructure Lifecycle

The intended lifecycle is:

```text
Terraform
   |
   +--> Resource Group
   |
   +--> App Service Plan
   |
   +--> Autoscaling
   |
   +--> Production Web App
   |
   +--> Staging Slot
   |
   +--> Production App Registration
   |
   +--> Production Service Principal
   |
   +--> Production Federated Credential
   |
   +--> Staging App Registration
   |
   +--> Staging Service Principal
   |
   +--> Staging Federated Credential
   |
   +--> RBAC Assignments
```

This allows the environment to be recreated using Terraform rather than relying on manually created Azure resources.

---

# Security Design

This project intentionally avoids long-lived Azure credentials in GitHub Actions.

Instead of:

```text
GitHub
   ↓
Client ID + Client Secret
   ↓
Azure
```

the project uses:

```text
GitHub
   ↓
Short-lived OIDC JWT
   ↓
Microsoft Entra ID
   ↓
Federated Credential validation
   ↓
Service Principal
   ↓
RBAC
   ↓
Azure
```

Advantages include:

* No client secret stored in GitHub.
* No long-lived password/token required.
* Short-lived GitHub-issued identity tokens.
* Branch-level trust.
* Separate identities for production and staging.
* Reduced credential-management overhead.

---

# Branch Strategy

The application repository uses:

```text
main
staging
```

Deployment mapping:

```text
staging branch
      ↓
staging environment

main branch
      ↓
production environment
```

The staging environment acts as the validation environment before changes are merged into production.

---

# Current Deployment Flow

## Development

```text
Developer
   ↓
Modify Node.js application
   ↓
Commit
   ↓
Push staging
```

## Staging

```text
staging
   ↓
GitHub Actions
   ↓
OIDC
   ↓
Staging Service Principal
   ↓
RBAC
   ↓
Azure App Service staging slot
   ↓
Health check
   ↓
Staging validation
```

## Production

After staging validation:

```text
staging
   ↓
Merge into main
   ↓
GitHub Actions
   ↓
OIDC
   ↓
Production Service Principal
   ↓
RBAC
   ↓
Azure App Service production slot
   ↓
Health check
   ↓
Production
```

---

# Blue-Green Deployment Concept

This project uses Azure App Service deployment slots to demonstrate the fundamentals of a blue-green deployment strategy.

Conceptually:

```text
                 App Service
                     |
          +----------+----------+
          |                     |
      Production             Staging
       (Blue)                (Green)
          |                     |
       Users               New Version
```

A new application version can be deployed to staging without immediately replacing the production version.

After validation, the staging environment can be promoted to production using an App Service slot swap strategy if required.

The current implementation primarily demonstrates **isolated staging and production deployments**. Slot swapping can be added as a future enhancement.

---

# Future Improvements

Planned improvements include:

* [ ] Add automated production deployment approval.
* [ ] Add environment protection rules in GitHub.
* [ ] Add automated testing before deployment.
* [ ] Add slot swap for true blue-green promotion.
* [ ] Add deployment rollback strategy.
* [ ] Add Application Insights monitoring.
* [ ] Add alerts for unhealthy instances.
* [ ] Improve Terraform module structure.
* [ ] Move environment-specific configuration into Terraform variables.
* [ ] Improve secret/variable management.
* [ ] Automate OIDC identity bootstrap.
* [ ] Automate complete infrastructure creation with a single Terraform workflow.
* [ ] Add Terraform CI validation.
* [ ] Add `terraform fmt`, `validate`, and `plan` to CI.
* [ ] Add deployment status reporting.
* [ ] Add production approval gates.
* [ ] Add automated smoke tests against `/health`.
* [ ] Document disaster recovery and rollback procedures.

---

# Key Concepts Learned

This project was built to understand the complete relationship between:

```text
Infrastructure
     ↓
Identity
     ↓
Authentication
     ↓
Authorization
     ↓
CI/CD
     ↓
Application Deployment
     ↓
Application Health
```

Important concepts covered:

### Infrastructure as Code

Terraform manages Azure resources declaratively.

### Microsoft Entra ID

App Registrations and Service Principals provide workload identities.

### OIDC

GitHub Actions authenticates to Azure without storing long-lived secrets.

### Federated Identity

Azure trusts a specific GitHub token issuer and subject.

### RBAC

Azure determines what the authenticated identity is allowed to do.

### App Service Slots

Staging can run independently from production.

### Oryx

Azure can build the Node.js application and install dependencies during deployment.

### Health Checks

Azure can monitor application health and identify unhealthy instances.

### Autoscaling

Azure can dynamically increase or decrease App Service instances based on CPU utilization.

---

# Interview Explanation

A concise explanation of the project:

> I built a Terraform-managed Azure App Service deployment with separate staging and production environments. GitHub Actions uses OIDC workload identity federation with Microsoft Entra ID instead of client secrets. I created separate App Registrations and Service Principals for staging and production, configured branch-specific federated credentials, and assigned Website Contributor RBAC permissions. The staging branch deploys to an App Service staging slot, while the main branch deploys to production. Azure App Service performs the Node.js build during deployment using Oryx, installs application dependencies, performs health checks, and uses autoscaling based on CPU utilization.

---

# Lessons From Troubleshooting

The project deliberately involved real deployment failures and debugging.

Major failures included:

```text
ResourceNotFound
```

→ Investigated App Service slot naming and resource hierarchy.

```text
AADSTS700016
```

→ Investigated Microsoft Entra application/client IDs and tenant configuration.

```text
AuthorizationFailed
```

→ Investigated Azure RBAC and Service Principal permissions.

```text
Cannot find module 'express'
```

→ Investigated Node.js dependency installation and Azure Oryx build behavior.

```text
ContainerStartupFailure
```

→ Investigated App Service container startup logs and application startup failures.

These troubleshooting exercises were important for understanding how the individual components interact instead of treating GitHub Actions, Terraform, OIDC, and Azure App Service as isolated technologies.

---

# Project Outcome

The final system successfully supports:

```text
                 GitHub
                    |
          +---------+---------+
          |                   |
       staging               main
          |                   |
       OIDC                 OIDC
          |                   |
     Staging SP          Production SP
          |                   |
      RBAC                  RBAC
          |                   |
          v                   v
     App Service          App Service
       /staging            /production
          |                   |
          v                   v
       HEALTHY              HEALTHY
```

Both staging and production deployments are successfully automated through GitHub Actions.

Infrastructure and identity resources are managed through Terraform.

No long-lived Azure client secret is required for GitHub Actions authentication.

---

# Author

**Ivan Saji**

Project built as part of hands-on Azure Cloud / DevOps learning.

Focus areas:

* Azure
* Terraform
* Linux
* CI/CD
* GitHub Actions
* Microsoft Entra ID
* OIDC
* RBAC
* Infrastructure as Code
* Cloud automation
* Application deployment
