mock_provider "google" {
  mock_resource "google_iam_workload_identity_pool" {
    defaults = { name = "projects/123/locations/global/workloadIdentityPools/external" }
  }
  mock_resource "google_iam_workload_identity_pool_provider" {
    defaults = { name = "projects/123/locations/global/workloadIdentityPools/external/providers/example-oidc" }
  }
  mock_resource "google_service_account" {
    defaults = { name = "projects/p/serviceAccounts/deployer@p.iam.gserviceaccount.com", email = "deployer@p.iam.gserviceaccount.com" }
  }
}

variables {
  project          = "p"
  service_accounts = [{ account_id = "deployer" }]
  workload_identity_pools = [{
    pool_id = "external"
    providers = [{
      provider_id         = "example-oidc"
      issuer_uri          = "https://oidc.example.com"
      attribute_mapping   = { "google.subject" = "assertion.sub", "attribute.team" = "assertion.team" }
      attribute_condition = "assertion.team == \"platform\""
    }]
  }]
  workload_identity_pool_bindings = [
    { service_account_id = "deployer", pool_id = "external", attribute = "subject", value = "deploy:production" },
    { service_account_id = "deployer", pool_id = "external", attribute = "attribute.team", value = "platform" },
    { service_account_id = "deployer", pool_id = "external", attribute = "group", value = "admins" },
  ]
}

run "members" {
  command = apply
  assert {
    condition     = google_service_account_iam_member.workload_identity_pool["p::deployer::external::subject::deploy:production"].member == "principal://iam.googleapis.com/projects/123/locations/global/workloadIdentityPools/external/subject/deploy:production"
    error_message = "subject member wrong"
  }
  assert {
    condition     = google_service_account_iam_member.workload_identity_pool["p::deployer::external::attribute.team::platform"].member == "principalSet://iam.googleapis.com/projects/123/locations/global/workloadIdentityPools/external/attribute.team/platform"
    error_message = "attribute principalSet member wrong"
  }
  assert {
    condition     = google_service_account_iam_member.workload_identity_pool["p::deployer::external::group::admins"].member == "principalSet://iam.googleapis.com/projects/123/locations/global/workloadIdentityPools/external/group/admins"
    error_message = "group principalSet member wrong"
  }
  assert {
    condition     = output.workload_identity_pool_providers["p::external::example-oidc"].name == "projects/123/locations/global/workloadIdentityPools/external/providers/example-oidc"
    error_message = "provider output wrong"
  }
}

run "blank_condition_rejected" {
  command = plan
  variables {
    workload_identity_pools         = [{ pool_id = "x", providers = [{ provider_id = "y", issuer_uri = "https://i", attribute_mapping = { "google.subject" = "assertion.sub" }, attribute_condition = " " }] }]
    workload_identity_pool_bindings = []
  }
  expect_failures = [var.workload_identity_pools]
}

run "null_condition_rejected" {
  command = plan
  variables {
    workload_identity_pools         = [{ pool_id = "x", providers = [{ provider_id = "y", issuer_uri = "https://i", attribute_mapping = { "google.subject" = "assertion.sub" }, attribute_condition = null }] }]
    workload_identity_pool_bindings = []
  }
  expect_failures = [var.workload_identity_pools]
}

run "empty_attribute_name_rejected" {
  command = plan
  variables {
    workload_identity_pool_bindings = [{ service_account_id = "deployer", pool_id = "external", attribute = "attribute.", value = "v" }]
  }
  expect_failures = [var.workload_identity_pool_bindings]
}

run "uppercase_attribute_name_rejected" {
  command = plan
  variables {
    workload_identity_pool_bindings = [{ service_account_id = "deployer", pool_id = "external", attribute = "attribute.Team", value = "v" }]
  }
  expect_failures = [var.workload_identity_pool_bindings]
}

run "null_attribute_rejected" {
  command = plan
  variables {
    workload_identity_pool_bindings = [{ service_account_id = "deployer", pool_id = "external", attribute = null, value = "v" }]
  }
  expect_failures = [var.workload_identity_pool_bindings]
}
