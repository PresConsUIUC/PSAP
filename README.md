# Quick Start

To get the application up and running, see [PreparingADevelopmentEnvironment](https://github.com/PresConsUIUC/PSAP/wiki/PreparingADevelopmentEnvironment).

# Development

## SCM Workflow

This project uses the "Gitflow" git workflow, described at:
* [http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/)
* [https://www.atlassian.com/git/workflows#!workflow-gitflow](https://www.atlassian.com/git/workflows#!workflow-gitflow)

## Coding Standards

Indentation is two spaces. Spaces are used instead of tabs. 80-character
margins are aimed for but sometimes exceeded, especially in the view templates.

# Deployment

PSAP is configured to use Capistrano for deployment. At UIUC, it runs in
Passenger Standalone, reverse-proxied behind Apache.

You must change the secret key when you deploy. The command `rake secret`
generates a new random secret you can use. Copy it from the console output to
a file called `.secret` in the application root.

Initially, only one user exists: an administrator with username of `admin` and
password `password.` Immediately after deploying, you should log in as this
user and change the password.

# Notes

PSAP uses the standard Rails application configuration files in
`config/environments`.

The application version number is set in `app/helpers/application_helper.rb`.
