# Use the OSRM backend image as the base
FROM ghcr.io/project-osrm/osrm-backend:latest as builder

# Install curl
RUN apt-get update && apt-get install -y curl

# Set the working directory
WORKDIR /data

# Download the OSM data
RUN curl -o india-latest.osm.pbf https://download.geofabrik.de/asia/india/northern-zone-latest.osm.pbf

# Process the map data
RUN osrm-extract -p /opt/car.lua india-latest.osm.pbf \
    && osrm-partition india-latest.osrm \
    && osrm-customize india-latest.osrm

# Start the OSRM backend with the India map
FROM ghcr.io/project-osrm/osrm-backend
COPY --from=builder /data /data
EXPOSE 5050
CMD ["osrm-routed", "--algorithm", "mld", "/data/india-latest.osrm"]
