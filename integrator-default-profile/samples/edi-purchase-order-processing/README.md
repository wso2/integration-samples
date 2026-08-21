# EDI Purchase Order Processing

## Description

Reads an inbound EDIFACT purchase order interchange, identifies the trading partner from the envelope headers without a schema, and parses the orders inside it into typed Ballerina records. A message the schema cannot read is quarantined with its parse error, and the rest of the interchange is still processed.

This is the finished code for the [Process Inbound EDI Purchase Orders from Trading Partners](https://wso2.com/integrator/docs/guides/howtoguides/edi-purchase-order-processing/) guide.

## Project layout

```text
edi-purchase-order-processing/
├── edi_order_processing/   # the integration
├── orders/                 # typed ORDERS library, generated with `bal edi codegen`
├── schema/ORDERS.json      # the EDI schema, adjusted for this trading partner
└── orders.edi              # sample interchange: two valid orders and one malformed message
```

## Usage Instructions

1. Open the workspace in WSO2 Integrator and select **Run** on the `edi_order_processing` integration, or run it from the terminal:

   ```bash
   cd edi_order_processing
   bal run
   ```

2. Two orders are logged, and the third message — which is missing its mandatory `BGM` segment — is quarantined with the reason:

   ```text
   level=INFO  message="Order file from SUPERMART, reference REF2"
   level=INFO  message="Order PO20001 received from SUPERMART"
   level=INFO  message="Order PO20002 received from SUPERMART"
   level=ERROR message="Quarantined message" reference="0003" error="Mandatory unit is missing in the EDI. Unit: Segment BGM ..."
   ```

3. Change the sender in the `UNB` segment of `orders.edi` to something other than `SUPERMART` and run again: the file is rejected on the envelope alone, without the schema being consulted.

The file path and the expected partner are configurable:

```toml
ediFilePath = "../orders.edi"
tradingPartner = "SUPERMART"
```

## Regenerating the library

The schema was generated from the free UN/EDIFACT D03A directory, then adjusted for this partner — the `QTY` segment of a line item, optional in the standard, is required here because the partner always sends it. That adjustment is why this sample generates a library: a partner sending the standard `ORDERS` message unchanged can import [`ballerinax/edifact.d03a.supplychain`](https://central.ballerina.io/ballerinax/edifact.d03a.supplychain/latest) instead and skip generation entirely.

Download the D03A archive from [UN/EDIFACT directory downloads](https://unece.org/trade/uncefact/unedifact/download), then:

```bash
bal edi convertEdifactSchema -v d03a -t ORDERS -i d03a.zip -o schema
cd orders && bal edi codegen -i ../schema/ORDERS.json -o orders.bal
```

## References

- [EDI Processing](https://wso2.com/integrator/docs/develop/transform/edi/)
- [EDI tool](https://wso2.com/integrator/docs/develop/tools/integration-tools/edi-tool/)
- [`ballerina/edi` API docs](https://central.ballerina.io/ballerina/edi/latest)
