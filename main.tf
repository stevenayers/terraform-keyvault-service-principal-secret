data "azurerm_key_vault_secret" "azkvpoc-app" {
  name      = "${var.secret_name}"
  vault_uri = "https://${var.vault_name}.vault.azure.net/"
}

# Hacky way of turning the decoded json into a terraform map?
data "external" "app-sp-json" {
  program = [
    "echo",
    "${base64decode(data.azurerm_key_vault_secret.azkvpoc-app.value)}"
  ]
}

output "app-sp" {
  value = "${data.external.app-sp-json.result}"
}