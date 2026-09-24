# terraform-google-cloud-storage-bucket

### Build
Please use the below commands to run terraform.

```
terraform init --input=false
terraform plan
terraform apply
```

### Clean Up
To destroy the resources that you have created please use the below command.

```
terraform destroy
```

### Provider Dependencies
Providers are Terraform plugins that will be automatically installed during `terraform init` if available on the Terraform registry.
```
Terraform version >= 0.13
google(hashicorp/google) >= 4.1.0
```


### Module Dependencies
Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.

This module has no external module dependencies.

### Prerequisites
#### IAM Permissions
Please ensure the below IAM permissions are in place to create this GCS bucket.

```
roles/storage.admin
```
#### API Enablement
A project with the following APIs enabled must be used to host the resources of this module:

```
storage-api.googleapis.com
```

### Inputs

|   Name	|  Description 	|   Type	|  Default 	|   Required	|
|---	    |---	        |---	    |---	    |---	    |
| name	|  The name of the new bucket that will be created. Please do note that it will have to be unique "". | string | ""	| yes |
| force_destroy | option to delete all objects in a bucket while deleting a bucket | bool | false | no |
| location | the location of the bucket | string | NA | yes |
| project_id | the ID of the project where the bucket will be created | string | NA | yes |
| storage_class | the Storage Class of the new bucket | string | null | no |
| labels | a map of key/value label pairs to assign to the bucket | map(string) | null | no |
| uniform_bucket_level_access | enables uniform bucket level access to a bucket | bool | true | no |
| lifecycle_rule | lifecycle rule for a gcs bucket | list(object(any)) | NA | no |
| bucket_object_versioning | enabling versioning can help retain a noncurrent object version | bool | true | no | 
| cors | cors configuration for the bucket | any | [] | no |
| retention_policy | configuration of the bucket's data retention policy for how long objects in the bucket should be retained | object({ is_locked = bool retention_period = number }) | null | no |
| log_object_bucket | a gcs bucket that can receive log objects | string | null | no |
| log_object_prefix | the object prefix for log objects which defaults to gcs bucket name | string | null | no |
| encryption | a cloud KMS key that will be used to encrypt objects inserted into this bucket | object({kms_key_name=string}) | null | no |

### Outputs
