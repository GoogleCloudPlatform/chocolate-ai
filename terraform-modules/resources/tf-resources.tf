####################################################################################
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
####################################################################################

####################################################################################
# Create the GCP resources
#
# Author: Adam Paternostro
####################################################################################


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "5.35.0"
    }
  }
}


####################################################################################
# Variables
####################################################################################
variable "gcp_account_name" {}
variable "project_id" {}

variable "dataplex_region" {}
variable "multi_region" {}
variable "bigquery_non_multi_region" {}
variable "vertex_ai_region" {}
variable "data_catalog_region" {}
variable "appengine_region" {}
variable "colab_enterprise_region" {}
variable "dataflow_region" {}
variable "kafka_region" {}

variable "random_extension" {}
variable "project_number" {}
variable "deployment_service_account_name" {}
variable "terraform_service_account" {}

variable "bigquery_chocolate_ai_dataset" {}
variable "chocolate_ai_bucket" {}
variable "chocolate_ai_code_bucket" {}
variable "dataflow_staging_bucket" {}

####################################################################################
# Bucket for all data (BigQuery, Spark, etc...)
# This is your "Data Lake" bucket
# If you are using Dataplex you should create a bucket per data lake zone (bronze, silver, gold, etc.)
####################################################################################
resource "google_storage_bucket" "google_storage_bucket_chocolate_ai_bucket" {
  project                     = var.project_id
  name                        = var.chocolate_ai_bucket
  location                    = var.multi_region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "google_storage_bucket_chocolate_ai_code_bucket" {
  project                     = var.project_id
  name                        = var.chocolate_ai_code_bucket
  location                    = var.multi_region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "google_storage_bucket_dataflow_staging" {
  project                     = var.project_id
  name                        = var.dataflow_staging_bucket
  location                    = var.multi_region
  force_destroy               = true
  uniform_bucket_level_access = true
  soft_delete_policy {
    retention_duration_seconds = 0
  }
}

####################################################################################
# Default Network
# The project was not created with the default network.  
# This creates just the network/subnets we need.
####################################################################################
resource "google_compute_network" "default_network" {
  project                 = var.project_id
  name                    = "vpc-main"
  description             = "Default network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "colab_enterprise_subnet" {
  project                  = var.project_id
  name                     = "colab-enterprise-subnet"
  ip_cidr_range            = "10.1.0.0/16"
  region                   = var.colab_enterprise_region
  network                  = google_compute_network.default_network.id
  private_ip_google_access = true

  depends_on = [
    google_compute_network.default_network
  ]
}


resource "google_compute_subnetwork" "dataflow_subnet" {
  project                  = var.project_id
  name                     = "dataflow-subnet"
  ip_cidr_range            = "10.2.0.0/16"
  region                   = var.dataflow_region
  network                  = google_compute_network.default_network.id
  private_ip_google_access = true

  depends_on = [
    google_compute_network.default_network,
    google_compute_subnetwork.colab_enterprise_subnet
  ]
}

resource "google_compute_subnetwork" "kafka_subnet" {
  project                  = var.project_id
  name                     = "kafka-subnet"
  ip_cidr_range            = "10.3.0.0/16"
  region                   = var.kafka_region
  network                  = google_compute_network.default_network.id
  private_ip_google_access = true

  depends_on = [
    google_compute_network.default_network,
    google_compute_subnetwork.colab_enterprise_subnet,
    google_compute_subnetwork.kafka_subnet
  ]
}

# Firewall for NAT Router
resource "google_compute_firewall" "subnet_firewall_rule" {
  project = var.project_id
  name    = "subnet-nat-firewall"
  network = google_compute_network.default_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }
  source_ranges = ["10.1.0.0/16","10.2.0.0/16","10.3.0.0/16"]

  depends_on = [
    google_compute_subnetwork.colab_enterprise_subnet,
    google_compute_subnetwork.dataflow_subnet,
    google_compute_subnetwork.kafka_subnet
  ]
}

# We want a NAT for every region
locals {
  distinctRegions = distinct([var.colab_enterprise_region, var.dataflow_region, var.kafka_region])
}

resource "google_compute_router" "nat-router-distinct-regions" {
  project = var.project_id
  count   = length(local.distinctRegions)
  name    = "nat-router-${local.distinctRegions[count.index]}"
  region  = local.distinctRegions[count.index]
  network = google_compute_network.default_network.id

  depends_on = [
    google_compute_firewall.subnet_firewall_rule
  ]
}

resource "google_compute_router_nat" "nat-config-distinct-regions" {
  project                            = var.project_id
  count                              = length(local.distinctRegions)
  name                               = "nat-config-${local.distinctRegions[count.index]}"
  router                             = google_compute_router.nat-router-distinct-regions[count.index].name
  region                             = local.distinctRegions[count.index]
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [
    google_compute_router.nat-router-distinct-regions
  ]
}

####################################################################################
# BigQuery Datasets
####################################################################################
resource "google_bigquery_dataset" "google_bigquery_dataset_chocolate_ai" {
  project       = var.project_id
  dataset_id    = var.bigquery_chocolate_ai_dataset
  friendly_name = var.bigquery_chocolate_ai_dataset
  description   = "This dataset contains the data for the Chocolate A.I. demo."
  location      = var.multi_region
}


####################################################################################
# IAM for cloud build
####################################################################################
# Needed per https://cloud.google.com/build/docs/cloud-build-service-account-updates
resource "google_project_iam_member" "cloudfunction_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

# Needed per https://cloud.google.com/build/docs/cloud-build-service-account-updates
# Allow cloud function service account to read storage [V2 Function]
resource "google_project_iam_member" "cloudfunction_objectViewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"

  depends_on = [
    google_project_iam_member.cloudfunction_builder
  ]
}


####################################################################################
# Dataplex / Data Lineage
####################################################################################
resource "google_project_iam_member" "gcp_roles_datalineage_admin" {
  project = var.project_id
  role    = "roles/datalineage.admin"
  member  = "user:${var.gcp_account_name}"
}


####################################################################################
# BigQuery - Connections (BigLake, Functions, etc)
####################################################################################
# Vertex AI connection
resource "google_bigquery_connection" "vertex_ai_connection" {
  project       = var.project_id
  connection_id = "vertex-ai"
  location      = var.multi_region
  friendly_name = "vertex-ai"
  description   = "vertex-ai"
  cloud_resource {}
}


# Allow Vertex AI connection to Vertex User
resource "google_project_iam_member" "vertex_ai_connection_vertex_user_role" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_bigquery_connection.vertex_ai_connection.cloud_resource[0].service_account_id}"

  depends_on = [
    google_bigquery_connection.vertex_ai_connection
  ]
}

# BigLake connection
resource "google_bigquery_connection" "biglake_connection" {
  project       = var.project_id
  connection_id = "biglake-connection"
  location      = var.multi_region
  friendly_name = "biglake-connection"
  description   = "biglake-connection"
  cloud_resource {}
}

resource "time_sleep" "biglake_connection_time_delay" {
  depends_on      = [google_bigquery_connection.biglake_connection]
  create_duration = "30s"
}

# Allow BigLake to read storage (at project level, you can do each bucket individually)
resource "google_project_iam_member" "bq_connection_iam_object_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_bigquery_connection.biglake_connection.cloud_resource[0].service_account_id}"

  depends_on = [
    time_sleep.biglake_connection_time_delay
  ]
}

####################################################################################
# Colab Enterprise
####################################################################################
# https://cloud.google.com/vertex-ai/docs/reference/rest/v1beta1/projects.locations.notebookRuntimeTemplates
# NOTE: If you want a "when = destroy" example TF please see: 
#       https://github.com/GoogleCloudPlatform/data-analytics-golden-demo/blob/main/cloud-composer/data/terraform/dataplex/terraform.tf#L147
resource "null_resource" "colab_runtime_template" {
  provisioner "local-exec" {
    when    = create
    command = <<EOF
  curl -X POST \
  https://${var.colab_enterprise_region}-aiplatform.googleapis.com/ui/projects/${var.project_id}/locations/${var.colab_enterprise_region}/notebookRuntimeTemplates?notebookRuntimeTemplateId=colab-enterprise-template \
  --header "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=${var.terraform_service_account})" \
  --header "Content-Type: application/json" \
  --data '{
        displayName: "colab-enterprise-template", 
        description: "colab-enterprise-template",
        isDefault: true,
        machineSpec: {
          machineType: "e2-highmem-4"
        },
        networkSpec: {
          enableInternetAccess: false,
          network: "projects/${var.project_id}/global/networks/vpc-main", 
          subnetwork: "projects/${var.project_id}/regions/${var.colab_enterprise_region}/subnetworks/${google_compute_subnetwork.colab_enterprise_subnet.name}"
        },
        shieldedVmConfig: {
          enableSecureBoot: true
        }
  }'
EOF
  }
  depends_on = [
    google_compute_subnetwork.colab_enterprise_subnet
  ]
}

# https://cloud.google.com/vertex-ai/docs/reference/rest/v1beta1/projects.locations.notebookRuntimes
resource "null_resource" "colab_runtime" {
  provisioner "local-exec" {
    when    = create
    command = <<EOF
  curl -X POST \
  https://${var.colab_enterprise_region}-aiplatform.googleapis.com/ui/projects/${var.project_id}/locations/${var.colab_enterprise_region}/notebookRuntimes:assign \
  --header "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=${var.terraform_service_account})" \
  --header "Content-Type: application/json" \
  --data '{
      notebookRuntimeTemplate: "projects/${var.project_number}/locations/${var.colab_enterprise_region}/notebookRuntimeTemplates/colab-enterprise-template",
      notebookRuntime: {
        displayName: "colab-enterprise-runtime", 
        description: "colab-enterprise-runtime",
        runtimeUser: "${var.gcp_account_name}"
      }
}'  
EOF
  }
  depends_on = [
    null_resource.colab_runtime_template
  ]
}


####################################################################################
# New Service Account - For Continuous Queries
####################################################################################
resource "google_service_account" "kafka_continuous_query_service_account" {
  project      = var.project_id
  account_id   = "kafka-continuous-query"
  display_name = "kafka-continuous-query"
}

# Needs access to BigQuery
resource "google_project_iam_member" "kafka_continuous_query_service_account_bigquery_admin" {
  project  = var.project_id
  role     = "roles/bigquery.admin"
  member   = "serviceAccount:${google_service_account.kafka_continuous_query_service_account.email}"

  depends_on = [
    google_service_account.kafka_continuous_query_service_account
  ]
}

# Needs access to Pub/Sub
resource "google_project_iam_member" "kafka_continuous_query_service_account_pubsub_admin" {
  project  = var.project_id
  role     = "roles/pubsub.admin"
  member   = "serviceAccount:${google_service_account.kafka_continuous_query_service_account.email}"

  depends_on = [
    google_project_iam_member.kafka_continuous_query_service_account_bigquery_admin
  ]
}


####################################################################################
# Pub/Sub (Topic and Subscription)
####################################################################################
resource "google_pubsub_topic" "google_pubsub_topic_bq_continuous_query" {
  project  = var.project_id
  name = "bq-continuous-query"
  message_retention_duration = "86400s"
}

resource "google_pubsub_subscription" "google_pubsub_subscription_bq_continuous_query" {
  project  = var.project_id  
  name  = "bq-continuous-query"
  topic = google_pubsub_topic.google_pubsub_topic_bq_continuous_query.id

  message_retention_duration = "86400s"
  retain_acked_messages      = false

  expiration_policy {
    ttl = "86400s"
  }

  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false

  depends_on = [
    google_pubsub_topic.google_pubsub_topic_bq_continuous_query
  ]
}


####################################################################################
# DataFlow Service Account
####################################################################################
# Service account for dataflow cluster
resource "google_service_account" "dataflow_service_account" {
  project      = var.project_id
  account_id   = "dataflow-service-account"
  display_name = "Service Account for Dataflow Environment"
}


# Grant editor (too high) to service account
resource "google_project_iam_member" "dataflow_service_account_editor_role" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"

  depends_on = [
    google_service_account.dataflow_service_account
  ]
}

####################################################################################
# Outputs
####################################################################################
output "dataflow_service_account" {
  value = google_service_account.dataflow_service_account.email
}
