#----------------------------------------------------------------
# Building Stage:
#
# this stage builds the application
#----------------------------------------------------------------
FROM node:14.20-buster-slim AS build

#WORKDIR /application/node_modules
WORKDIR /application

COPY package.json package-lock.json* ./
RUN npm install --from-lockfile

COPY . .
RUN npm run build --prod


#----------------------------------------------------------------
# Run Stage:
#
# this stage runs the application as s2i
# See base image for more information:
# https://catalog.redhat.com/software/containers/ubi8/nginx-120/6156abfac739c0a4123a86fd
#----------------------------------------------------------------
FROM registry.access.redhat.com/ubi8/nginx-120

# Add application to the source directory for the assemble script
# Also sets permissions so that container runs without root access
USER 0
COPY --from=build /application/dist/roadhouse /tmp/src/
RUN chown -R 1001:0 /tmp/src
USER 1001

# Execute assemble script to install the dependencies.
RUN /usr/libexec/s2i/assemble

# Run script for executing nginx
CMD /usr/libexec/s2i/run
