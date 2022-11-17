# # Заменить на ID своего облака
# # https://console.cloud.yandex.ru/cloud?section=overview
# variable "yandex_cloud_id" {
#   default = "b1gd83gqq6vu73hvnnio"
# }

# # Заменить на Folder своего облака
# # https://console.cloud.yandex.ru/cloud?section=overview
# variable "yandex_folder_id" {
#   default = "b1g5c439t6nqk4aep66h"
# }

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "centos-7-base" {
  default = "fd89gj0pgbjri55i1ata"
}
