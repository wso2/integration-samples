# Person Lookup Automation

## Description

An automation that looks up a person record in a dataset bundled with the integration and logs a summary of it. Each run looks up the configured person ID once, logs the person's name, age, date of birth, and home city, and exits. The sample has no external dependencies, so it runs the same way locally and on WSO2 Cloud. Schedule it to run the lookup periodically without a continuously running process.

The integration has no API, proxy, or task. It runs as the main sequence of the integration (`PersonRecordSeq`, set as `mainSequence` in `pom.xml`), which the runtime executes once at startup before shutting down.

## Configuration

The integration reads the following value, declared in `src/main/wso2mi/resources/conf/config.properties`:

- `personId`: the ID of the person to look up. The bundled dataset contains IDs `1` to `5`.

For a local run, set it as an environment variable or create a `.env` file in the project directory with the following value:

```
personId=1
```

## Usage Instructions

1. Run the integration locally using the Run button in WSO2 Integrator: MI.

To run it on a Micro Integrator server, build the project with `mvn clean install`, copy `target/PersonLookupAutomation_1.0.0.car` to `<MI_HOME>/repository/deployment/server/carbonapps/`, and start the server in automation mode.

With `personId` set as an environment variable:

```bash
personId=1 ./bin/micro-integrator.sh --car PersonLookupAutomation
```

With `personId` set in a `.env` file:

```bash
./bin/micro-integrator.sh --car PersonLookupAutomation --env-file=<project directory>/.env
```

### Deploy on **WSO2 Cloud**

1. Deploy this integration on **WSO2 Cloud** as an **Automation**.
2. Before running the **Automation**, set `personId` in the Automation's configurations (for example, `1`). Do not pass it in the **Arguments** field of the run dialog. The integration reads `personId` as a configuration, not as a command-line argument.
3. Click **Schedule** and configure how often the lookup should run.

Note: If scheduling this job is not a requirement, you can execute the integration locally using the Run button in WSO2 Integrator: MI.

## How It Works

- The person records are stored in `src/main/wso2mi/resources/json/persons.json`, which is deployed as a registry resource at `gov:/mi-resources/json/persons.json`. Edit this file to add or change records.
- `PersonRecordSeq` reads the registry resource with the `registry()` function and selects the records whose `id` matches the configured `personId`.
- If a record matches, the sequence logs a one-line summary. If the ID matches no record, the sequence logs a warning.
- If the lookup fails, for example because `personId` is not set, `PersonLookupErrorSeq` logs the error code and message.

## Example Log Output

```
INFO {LogMediator} - Looking up person record for ID: 1
INFO {LogMediator} - Person found: Name = Newton, Dave R., Age = 26, DOB = 2000-03-20, Home = Pueblo, AK
```

When no person matches the ID:

```
INFO {LogMediator} - Looking up person record for ID: 99
WARN {LogMediator} - No person record found for ID: 99
```

## References

- [Schedule Your First Automation](https://wso2.com/devant/docs/quick-start-guides/schedule-your-first-automation)
