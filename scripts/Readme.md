## get-secrets.js
retrieve secret from Key Vault for use in terraform deployments

To use in terraform:
```
data "external" "secrets" {
	program = [ "node", "get-secrets.js" ]

	query = {
		username 		= "${var.username_secret}"
		password 		= "${var.password_secret}"
	}
}

output "username" {
    value = {data.external.secrets.result.username
}
```

## Set-TerraformEnv.ps1
Powershell script to set environment variables used by terraform for authentication and remote state.