resource aws_ecr_repository _ {
  name                 = "measurabl"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource aws_codecommit_repository _ {
  default_branch  = "main"
  description     = "for measurabl take home test"
  repository_name = "measurable"
}
