terraform {
  required_providers {
    flexibleengine = {
      source = "flexibleenginecloud/flexibleengine"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
  required_version = ">= 0.13"
}
