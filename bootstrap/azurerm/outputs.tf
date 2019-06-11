output "bucket_name" {
  value = "${azurerm_storage_container.container.id}"
}
