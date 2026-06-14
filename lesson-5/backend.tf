# Налаштування бекенду: стейти зберігаються в S3, блокування — через DynamoDB.
#
# УВАГА (bootstrap): S3-бакет та таблиця DynamoDB мають існувати ДО `terraform init`
# з цим бекендом. Тому першого разу:
#   1) тимчасово закоментуйте цей блок (локальний бекенд за замовчуванням);
#   2) `terraform init && terraform apply` — створить бакет і таблицю;
#   3) розкоментуйте блок і виконайте `terraform init -migrate-state`.
#
# Значення bucket/dynamodb_table мають збігатися з модулем s3_backend у main.tf.
terraform {
  backend "s3" {
    bucket         = "yuriiavr-tf-state-lesson-5"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
