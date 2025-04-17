# Builder stage to process map data
FROM ghcr.io/project-osrm/osrm-backend:latest AS builder

# Install curl for downloading map data
RUN apk add --no-cache curl

# Set working directory for map data processing
WORKDIR /data

# Define build arguments for map data
ARG OSM_FILE_URL
ARG REGION_NAME

# Download the OSM file with error handling
RUN echo "Downloading map data for ${REGION_NAME}..." && \
    curl -L -o "${REGION_NAME}.osm.pbf" "${OSM_FILE_URL}" && \
    [ -f "${REGION_NAME}.osm.pbf" ] || { echo "Download failed"; exit 1; }

# Process the map data using MLD pipeline with memory optimization
# Use a thread count suitable for most modern servers; adjust based on available cores
RUN echo "Extracting map data..." && \
    osrm-extract -p /opt/car.lua -t 4 "${REGION_NAME}.osm.pbf" && \
    echo "Partitioning map data..." && \
    osrm-partition "${REGION_NAME}.osrm" && \
    echo "Customizing map data..." && \
    osrm-customize "${REGION_NAME}.osrm" || { echo "Processing failed"; exit 1; }

# Runtime stage to serve the routing engine
FROM ghcr.io/project-osrm/osrm-backend:latest

# Copy processed data from builder stage
COPY --from=builder /data /data

# Expose the default OSRM port
EXPOSE 5000

# Define environment variable for region name to use in CMD
ARG REGION_NAME
ENV REGION_NAME=${REGION_NAME}

# Start the OSRM routing server with MLD algorithm
# Added --max-table-size to support larger queries if needed
CMD ["sh", "-c", "osrm-routed --algorithm mld --max-table-size 10000 /data/${REGION_NAME}.osrm"]