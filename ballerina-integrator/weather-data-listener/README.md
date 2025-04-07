# Weather Data FTP Listener

This project demonstrates how to build an FTP listener using the Ballerina Integrator. It connects to the National Weather Service FTP server, which updates hourly with global weather data in the form of text files.

The integration listens to the FTP server, retrieves new weather data files, and logs them. This serves as a practical example of file-based integration with the Ballerina Integrator.

## Usage Instructions

1. Run the integration locally using the Run button in Ballerina Integrator.

## Deploy on Devant

1. Deploy this integration on **Devant** as an **File Integration**.

## How It Works

- The integration sets up an FTP listener that connects to the National Weather Service FTP server.
- It listens to the directory: `/data/observations/metar/decoded/`.
- When new weather data files are added to this directory, the listener automatically retrieves them.
- Each weather file is then processed, and the location of the weather report is logged to the console.
