variable "fn" {
  type    = string
  default = "sample_file.txt"
}

variable "num" {
  type    = number
  default = 3.5677
}
resource "local_file" "sample_res1" {
  filename = "sample1.txt"
  content  = var.num

  lifecycle {
    prevent_destroy = true
  }
}

resource "local_file" "sample_res2" {
  filename = "sample1.txt"
  content  = var.lt[0]

  lifecycle {
    create_before_destroy = true
  }
}


resource "local_file" "sample_res3" {
  filename = "sample3.txt"
  content  = var.obj["a"]
}

resource "local_file" "sample_res4" {
  filename = "sample4.txt"
  content  = var.tup[0]
}

resource "local_file" "sample_res5" {
  filename = "sample5.txt"
  content  = var.mp.name[0]
}

/*
resource local_file sample1_file{
    filename="sample2.txt"
    content=var.content
}
*/

// My first comment
/**/
variable "lt" {
  type    = list(any)
  default = ["dscsd", "dscdsc", "cddcd", "cddcd"]
}

variable "mp" {
  type    = map(list(number))
  default = { name = [3, 5], age = [6, 7], x = [2, 4, 5] }
}

variable "st" {
  type    = set(string)
  default = ["dscsd", "dscdsc", "cddcd", "cddcd"]
}

variable "tup" {
  type    = tuple([number, string, list(number)])
  default = [3, "name", [5, 3, ]]
}

variable "obj" {
  type = object({
    a = number
    b = string
  })
  default = {
    a = 22
    b = "dssd"
  }
}
output "val" {
  value = var.tup
}

terraform {
  #   required_version = ">= 0.12"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "random" {

}
