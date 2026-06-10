# Builder stage
FROM ghcr.io/project-osrm/osrm-backend:latest AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /data

ARG OSM_FILE_URL
ARG REGION_NAME

RUN echo "Downloading map data for ${REGION_NAME}..." && \
    curl -fL -o "${REGION_NAME}.osm.pbf" "${OSM_FILE_URL}"

RUN echo "Extracting map data..." && \
    osrm-extract -p /opt/car.lua -t 4 "${REGION_NAME}.osm.pbf" && \
    echo "Partitioning map data..." && \
    osrm-partition "${REGION_NAME}.osrm" && \
    echo "Customizing map data..." && \
    osrm-customize "${REGION_NAME}.osrm"

# Runtime stage
FROM ghcr.io/project-osrm/osrm-backend:latest

WORKDIR /data

COPY --from=builder /data /data

EXPOSE 5000

ARG REGION_NAME
ENV REGION_NAME=${REGION_NAME}

CMD ["sh", "-c", "osrm-routed --algorithm mld --max-table-size 10000 /data/${REGION_NAME}.osrm"]
