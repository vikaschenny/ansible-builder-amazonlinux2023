[![CI](https://github.com/ansible/ansible-builder/actions/workflows/ci.yml/badge.svg?branch=devel)](https://github.com/ansible/ansible-builder/actions?query=branch%3Adevel)
[![codecov](https://codecov.io/gh/ansible/ansible-builder/branch/devel/graph/badge.svg?token=4F6P3DBI40)](https://codecov.io/gh/ansible/ansible-builder)

# Ansible Builder

Ansible Builder is a tool that automates the process of building execution
environments using the schemas and tooling defined in various Ansible
Collections and by the user.

See the readthedocs page for `ansible-builder` at:

https://docs.ansible.com/projects/builder/en/stable/


## Get Involved:

* We welcome your feedback, questions and ideas.
  See our [Communication guide](https://docs.ansible.com/projects/builder/en/latest/community/)
  to learn how to join the conversation.
* We use [GitHub issues](https://github.com/ansible/ansible-builder/issues) to
  track bug reports and feature ideas.
* Want to contribute, check out our [guide](CONTRIBUTING.md).

## Code of Conduct

We ask all of our community members and contributors to adhere to the [Ansible
code of
conduct](https://docs.ansible.com/projects/ansible/latest/community/code_of_conduct.html). If


## Ansible Builder image (Amazon Linux 2023)

This folder contains a Containerfile for building an `ansible-builder` image
based on the custom Python builder image `vikaschenny/python-builder-image:amazonlinux2023`.

The resulting image can be used to build Ansible Execution Environments while
keeping the base OS aligned with Amazon Linux 2023.

---

### Prerequisites

- **Docker** or **Podman** installed on the build host
- Access to the base image:
  - `vikaschenny/python-builder-image:amazonlinux2023`

> The base image itself is built from `vikaschenny/python-base-image:amazonlinux2023`
> and includes the Python build tooling and scripts used by Ansible Builder.

---

### Containerfile overview

Key points from `Containerfile`:

- **Base image argument**
  - `ARG BASE_IMAGE=vikaschenny/python-builder-image:amazonlinux2023`
- **Builder stage**
  - `FROM $BASE_IMAGE AS builder`
  - Copies the `ansible-builder` source into `/tmp/src`
  - Copies helper scripts from `src/ansible_builder/_target_scripts/` into `/output/scripts/`
  - Ensures `pip` is available and installs `bindep` and `wheel`
  - Runs `/output/scripts/assemble` to produce build artifacts under `/output`
- **Final stage**
  - `FROM $BASE_IMAGE`
  - Copies `/output` from the builder stage
  - Runs `/output/scripts/install-from-bindep` to install required system/Python deps
  - Cleans everything in `/output` except `install-from-bindep`
  - Copies the `assemble` script into `/usr/local/bin/assemble`

---

### Build locally

From the `ansible-builder` directory (next to `Containerfile`):

```bash
cd ansible-builder

# Using Docker
docker build -f Containerfile -t ansible-builder:latest .

# Or using Podman
podman build -f Containerfile -t ansible-builder:latest .
```

This produces an `ansible-builder:latest` image based on
`vikaschenny/python-builder-image:amazonlinux2023`.

---

### Build on the MCP server

On the MCP server (assuming the repo is cloned to `~/ansible-builder`
and the base image is available there):

```bash
cd ~/ansible-builder
docker build -f Containerfile -t ansible-builder:latest .
```

After the build completes you can verify the image:

```bash
docker images ansible-builder:latest
```

You should see `ansible-builder:latest` with the Amazon Linux 2023–based
builder image as its base.

---

### Using the built image

Once built, the `ansible-builder:latest` image can be used with the
`ansible-builder` CLI to create execution environments, for example:

```bash
ansible-builder build \
  -t my-ee:latest \
  -f execution-environment.yml
```

Configure your tooling (CI/CD, local scripts, etc.) to use
`ansible-builder:latest` as the image that runs this command.

you have questions, or need assistance, please reach out to our community team
at [codeofconduct@ansible.com](mailto:codeofconduct@ansible.com).

## License

[Apache License v2.0](./LICENSE.md)
