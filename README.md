# RMAP Terraform Deployment

## Goal

The goal with this project is to duplicate the existing RMAP Production infrastructure using Terraform.  This will allow us to deploy RMAP in a quicker, more repeatable fashion.

### Required Components

**Instance specific**
* rmap app server

* rmap graphdb server
* rmap kafka servers (x1 for demo/dev, x3 for prod)
* rmap solr server
* rmap loader server
* rmap aws rds mariadb for app server
* rmap aws rds postgresql for loader

**Shared**
* vpc
* jumpoff server