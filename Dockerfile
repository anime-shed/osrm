# =========================
# Builder stage
# =========================
FROM ghcr.io/project-osrm/osrm-backend:latest AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Some base images set broken certificate paths.
ENV CURL_CA_BUNDLE=
ENV SSL_CERT_FILE=
ENV SSL_CERT_DIR=

WORKDIR /data

ARG OSM_FILE_URL
ARG REGION_NAME

# Download map
RUN echo "Downloading map data for ${REGION_NAME}..." && \
    curl \
      --cacert /etc/ssl/certs/ca-certificates.crt \
      -fL \
      -o "${REGION_NAME}.osm.pbf" \
      "${OSM_FILE_URL}"

# Process map
RUN echo "Extracting map data..." && \
    osrm-extract -p /opt/car.lua -t 4 "${REGION_NAME}.osm.pbf" && \
    echo "Partitioning map data..." && \
    osrm-partition "${REGION_NAME}.osrm" && \
    echo "Customizing map data..." && \
    osrm-customize "${REGION_NAME}.osrm"

# =========================
# Runtime stage
# =========================
FROM ghcr.io/project-osrm/osrm-backend:latest

WORKDIR /data

COPY --from=builder /data /data

EXPOSE 5000

ARG REGION_NAME
ENV REGION_NAME=${REGION_NAME}

CMD sh -c 'osrm-routed --algorithm mld --max-table-size 10000 /data/${REGION_NAME}.osrm'
