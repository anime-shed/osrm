FROM ghcr.io/project-osrm/osrm-backend:latest as builder

# Install curl
RUN apt-get update && apt-get install -y curl

RUN mkdir -p /data
WORKDIR /data

# Download the OSM data
RUN curl -o india-latest.osm.pbf https://download.geofabrik.de/asia/india-latest.osm.pbf

# Set the command to run when the container starts
CMD ["osrm-routed", "--algorithm", "mld", "/data/india-latest.osrm"]

# Expose the /data directory
VOLUME ["/data"]
