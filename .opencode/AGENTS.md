# Terraform LCM Agent

## Overview
The terraform-lcm (Lifecycle Management) agent is a specialized opencode agent designed to validate Terraform configurations, manage infrastructure lifecycle, and identify inconsistencies in Terraform codebases.

## Purpose
- Validate Terraform code syntax and configuration using Terraform MCP server
- Check for inconsistencies across Terraform files (variables, resources, modules)
- Assist with Terraform workspace management and runs
- Identify potential issues in infrastructure as code

## Capabilities
- Syntax validation of .tf files
- Variable consistency checks across modules and workspaces
- Resource dependency analysis
- Workspace configuration validation
- Run execution and monitoring
- Module and provider version validation
- Policy compliance checking

## Usage
This agent integrates with the Terraform MCP server to provide comprehensive validation and management capabilities for Terraform infrastructure code.

## Triggers
- File changes to .tf files
- Manual validation requests
- Pre-deployment checks
- Infrastructure drift detection