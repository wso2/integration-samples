# EDI Purchase Order Processing

## Description

Picks up EDIFACT purchase order interchanges that a trading partner drops on an SFTP server, identifies the partner from the envelope headers without a schema, and parses the orders inside into typed Ballerina records with the prebuilt [`ballerinax/edifact.d03a.supplychain`](https://central.ballerina.io/ballerinax/edifact.d03a.supplychain/latest) package. A file from an unknown partner is moved to a `rejected` folder. A message the schema cannot read is quarantined with its parse error, and the rest of the interchange is still processed.

This is the finished code for the [Process Inbound EDI Purchase Orders from Trading Partners](https://wso2.com/integration-platform/docs/integrator/guides/business-use-cases/edi-purchase-order-processing/) guide.

## Project layout

```text
edi-purchase-order-processing/
├── edi_order_processing/   # the integration: an SFTP service with an onFile handler
├── orders.edi              # sample interchange: two valid orders and one malformed message
└── docker-compose.yml      # local SFTP server standing in for the partner's mailbox
```

## Usage Instructions

1. Start the SFTP server. It creates the user `partner` with the `edi/inbox`, `edi/processed`, and `edi/rejected` folders:

   ```bash
   docker compose up -d
   ```

2. Add a `Config.toml` to `edi_order_processing` with the SFTP credentials:

   ```toml
   sftpUsername = "partner"
   sftpPassword = "partner123"
   ```

3. Open the project in WSO2 Integrator and select **Run** on the `edi_order_processing` integration, or run it from the terminal:

   ```bash
   cd edi_order_processing
   bal run
   ```

4. Drop the sample interchange into the inbox:

   ```bash
   docker cp orders.edi edi-sftp:/home/partner/edi/inbox/
   docker exec edi-sftp chown partner /home/partner/edi/inbox/orders.edi
   ```

   On its next poll (once a minute by default), the listener logs two orders and quarantines the third message, which is missing its mandatory `BGM` segment. The file then moves to `edi/processed`.

   ```text
   level=INFO  message="Order file from SUPERMART, reference REF2"
   level=INFO  message="Order PO20001 received from SUPERMART"
   level=INFO  message="Order PO20002 received from SUPERMART"
   level=ERROR message="Quarantined message" error={..."message":"Mandatory unit is missing in the EDI. Unit: Segment BGM ..."} reference="0003"
   ```

5. Change the sender in the `UNB` segment of `orders.edi` to something other than `SUPERMART` and drop it again: the file is rejected on the envelope alone, without the schema being consulted, and moves to `edi/rejected`.

The expected partner is configurable with `tradingPartner` (default `SUPERMART`).

## Using your own message schema

The prebuilt package covers the standard UN/EDIFACT D03A `ORDERS` message. When a partner deviates from the standard, or sends a message type or directory version that no prebuilt package covers, generate a parser from the specification with the `bal edi` tool, adjust its schema to what the partner sends, and call its `interchangeFromEdiString` in place of the package's. See [Generating code from an EDIFACT spec](https://wso2.com/integration-platform/docs/integrator/develop-and-test/data-transformation/edi/#generating-code-from-an-edifact-spec) and [Adapting the schema to a trading partner](https://wso2.com/integration-platform/docs/integrator/develop-and-test/data-transformation/edi/#adapting-the-schema-to-a-trading-partner).

## References

- [EDI Processing](https://wso2.com/integration-platform/docs/integrator/develop-and-test/data-transformation/edi/)
- [EDI tool](https://wso2.com/integration-platform/docs/integrator/develop-and-test/developer-tools/integration-tools/edi-tool/)
- [`ballerina/edi` API docs](https://central.ballerina.io/ballerina/edi/latest)
- [`ballerinax/edifact.d03a.supplychain` API docs](https://central.ballerina.io/ballerinax/edifact.d03a.supplychain/latest)
