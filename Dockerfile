# syntax=docker/dockerfile:1

################################################################################

# Create a stage for building the application.
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:6.0 AS build



# Create a new .NET console application
RUN dotnet new console -o testApp && cd testApp && \
    # Add a vulnerable version of Newtonsoft.Json
    dotnet add package Newtonsoft.Json --version 12.0.1 && \
    # Restore dependencies
    dotnet restore && \
    rm -rf testApp

COPY . /source

WORKDIR /source/src

# Build the application
RUN dotnet publish -c Release -o /app

################################################################################

# Create a new stage for running the application.
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final

LABEL maintainer="onoureldin14" \
      version="1.0.0" \
      description="A sample .NET application with a vulnerable dependency for testing" \
      image.base.ref.name="mcr.microsoft.com/dotnet/aspnet:6.0"

WORKDIR /app

# Copy everything needed to run the app from the "build" stage.
COPY --from=build /app .

# Create a non-privileged user that the app will run under.
ARG UID=10001
RUN useradd \
    --no-create-home \
    --shell /usr/sbin/nologin \
    --uid "${UID}" \
    appuser
USER appuser

ENTRYPOINT ["dotnet", "testApp.dll"]
