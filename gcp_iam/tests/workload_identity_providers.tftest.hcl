mock_provider "google" {}

run "oidc_provider" {
  command = plan

  variables {
    project = "example-project"
    workload_identity_pools = [{
      pool_id = "external"
      providers = [{
        provider_id       = "example-oidc"
        issuer_uri        = "https://oidc.example.com"
        allowed_audiences = ["example-audience"]
        attribute_mapping = {
          "google.subject" = "assertion.sub"
        }
        attribute_condition = "assertion.sub.startsWith('deploy:')"
      }]
    }]
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.this["example-project::external::example-oidc"].oidc[0].issuer_uri == "https://oidc.example.com"
    error_message = "OIDC providers must retain their issuer configuration."
  }

  assert {
    condition     = length(google_iam_workload_identity_pool_provider.this["example-project::external::example-oidc"].aws) == 0
    error_message = "OIDC providers must not render an AWS provider block."
  }
}

run "aws_provider" {
  command = plan

  variables {
    project = "example-project"
    workload_identity_pools = [{
      pool_id = "external"
      providers = [{
        provider_id    = "example-aws"
        aws_account_id = "123456789012"
        attribute_mapping = {
          "google.subject"     = "assertion.arn"
          "attribute.aws_role" = "assertion.arn.extract('assumed-role/{role}/')"
        }
        attribute_condition = "assertion.account == '123456789012'"
      }]
    }]
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.this["example-project::external::example-aws"].aws[0].account_id == "123456789012"
    error_message = "AWS providers must render the configured account ID."
  }

  assert {
    condition     = length(google_iam_workload_identity_pool_provider.this["example-project::external::example-aws"].oidc) == 0
    error_message = "AWS providers must not render an OIDC provider block."
  }
}

run "provider_requires_one_type" {
  command = plan

  variables {
    project = "example-project"
    workload_identity_pools = [{
      pool_id = "external"
      providers = [{
        provider_id         = "invalid"
        issuer_uri          = "https://oidc.example.com"
        aws_account_id      = "123456789012"
        attribute_mapping   = { "google.subject" = "assertion.sub" }
        attribute_condition = "assertion.sub != ''"
      }]
    }]
  }

  expect_failures = [var.workload_identity_pools]
}

run "provider_requires_a_type" {
  command = plan

  variables {
    project = "example-project"
    workload_identity_pools = [{
      pool_id = "external"
      providers = [{
        provider_id         = "invalid"
        attribute_mapping   = { "google.subject" = "assertion.sub" }
        attribute_condition = "assertion.sub != ''"
      }]
    }]
  }

  expect_failures = [var.workload_identity_pools]
}

run "provider_requires_attribute_condition" {
  command = plan

  variables {
    project = "example-project"
    workload_identity_pools = [{
      pool_id = "external"
      providers = [{
        provider_id         = "invalid"
        aws_account_id      = "123456789012"
        attribute_mapping   = { "google.subject" = "assertion.arn" }
        attribute_condition = ""
      }]
    }]
  }

  expect_failures = [var.workload_identity_pools]
}
