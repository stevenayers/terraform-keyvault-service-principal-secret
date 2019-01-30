# Azure Key Vault PoC

This Terraform attempts to pull out service principal credentials from Azure Key Vault and
output the values.

Authentication for Terraform is done via Service Principal and Client Secret.

1. Terraform Authenticates using initial Service Principal (azkvpoc-sp).
2. Data source retrieves credentials for app Service Principal (azkvpoc-app-sp) from Azure Key Vault.
3. Data Source provides outputs compatible to be passed in to other modules and fields.
    ```
    [azkvpoc outputs]
    app-sp = {
        client_id = 00000000-0000-0000-0000-000000000000
        client_secret = 00000000-0000-0000-0000-000000000000
        object_id = 00000000-0000-0000-0000-000000000000
    }
    ```
    ```hcl-terraform
    module "foo" {
       source = "../modules/foo"
       client_id = "${module.azkvpoc.client_id}"
       client_secret = "${module.azkvpoc.client_secret}"
       object_id = "${module.azkvpoc.object_id}"  
    }
 
    module "azkvpoc" {
       ...
    }
    ```
    
### Setup
For this to work, the initial and app Service Principals have been manually created inside the
Azure Portal, along with an Azure Key Vault for the app Service Principal credentials to sit in.

The initial service principal requires read access to the key vault, but the app Service
Principal doesn't require any access to be granted (we're not doing anything with it here apart
from printing it out to the screen).

The content of this key vault secret looks something like this once base64 decoded:
```json
{
  "client_id": "00000000-0000-0000-0000-000000000000",
  "object_id": "00000000-0000-0000-0000-000000000000",
  "client_secret": "00000000-0000-0000-0000-000000000000"      
}
```

To add the app Service Principal credentials to the key vault (ensure your azure user has write access to the key vault):
```bash
APP_SP_JSON='<STRING OF JSON>'
az keyvault secret set \
    --vault-name "azkvpoc-vault" \
    --name "azkvpoc-app-creds" \
    --value "$(echo ${APP_SP_JSON} | base64)"
```


### Runbook
1. Export azkvpoc-sp values to environment variables. If you do not have a client secret already, go
   into the Service Principal settings in the Azure portal and create a new 'password' under keys 
   ([docs](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html)).
   ```bash
    export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
    export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
    export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
    export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```
2. Run `terraform apply`

3. You should see:
   ```
   Outputs:
   
   app-sp = {
     client_id = 00000000-0000-0000-0000-000000000000
     client_secret = 00000000-0000-0000-0000-000000000000
     object_id = 00000000-0000-0000-0000-000000000000
   }
   ```