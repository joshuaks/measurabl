variable default_name {
  type        = string
  description = "the default name for most resources"
  default     = "MeasurableWebPageCounter"
}

variable db_webpage_name {
  type        = string
  description = "associates webpage name with a counter value"
  default     = "measurabl"
}

variable lambda_role_arn   {
  type        = string
  description = "default access given by AWS + DynamoDBAccess"
  default     = "arn:aws:iam::809243998450:role/service-role/foo-role-60bvu770"
}

variable lambda_runtime {
  type        = string
  description = "runtime to use against the given lambda script"
  default     = "nodejs14.x"
}

variable lambda_architecture {
  type        = string
  description = "must be either x86 or arm64, arm64 is generally cheaper"
  default     = "arm64"
}
