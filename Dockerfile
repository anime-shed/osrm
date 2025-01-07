FROM ghcr.io/project-osrm/osrm-backend:v5.24.0 as builder  # Use a specific version

# Install curl
RUN apt-get update && apt-get install -y curl

RUN mkdir -p /data
WORKDIR /data

# Download the OSM data
RUN curl -o india-latest.osm.pbf https://download.geofabrik.de/asia/india-latest.osm.pbf

# Set the command to run when the container starts
CMD ["osrm-routed", "--algorithm", "mld", "/data/india-latest.osrm"]
