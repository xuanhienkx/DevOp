## sử dụng terraform để clone và apply ứng dụng
https://developer.hashicorp.com/terraform/downloads
cài trên ubuntu

```shell
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
---

## điền thông tin kết nối trên file credentials.tf và variable.tf

## kiểm tra lại thông tin file redmine.sh thay đổi dbname, username, password db


Thực thi chương trình
---shell
terraform init
terraform apply -auto-approve
---