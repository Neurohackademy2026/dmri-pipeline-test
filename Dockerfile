FROM python:3.12-slim

# Install light-weight runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Pre-install neuroimaging dependencies
RUN pip install --no-cache-dir numpy nibabel dipy matplotlib

WORKDIR /workspace
CMD ["python"]