# 🚀 Project 3 - Azure App Service Blue-Green Deployment using Terraform

## 📖 Overview

This project demonstrates how to provision and deploy an Azure App Service using **Terraform** while implementing modern **Blue-Green Deployment** practices with **GitHub Actions**.

The objective of this project was to learn how Azure App Service works in a real-world deployment scenario by provisioning the infrastructure as code, integrating CI/CD, creating deployment slots, testing traffic routing, and performing zero-downtime deployments.
---

## 📌 Project Status

| Feature | Status |
|---------|--------|
| Terraform Infrastructure | ✅ Completed |
| Azure App Service | ✅ Completed |
| GitHub Actions CI/CD | ✅ Completed |
| Deployment Slots | ✅ Completed |
| Blue-Green Deployment | ✅ Completed |
| Canary Deployment | ✅ Completed |
| Slot Swap | ✅ Completed |
| Rollback | ✅ Completed |
| Health Checks | ⏳ Planned |
| Autoscaling | ⏳ Planned |
| Application Insights | ⏳ Planned |
| Managed Identity | ⏳ Planned |
---

# 🛠 Technologies Used

* Terraform
* Microsoft Azure
* Azure App Service
* Azure App Service Plan
* Azure Deployment Slots
* Git
* GitHub
* GitHub Actions
* Node.js
* Azure Remote Backend (Storage Account)

---

# 📁 Project Structure

```
proj3-azure-appservice-blue-green-terraform/

│
├── terraform/
│   ├── backend.tf
│   ├── provider.tf
│   ├── resourceGroup.tf
│   ├── appservice.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── README.md
```

The application source code is maintained in a separate GitHub repository (Microsoft Node.js Web App Sample fork).

---

# 🏗 Infrastructure Provisioned

Terraform provisions the following Azure resources:

* Resource Group
* App Service Plan (Linux)
* Linux Web App
* Deployment Slot (Staging)
* GitHub Source Control Integration (Production)

---

# ⚙ CI/CD Pipeline

GitHub Actions is used for Continuous Integration and Continuous Deployment.

Workflow:

```
Developer
      │
      ▼
Git Push
      │
      ▼
GitHub Actions
      │
      ▼
Build Node.js Application
      │
      ▼
Deploy to Azure App Service
```

Application deployments are automatically triggered whenever code is pushed to GitHub.

---

# 🌿 Blue-Green Deployment

Deployment slots were used to achieve zero-downtime deployments.

```
Production Slot

Staging Slot
```

The staging slot was used for testing new application versions before promoting them to production.

---

# 🔀 Deployment Slot Swap

After validating the application in the staging slot, Azure's Slot Swap feature was used.

```
Production
      ⇅
Staging
```

Benefits:

* No downtime
* No application restart
* Instant promotion
* Easy rollback

---

# 🚦 Traffic Routing (Canary Deployment)

Azure App Service Traffic Routing was used to gradually expose users to the new deployment.

Examples tested:

* 10% → Staging
* 90% → Production

This demonstrates how Azure supports Canary deployments before performing a complete swap.

---

# 🔄 Rollback Strategy

Rollback was performed using another Slot Swap operation.

Instead of redeploying the application:

```
Production
      ⇅
Staging
```

Rollback was completed within seconds.

---

# 📌 Challenges Faced

## 1. Azure Subscription Quota

The Azure Free subscription initially had no VM quota available in East US.

Resolution:

* Switched deployment region to Central India.

---

## 2. App Service Plan SKU Limitations

The Free (F1) plan does not support:

* Deployment Slots
* Always On

Resolution:

* Upgraded the App Service Plan to Standard (S1).

---

## 3. Azure Resource Group Visibility

Terraform reported that the Resource Group already existed, while the Azure Portal did not display it.

Azure CLI confirmed the Resource Group existed.

Resolution:

* Deleted the orphaned Resource Group using Azure CLI.
* Re-provisioned the infrastructure using Terraform.

---

## 4. Terraform Provider Limitation

Terraform currently does not support configuring Azure App Service Source Control for Deployment Slots.

Attempting to use:

```
azurerm_app_service_source_control
```

with

```
azurerm_linux_web_app_slot.id
```

resulted in provider parsing errors.

Resolution:

* Managed Production source control with Terraform.
* Managed Staging deployment through GitHub Actions and Azure Portal.
* Future deployments will rely entirely on GitHub Actions.

---

## 5. Incorrect Build Provider

Initial deployments failed because Azure attempted to build the application using PHP instead of Node.js.

Resolution:

* Changed Build Provider to GitHub Actions.
* Configured Node.js Runtime Stack.

---

## 6. Browser Cache During Traffic Routing

Traffic routing appeared inconsistent during testing.

Root Cause:

* Browser cache and ARR Affinity cookies.

Resolution:

* Tested using multiple browsers/incognito sessions.

---

# 📚 Key Learnings

Through this project I learnt:

* Azure App Service Architecture
* App Service Plans
* Linux Web Apps
* Deployment Slots
* Blue-Green Deployment
* Canary Deployment
* Slot Swapping
* Rollback Strategy
* GitHub Actions CI/CD
* Azure Deployment Center
* Remote Terraform Backend
* Infrastructure as Code using Terraform

---

# 🚀 Future Improvements

* Configure Staging deployment completely through GitHub Actions
* Custom Domains
* Managed Identity integration
* Azure Key Vault integration
* Application Insights
* Autoscaling Rules
* Health Checks
* Diagnostic Logging

---

# 🎯 Conclusion

This project demonstrates a production-style Azure App Service deployment using Terraform and GitHub Actions while implementing Blue-Green deployment and rollback strategies.

The project provides practical experience with Infrastructure as Code, CI/CD pipelines, deployment slots, traffic routing, and zero-downtime application deployments.
