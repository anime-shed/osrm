FROM ghcr.io/project-osrm/osrm-backend:latest as builder

# Install curl
RUN apt-get update && apt-get install -y curl

RUN mkdir -p /data
WORKDIR /data

# Download the OSM data
RUN curl -o india-latest.osm.pbf https://download.geofabrik.de/asia/india-latest.osm.pbf

# Ensure the data is processed
RUN osrm-extract --profile car india-latest.osm.pbf  # Specify the profile
RUN osrm-partition india-latest.osrm
RUN osrm-customize india-latest.osrm
