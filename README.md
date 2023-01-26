# Brokenman Infrastructure

### Requirements
- AWS 계정
- Terraform
- AWS CLI

## Deploy

### 1. Terraform backend 준비

```shell
terraform init
terraform apply
```

#### Variables

| name | description |
| ---- | ----------- |
| `backend_s3_bucket`| Terraform backend로 사용할 S3 버킷이름 |
| `terraform-lock`| State Lock을 위한 DynamoDB 테이블 이름 |

### 2. Provisioning

```shell
cd env/dev
terraform init -backend-config="bucket=버킷이름"  # backend로 사용할 S3 버킷 이름
terraform apply
```

#### Variables

| name | description |
| ---- | ----------- |
| `name`| 애플리케이션 스택 이름 |
| `ipv4_cidr`| VPC 구성에 사용할 IPv4 CIDR 영역 |
| `container_port`| 컨테이너에서 로드 밸런서로 매핑하려는 포트 |
| `container_uri` | ECR에 저장된 이미지 URI |
| `database_name` | 데이터베이스 이름 |
| `database_username` | 데이터베이스 사용자 이름 |
| `database_password` | 데이터베이스 암호 |
| `database_hostname` | 데이터베이스 엔드포인트 |
