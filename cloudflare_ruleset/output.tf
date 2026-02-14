output "id" {
  description = "The ID of the created ruleset"
  value       = try(one(cloudflare_ruleset.account[*].id), one(cloudflare_ruleset.zone[*].id), null)
}

output "name" {
  description = "The name of the ruleset"
  value       = try(one(cloudflare_ruleset.account[*].name), one(cloudflare_ruleset.zone[*].name), null)
}

output "kind" {
  description = "The kind of the ruleset"
  value       = try(one(cloudflare_ruleset.account[*].kind), one(cloudflare_ruleset.zone[*].kind), null)
}

output "phase" {
  description = "The phase of the ruleset"
  value       = try(one(cloudflare_ruleset.account[*].phase), one(cloudflare_ruleset.zone[*].phase), null)
}
