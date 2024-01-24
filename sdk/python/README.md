# Getting started - Managing NGINXaaS for Azure using Azure Python SDK

These code samples will show you how to manage NGINXaaS for Azure using Azure SDK for Python.

## Features

This project framework provides examples for the following services:

### NGINXaaS for Azure

* Using the Azure SDK for Python - NGINXaaS for Azure Management Library [azure-mgmt-nginx](https://pypi.org/project/azure-mgmt-nginx/)

## Getting Started

### Prerequisites

1. Before we run the samples, we need to make sure we have setup the credentials. Follow the instructions in [register a new application using Azure portal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) to obtain `subscription id`,`client id`,`client secret`, and `application id`

2. Store your credentials an environment variables.
For example, in Linux-based OS, you can do

```bash
export AZURE_TENANT_ID="xxx"
export AZURE_CLIENT_ID="xxx"
export AZURE_CLIENT_SECRET="xxx"
export AZURE_SUBSCRIPTION_ID="xxx"
```

### Installation

1. If you don't already have it, [install Python](https://www.python.org/downloads/).

2. General recommendation for Python development is to use a Virtual Environment.
    For more information, see [Virtual Environments and Packages](https://docs.python.org/3/tutorial/venv.html)

    Install and initialize the virtual environment with the "venv" module on Python 3 (you must install [virtualenv](https://pypi.python.org/pypi/virtualenv) for Python 2.7):

    ```bash
    python -m venv venv # Might be "python3" or "py -3.6" depending on your Python installation
    source venv/bin/activate      # Linux shell (Bash, ZSH, etc.) only
    ./venv/scripts/activate       # PowerShell only
    ./venv/scripts/activate.bat   # Windows CMD only
    ```

### Quickstart

1. Clone the repository.

    ```bash
    git clone https://github.com/nginxinc/nginx-for-azure-snippets.git
    ```

2. Install the dependencies using pip.

    ```bash
    cd nginx-for-azure-snippets/sdk/python/
    pip install -r requirements.txt
    ```

## Demo

To run each individual demo, point directly to the file. For example:

```bash
python3 deployments/create_or_update.py
```

## Resources

* <https://github.com/Azure/azure-sdk-for-python>
