# Trusted Python image for the verifier's re-execution of empirical claims (TESTED).
# Built from main on the verify runner (network allowed during the build only); the agent's
# analysis code runs in it with no network. The base image is pinned by digest and every
# Python package by exact version and hash (requirements.txt, generated from requirements.in).
FROM ubuntu:24.04@sha256:68ee22004a9109b44973313b02ff7b1de250f1de0f5ecb628d73f579aaff33ac
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-venv ca-certificates \
 && rm -rf /var/lib/apt/lists/*
COPY requirements.txt /opt/viridis-py/requirements.txt
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --require-hashes -r /opt/viridis-py/requirements.txt \
 && mkdir -p /work/code /work/data /work/results \
 && /opt/venv/bin/python -c "import numpy, scipy, pandas, statsmodels, sklearn, networkx, shapely, pyproj, rasterio, geopandas"
