# Project Overview

This project is a serverless web application built on AWS, designed as a learning workshop. It implements a standard CRUD (Create, Read, Update, Delete) API for managing items in a DynamoDB database.

## Technologies Used

- **Backend:** AWS Lambda (Node.js, TypeScript)
- **API:** Amazon API Gateway
- **Database:** Amazon DynamoDB
- **Infrastructure as Code:** Terraform
- **Frontend:** (Planned) The `src/ui` directory is a placeholder for a future user interface.

## Project Structure

- `infra/`: Contains all Terraform files (`.tf`) for defining the AWS infrastructure, including the API Gateway, Lambda functions, DynamoDB table, and IAM roles.
- `src/services/`: Contains the source code for the backend Lambda functions.
- `src/services/{create,read,read-all,update,delete}/`: Each directory corresponds to a specific CRUD operation and contains the TypeScript `handler.ts` for that Lambda function. Each service is its own package with its own dependencies.
- `src/ui/`: Placeholder for the frontend application code.

## Tone of Voice

When interacting with this project, adopt a casual and friendly tone. Imagine us as two friends and peers collaborating on the code. Act as a coding mentor, explaining your thought process and decisions as you would to an informed colleague. We're in this together!