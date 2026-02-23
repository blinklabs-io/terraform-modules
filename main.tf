resource "grafana_folder" "this" {
  title = var.grafana_title
}

resource "grafana_dashboard" "this" {
  for_each = {
    for filename in fileset("${path.root}/${var.local_directory}", "*.json") :
    filename => length(var.datasource_uids) > 0 ? jsondecode(templatefile("${path.root}/${var.local_directory}/${filename}", {
      datasource_uid_map = var.datasource_uids
    })) : jsondecode(file("${path.root}/${var.local_directory}/${filename}"))
  }

  config_json = jsonencode(each.value)
  folder      = grafana_folder.this.uid
}
