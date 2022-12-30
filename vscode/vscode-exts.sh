#!/bin/bash
# run as root / admin

code --install-extension ms-azuretools.vscode-azureappservice
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-azuretools.vscode-azurelogicapps
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-azuretools.vscode-logicapps
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension GraphQL.vscode-graphql
code --install-extension HashiCorp.terraform
code --install-extension eamodio.gitlens
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension vscode-icons-team.vscode-icons
code --install-extension dbaeumer.vscode-eslint
code --install-extension formulahendry.code-runner
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension eamodio.gitlens
code --install-extension mechatroner.rainbow-csv

code --list-extensions

az bicep install
az bicep upgrade

az extension add --name azure-devops
