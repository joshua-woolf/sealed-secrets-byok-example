# Sealed Secrets BYOK Example

This repository is an example of how to use sealed secrets with a self-managed key pair.

## Getting Started

**Prerequisites**

This script can be run on WSL.

Run [Docker Desktop](https://www.docker.com/products/docker-desktop) on your Windows host.

Install [Homebrew](https://brew.sh):

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install the dependencies:

```shell
brew bundle
```

Run the example:

```shell
./example-secret.sh
```