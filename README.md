# Udemy Scraper Project
## Business Requirements
### Online scraping
- scrape the stats from each udemy course I own
- generate an object for each course
- store the file as json in the cloud
### PDF scraping
- access certificates PDF stored in the cloud
- scrape the stats from each certificate
- generate an object for each certificate
- store the file as json in the cloud
## Requirements analysis
### Functional Requirements
- Development
  - Use GitHub as Version Control System
  - Use Python for the source code
    - Use UV as the package manager

- Deployment
  - use Terraform for Infrastucture as Code
    - provider: aws, docker
  - use AWS as cloud service provider
  - build serverless as lambda app
  - build docker image
  - push the image to Elastic Container Registry (ECR)
