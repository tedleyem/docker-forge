# Docker Monitoring Stack

A streamlined observability suite using Prometheus, Grafana, and cAdvisor to monitor local Docker containers and host performance. This project also uses Influxdb as an alternative source with other dashboards pulled from [public dashboards](https://grafana.com/grafana/dashboards/)

 **Note:** password are saved in plain text for development purposes. 
 
### Project Structure
```
.
├── docker-compose.yml
├── grafana
│   ├── dashboards
│   │   ├── applications
│   │   └── infrastructure
│   ├── prometheus
│   │   ├── docker-compose.yml
│   │   ├── grafana
│   │   └── prometheus
│   └── provisioning
│       ├── dashboards
│       └── datasources
├── prometheus.yml
└── README.md
 ```

##### Launch the Stack

From the root directory, run:
```Bash

docker-compose up -d
```
##### Access the Tools

    Grafana: http://grafana:3000 (Default Login: admin / admin)

    Prometheus: http://prometheus:9090

    InfluxDB: http://influxdb:8086

    cAdvisor: http://cAdvisor:8080


##### Configuration Details
Monitoring Logic

    cAdvisor analyzes resource usage (CPU, Memory, Network, Disk) of all running containers on the host.

    Prometheus scrapes these metrics every 15 seconds.

    Grafana automatically connects to Prometheus via the provisioned datasource and loads the dashboards found in ./grafana/dashboards.


##### Adding New Dashboards

To add a new dashboard:

    Export your dashboard as a JSON file from the Grafana UI.

    Place the file into ./grafana/dashboards/.

    Restart the stack or run docker-compose restart grafana.