resource "google_storage_bucket" "storage_bucket" {

  name          = var.name
  force_destroy = var.force_destroy
  location      = var.location
  project       = var.project
  storage_class = var.storage_class
  lifecycle_rule {
    action {
      type          = var.lra_type # lifecycle_rule_action
      storage_class = var.lra_storage_class
    }
    condition {
      age                    = var.lrc_age   #lifecycle_rule_condation
      created_before         = var.lrc_created_before
      with_state             = var.lrc_with_state
      matches_storage_class  = var.lrc_matches_storage_class
      num_newer_versions     = var.lrc_num_newer_versions
      custom_time_before     = var.lrc_custom_time_before
      days_since_custom_time = var.lrc_days_since_custom_time
      noncurrent_time_before = var.lrc_noncurrent_time_before

    }

  }
  versioning {
    enabled = var.versioning_enabled
  }
  website {
    main_page_suffix = var.website_main_page_suffix
    not_found_page   = var.website_not_found_page

  }
  # cors {
  #   origin          = var.cors_origin
  #   method          = var.cors_method
  #   response_header = var.cors_response_header
  #   max_age_seconds = var.cors_max_age_seconds
  # }
  retention_policy {
    is_locked        = var.retention_policy_is_locked
    retention_period = var.retention_policy_retention_period
  }
  # labels = var.labels
  # logging {
  #   log_bucket        = var.logging_log_bucket
  #   log_object_prefix = var.logging_log_object_prefix
  # }
  # encryption {
  #   default_kms_key_name = var.encryption_default_kms_key_name
  # }
  requester_pays              = var.requester_pays
  uniform_bucket_level_access = var.uniform_bucket_level_access


}