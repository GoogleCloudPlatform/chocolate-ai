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
variable "project_id" {}
variable "multi_region" {}
variable "vertex_ai_region" {}
variable "bigquery_chocolate_ai_dataset" {}
variable "chocolate_ai_bucket" {}
variable "chocolate_ai_code_bucket" {}
variable "dataform_region" {}
variable "random_extension" {}
variable "gcp_account_name" {}
variable "dataflow_staging_bucket" {}
variable "dataflow_service_account" {}


# Define the list of notebook files to be created
locals {
  chocolate_ai_notebooks = [ 
    for s in fileset("../colab-enterprise/", "*.ipynb") : trimsuffix(s, ".ipynb")
  ]  

  notebook_names = local.chocolate_ai_notebooks # concat(local.TTTT, local.chocolate_ai_notebooks)
}


# Setup Dataform repositories to host notebooks
# Create the Dataform repos.  This will create all the repos across all directories
resource "google_dataform_repository" "notebook_repo" {
  count        = length(local.notebook_names)
  provider     = google-beta
  project      = var.project_id
  region       = var.dataform_region
  name         = local.notebook_names[count.index]
  display_name = local.notebook_names[count.index]
  labels = {
    "single-file-asset-type" = "notebook"
  }
}


# Template Substitution - You need one of these blocks per Notebook Directory
resource "local_file" "local_file_chocolate_ai_notebooks" {
  count    = length(local.chocolate_ai_notebooks)
  filename = "../terraform-modules/colab-deployment-create-files/notebooks/${local.chocolate_ai_notebooks[count.index]}.ipynb" 
  content = templatefile("../colab-enterprise/${local.chocolate_ai_notebooks[count.index]}.ipynb",
   {
    project_id = var.project_id
    bigquery_location = var.multi_region
    region = var.vertex_ai_region
    location = var.vertex_ai_region
    chocolate_ai_bucket = var.chocolate_ai_bucket
    bigquery_chocolate_ai_dataset = var.bigquery_chocolate_ai_dataset
    chocolate_ai_bucket = var.chocolate_ai_bucket
    chocolate_ai_code_bucket = var.chocolate_ai_code_bucket
    dataflow_staging_bucket = var.dataflow_staging_bucket
    dataflow_service_account = var.dataflow_service_account
    }
  )
}


# Deploy notebooks -  You need one of these blocks per Notebook Directory
# https://cloud.google.com/dataform/reference/rest/v1beta1/projects.locations.repositories/commit#WriteFile
#json='{
#  "commitMetadata": {
#    "author": {
#      "name": "Google Data Bean",
#      "emailAddress": "no-reply@google.com"
#    },
#    "commitMessage": "Committing Chocolate A.I. notebook"
#  },
#  "fileOperations": {
#      "content.ipynb": {
#         "writeFile": {
#           "contents" : "..."
#       }
#    }
#  }
#}'

# Write out the curl command content 
# If you do this within a docker/cloud build you can run into issues with the command output display being too long
resource "local_file" "local_file_chocolate_ai_notebooks_base64" {
  count    = length(local.chocolate_ai_notebooks)
  filename = "../terraform-modules/colab-deployment-create-files/notebooks_base64/${local.chocolate_ai_notebooks[count.index]}.base64" 
  content = "{\"commitMetadata\": {\"author\": {\"name\": \"Google Data Bean\",\"emailAddress\": \"no-reply@google.com\"},\"commitMessage\": \"Committing Chocolate A.I. notebook\"},\"fileOperations\": {\"content.ipynb\": {\"writeFile\": {\"contents\" : \"${base64encode(local_file.local_file_chocolate_ai_notebooks[count.index].content)}\"}}}}"
}
