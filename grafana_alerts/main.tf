locals {
  parsed_files = {
    for filename in fileset("${path.root}/${var.local_directory}", "*.json") :
    filename => jsondecode(templatefile("${path.root}/${var.local_directory}/${filename}", {
      datasource_uid_map = var.datasource_uids
    }))
  }

  rule_groups = merge([
    for filename, parsed in local.parsed_files : {
      for idx, group in try(parsed["groups"], []) :
      "${filename}:${idx}:${group["name"]}" => group
    }
  ]...)
}

resource "grafana_folder" "this" {
  title = var.grafana_title
}

resource "grafana_rule_group" "this" {
  for_each = local.rule_groups

  name             = each.value["name"]
  folder_uid       = grafana_folder.this.uid
  interval_seconds = try(each.value["interval"], var.default_interval_seconds)

  dynamic "rule" {
    for_each = try(each.value["rules"], [])

    content {
      name      = rule.value["title"]
      condition = rule.value["condition"]
      for       = try(rule.value["for"], "0s")
      dynamic "data" {
        for_each = try(rule.value["data"], [])
        content {
          ref_id         = data.value["refId"]
          datasource_uid = data.value["datasourceUid"]
          model          = jsonencode(data.value["model"])
          relative_time_range {
            from = try(data.value["relativeTimeRange"]["from"], 0)
            to   = try(data.value["relativeTimeRange"]["to"], 0)
          }
        }
      }
      no_data_state  = try(rule.value["noDataState"], "NoData")
      exec_err_state = try(rule.value["execErrState"], "Error")
      annotations    = try(rule.value["annotations"], {})
      labels         = try(rule.value["labels"], {})
      dynamic "notification_settings" {
        for_each = try(rule.value["notification_settings"], null) != null ? [rule.value["notification_settings"]] : []
        content {
          contact_point   = notification_settings.value["receiver"]
          group_by        = try(notification_settings.value["group_by"], null)
          group_interval  = try(notification_settings.value["group_interval"], null)
          group_wait      = try(notification_settings.value["group_wait"], null)
          repeat_interval = try(notification_settings.value["repeat_interval"], null)
          mute_timings    = try(notification_settings.value["mute_timings"], null)
        }
      }
    }
  }
}
