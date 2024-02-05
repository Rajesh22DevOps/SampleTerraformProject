# SampleTerraformKubernetesProject
This terraform module deploys a deployment on kubernetes and adds a service.

Usage:

module "deployment" {
  source              = "rajesh/deployment/kubernetes"
  version             = "~> 2.4"
  image_name          = "nginx"
  image_tag           = "latest"
  namespace           = "production"
  object_prefix       = "nginx"
  ports               = [
    {
      name           = "http"
      protocol       = "TCP"
      container_port = "8080"
      service_port   = "80"
    },
    {
      name           = "https"
      protocol       = "TCP"
      container_port = "8443"
      service_port   = "443"
    }
  ]
  volumes  = [{
    name         = "html"
    type         = "persistent_volume_claim"
    object_name  = "nginx"
    readonly     = false
    mounts = [{
      mount_path = "/usr/share/nginx/html"
    }]
  }]
  labels              = {
    "app.kubernetes.io/part-of" = "nginx"
  }
  env = {
    NGINX_HOST                  = "domain.com",
    NGINX_ENTRYPOINT_QUIET_LOGS = 1
  }
  env_secret = [{
    name   = "USERNAME"
    secret = app-secret
    key    = "username"
  },
  {
    name   = "PASSWORD"
    secret = app-secret
    key    = "password"
  }]
  custom_certificate_authority = [ "my-ca" ]
}