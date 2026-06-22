# Docker-Forge
**A Curated Catalog of Containerized Services**

Docker-Forge is a centralized repository for high-availability Docker Compose configurations and custom base images. It serves as the primary service catalog for the Meralus Systems Group (MSG) internal infrastructure, focusing on rapid deployment, persistent storage management, and container security.

---

## Repository Structure

* `compose/` - Multi-container orchestration stacks (Atlassian Suite, Monitoring, Security, Infrastructure, Gaming).
* `images/` - Custom Dockerfiles utilized across the environment.
* `scripts/` - Automation and helper scripts for deployment and maintenance.
* `hadolint.yaml` - Global linting configuration for Dockerfile compliance rules.

---

## CI/CD Automation

This repository utilizes GitHub Actions to automate code quality and container builds via a matrix workflow:

* **Linting:** Automatically scans custom Dockerfiles using Hadolint to catch syntax validation issues.
* **Build & Push:** Automatically builds verified images and pushes them to the container registry upon successful validation.