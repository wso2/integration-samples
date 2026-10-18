# EDI Purchase Order Processing

## Description

Picks up EDIFACT purchase order interchanges that a trading partner drops on an SFTP server, identifies the partner from the envelope headers without a schema, and parses the orders inside into typed Ballerina records with the prebuilt [`ballerinax/edifact.d03a.supplychain`](https://central.ballerina.io/ballerinax/edifact.d03a.supplychain/latest) package. Only `.edi` files are picked up. A file from an unknown partner is moved to a `rejected` folder. A message the schema cannot read is logged with its parse error while the rest of the interchange is still processed, and the partner gets an EDIFACT `APERAK` acknowledgement in the `outbox` folder listing the orders that were accepted and the messages that were rejected.

This is the finished code for the [Process Inbound EDI Purchase Orders from Trading Partners](https://wso2.com/integration-platform/docs/integrator/guides/business-use-cases/edi-purchase-order-processing/) guide.

## Project layout

```text
edi-purchase-order-processing/
├── edi_order_processing/   # the integration: an SFTP service with an onFile handler
│   └── functions.bal       # builds the APERAK acknowledgement
├── orders.edi              # sample interchange: two valid orders and one malformed message
└── docker-compose.yml      # local SFTP server standing in for the partner's mailbox
```

## Usage Instructions

1. Start the SFTP server. It creates the user `partner` with the `edi/inbox`, `edi/processed`, `edi/rejected`, and `edi/outbox` folders:

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

4. Drop the sample interchange into the inbox. Run this from the `edi_order_processing` directory used in the previous step:

   ```bash
   docker cp ../orders.edi edi-sftp:/home/partner/edi/inbox/
   docker exec edi-sftp chown partner /home/partner/edi/inbox/orders.edi
   ```

   On its next poll (once a minute by default), the listener logs two orders and rejects the third message, which is missing its mandatory `BGM` segment. The file then moves to `edi/processed`.

   ```text
   level=INFO  message="Order file from SUPERMART, reference REF2"
   level=INFO  message="Order PO20001 received from SUPERMART"
   level=INFO  message="Order PO20002 received from SUPERMART"
   level=ERROR message="Message rejected" error={..."message":"Mandatory unit is missing in the EDI. Unit: Segment BGM ..."} reference="0003"
   ```

5. Read the acknowledgement written to `edi/outbox`. It accepts the two orders (`DOC` segments) and reports the unreadable message `0003` with its error (`ERC`, `FTX`, and `RFF` segments):

   ```bash
   docker exec edi-sftp cat /home/partner/edi/outbox/orders.edi
   ```

6. Change the sender in the `UNB` segment of `orders.edi` to something other than `SUPERMART` and drop it again: the file is rejected on the envelope alone, without the schema being consulted, and moves to `edi/rejected`. A file without the `.edi` extension, such as a `.txt` file, is left in the inbox.

The expected partner is configurable with `tradingPartner` (default `SUPERMART`).

## Using your own message schema

The prebuilt package covers the standard UN/EDIFACT D03A `ORDERS` message. When a partner deviates from the standard, or sends a message type or directory version that no prebuilt package covers, generate a parser from the specification with the `bal edi` tool, adjust its schema to what the partner sends, and call its `interchangeFromEdiString` in place of the package's. See [Generating code from an EDIFACT spec](https://wso2.com/integration-platform/docs/integrator/develop-and-test/data-transformation/edi/#generating-code-from-an-edifact-spec) and [Adapting the schema to a trading partner](https://wso2.com/integration-platform/docs/integrator/develop-and-test/data-transformation/edi/#adapting-the-schema-to-a-trading-partner).

## References

- [EDI Processing](https://wso2.com/integration-platform/docs/integrator/develop-and-test/data-transformation/edi/)
- [EDI tool](https://wso2.com/integration-platform/docs/integrator/develop-and-test/developer-tools/integration-tools/edi-tool/)
- [`ballerina/edi` API docs](https://central.ballerina.io/ballerina/edi/latest)
- [`ballerinax/edifact.d03a.supplychain` API docs](https://central.ballerina.io/ballerinax/edifact.d03a.supplychain/latest)
