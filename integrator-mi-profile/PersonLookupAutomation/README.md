# Person Lookup Automation

## Description

An automation that looks up a person record from a SOAP service and logs a summary of it. Each run calls the service once for the configured person ID, logs the person's name, age, date of birth, and home city, and exits. Schedule it to run the lookup periodically without a continuously running process.

The integration has no API, proxy, or task. It runs as the main sequence of the integration (`PersonRecordSeq`, set as `mainSequence` in `pom.xml`), which the runtime executes once at startup before shutting down.

## Configuration

The integration reads the following value, declared in `src/main/wso2mi/resources/conf/config.properties`:

- `personId`: the ID of the person to look up

For a local run, set it as an environment variable or create a `.env` file in the project directory with the following value:

```
personId=1
```

## Usage Instructions

1. Run the integration locally using the Run button in WSO2 Integrator: MI.

To run it on a Micro Integrator server, build the project with `mvn clean install`, copy `target/PersonLookupAutomation_1.0.0.car` to `<MI_HOME>/repository/deployment/server/carbonapps/`, and start the server in automation mode:

```bash
./bin/micro-integrator.sh --car PersonLookupAutomation --env-file=<project directory>/.env
```

### Deploy on **WSO2 Cloud**

1. Deploy this integration on **WSO2 Cloud** as an **Automation**.
2. Configure `personId` before running the **Automation**.
3. Click **Schedule** and configure how often the lookup should run.

Note: If scheduling this job is not a requirement, you can execute the integration locally using the Run button in WSO2 Integrator: MI.

## How It Works

- `PersonRecordSeq` builds a `FindPerson` request for the configured `personId` and calls the `PersonRecordEP` endpoint, the public `SOAP.Demo` service at `http://www.crcind.com/csp/samples/SOAP.Demo.cls`.
- The call is blocking, so the response returns to the same sequence before the run ends.
- If the response contains a person, the sequence logs a one-line summary. If the ID matches no person, the service returns an empty response and the sequence logs a warning.
- If the call fails, for example because the service is unreachable, `PersonLookupErrorSeq` logs the error code and message.

## Example Log Output

```
INFO {LogMediator} - Looking up person record for ID: 1
INFO {LogMediator} - Person found: Name = Newton,Dave R., Age = 26, DOB = 2000-03-20, Home = Pueblo, AK
```

When no person matches the ID:

```
INFO {LogMediator} - Looking up person record for ID: 99999
WARN {LogMediator} - No person record found for ID: 99999
```

## References

- [Schedule Your First Automation](https://wso2.com/devant/docs/quick-start-guides/schedule-your-first-automation)
