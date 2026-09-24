##### Terraform Resource Block To Create a GCS Bucket #####

resource "random_string" "bucket_suffix" {
  length      = 3
  special     = false
  upper       = false
  numeric      = true
  min_lower   = 1
  min_numeric = 1
}

### kms key auto fetching BLOCK newly added

data "google_project" "current" {
  project_id = var.project_id
}

data "google_kms_key_ring" "project_keyring" {
  project  = var.project_id
  name     = var.project_id
  location = var.location
}

data "google_kms_crypto_key" "project_key" {
  name     = "${data.google_project.current.name}-key"
  key_ring = data.google_kms_key_ring.project_keyring.id
}
### kms key auto fetching BLOCK newly added

resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service_identity" "gcs_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "storage.googleapis.com"

  depends_on = [google_project_service.storage]
}

resource "time_sleep" "wait_for_gcs_sa" {
  create_duration = "60s"

  depends_on = [google_project_service_identity.gcs_sa]
}

resource "google_kms_crypto_key_iam_member" "gcs_cmek" {
  crypto_key_id = data.google_kms_crypto_key.project_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.service_project4.number}@gs-project-accounts.iam.gserviceaccount.com"

  depends_on = [time_sleep.wait_for_gcs_sa]

  lifecycle {
    ignore_changes = [member]
  }
}

resource "google_storage_bucket" "bucket" {
  count                       = var.no_of_buckets
  name                        = "${var.name_of_buckets[count.index]}-${random_string.bucket_suffix.result}"
  force_destroy               = var.force_destroy
  location                    = var.location
  project                     = var.project_id
  storage_class               = var.storage_class
  labels                      = var.labels
  uniform_bucket_level_access = var.uniform_bucket_level_access

  lifecycle {
    ignore_changes = [
      labels
    ]
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }

      condition {
        age                        = lookup(lifecycle_rule.value.condition, "age", null)
        created_before             = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state                 = lookup(lifecycle_rule.value.condition, "with_state", lookup(lifecycle_rule.value.condition, "is_live", false) ? "LIVE" : null)
        matches_storage_class      = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions         = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        custom_time_before         = lookup(lifecycle_rule.value.condition, "custom_time_before", null)
        days_since_custom_time     = lookup(lifecycle_rule.value.condition, "days_since_custom_time", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value.condition, "days_since_noncurrent_time", null)
        noncurrent_time_before     = lookup(lifecycle_rule.value.condition, "noncurrent_time_before", null)
      }
    }
  }

  versioning {
    enabled = var.bucket_object_versioning
  }

  dynamic "cors" {
    for_each = var.cors == null ? [] : var.cors
    content {
      origin          = lookup(cors.value, "origin", null)
      method          = lookup(cors.value, "method", null)
      response_header = lookup(cors.value, "response_header", null)
      max_age_seconds = lookup(cors.value, "max_age_seconds", null)
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy == null ? [] : [var.retention_policy]
    content {
      is_locked        = var.retention_policy.is_locked
      retention_period = var.retention_policy.retention_period
    }
  }

  dynamic "logging" {
    for_each = var.log_object_bucket == null ? [] : [var.log_object_bucket]
    content {
      log_bucket        = var.log_object_bucket
      log_object_prefix = var.log_object_prefix
    }
  }
dynamic "encryption" {
  for_each = [1]

  content {
    default_kms_key_name = data.google_kms_crypto_key.project_key.id
  }
}

  depends_on = [
    google_kms_crypto_key_iam_member.gcs_cmek
  ]
}

data "google_project" "service_project4" {
  project_id = var.project_id
}
