# Use the OSRM backend image as the base
FROM ghcr.io/project-osrm/osrm-backend:latest as builder

# Install curl
RUN apt-get update && apt-get install -y curl

# Set the working directory
WORKDIR /data

# Add build arguments
ARG OSM_FILE_URL
ARG REGION_NAME
RUN curl -o ${REGION_NAME}.osm.pbf ${OSM_FILE_URL}

# Process the map data
RUN osrm-extract -p /opt/car.lua ${REGION_NAME}.osm.pbf \
    && osrm-partition ${REGION_NAME}.osrm \
    && osrm-customize ${REGION_NAME}.osrm

# Start the OSRM backend with the India map
FROM ghcr.io/project-osrm/osrm-backend
COPY --from=builder /data /data
EXPOSE 5050
CMD ["osrm-routed", "--algorithm", "mld", "/data/${REGION_NAME}.osrm"]
