FROM ghcr.io/project-osrm/osrm-backend:latest as builder

# Install curl
RUN apt-get update && apt-get install -y curl

RUN mkdir -p data
WORKDIR /data
# Download the OSM data
RUN curl -o /data/india-latest.osm.pbf https://download.geofabrik.de/asia/india-latest.osm.pbf

# Ensure the data is processed
RUN osrm-extract /data/india-latest.osm.pbf -o /data/india-latest.osrm
RUN osrm-partition /data/india-latest.osrm
RUN osrm-customize /data/india-latest.osrm
