# Docker-Forge 
**A Curated Catalog of Containerized Services**

**Docker-Forge** is a centralized repository for high-availability Docker Compose configurations. It serves as the primary service catalog for the **Meralus Systems Group (MSG)** internal lab, focusing on rapid deployment, persistent storage management, and container security.

---

## Service Inventory
The forge is organized by application stack:

*   **`/atlassian-suite`**: Jira, Confluence, and Bitbucket orchestration.
*   **`/monitoring`**: Grafana and Nagios observability stacks.
*   **`/security`**: Wazuh-dev and Snipe-IT for asset and threat management.
*   **`/infrastructure`**: Foreman and OS Ticket for life-cycle and support.
*   **`/gaming`**: Dedicated ARK server configurations.

---

## 🚀 Deployment Standard
Each service directory follows a standardized structure:
1. `docker-compose.yml`: Optimized for resource limits and logging.
2. `.env.example`: Template for environment variables (secrets excluded).
3. `config/`: Persistent volume mount points.

