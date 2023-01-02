# To use this script, you will need to replace YOUR_GITHUB_TOKEN with your personal access token. You can obtain a personal access token by following the instructions in the GitHub documentation.
#
# When you run this script, you will be prompted to enter the repository name and description. The script will then check if the repository name is already being used, and if it is not, it will create the repository and enable branch protections for the main branch. It will also create a default README.md file that contains the repository name and description.
#
# To run this:
#
# terraform init
# terraform plan
# terraform apply
#

# Configure the GitHub provider
provider "github" {
  # Replace YOUR_GITHUB_TOKEN with your personal access token
  token = "YOUR_GITHUB_TOKEN"
}

# Prompt the user for the repository name and description
variable "repository_name" {
  type = string
  description = "Enter the name of the repository"
}

variable "repository_description" {
  type = string
  description = "Enter the description of the repository"
}

# Check if the repository name is already being used
data "github_repository" "repository" {
  name = var.repository_name
}

# Create the repository
resource "github_repository" "repository" {
  name        = var.repository_name
  description = var.repository_description
  # Enable branch protections for the main branch
  branch_protection {
    branch = "main"
    required_status_checks {
      strict = true
      contexts = []
    }
    enforce_admins = true
    required_pull_request_reviews {
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
      required_approving_review_count = 1
    }
    restrictions {
      teams = []
      users = []
    }
  }
}

# Create a default README.md file
resource "github_repository_file" "readme" {
  repository = github_repository.repository.name
  branch     = "main"
  path       = "README.md"
  message    = "Initial commit"
  content    = base64encode(<<EOF
# ${var.repository_name}

${var.repository_description}
EOF
)
}

