ARG BASE_IMAGE=vikaschenny/python-builder-image:amazonlinux2023

FROM $BASE_IMAGE AS builder
# build this library (meaning ansible-builder)
COPY . /tmp/src
COPY ./src/ansible_builder/_target_scripts/* /output/scripts/
RUN python3 -m ensurepip
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --no-cache-dir bindep wheel
RUN /output/scripts/assemble

FROM $BASE_IMAGE
COPY --from=builder /output/ /output
# building EEs require the install-from-bindep script, but not the rest of the /output folder
RUN /output/scripts/install-from-bindep && sh -c 'for p in /output/*; do [ "$(basename "$p")" = "install-from-bindep" ] || rm -rf "$p"; done'

# copy the assemble scripts themselves into this container
COPY ./src/ansible_builder/_target_scripts/assemble /usr/local/bin/assemble
