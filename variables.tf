variable "data_sources" {
  type = map(object({
    type = string
    name = string
    url  = string
    pdc  = optional(string)
  }))
  description = "Map of data sources with type, name, URL, and optional PDC (Private Data Source Connect) network ID."

  validation {
    condition     = length(var.data_sources) == length(distinct([for ds in var.data_sources : ds.name]))
    error_message = "Each data source must have a unique name."
  }
}
