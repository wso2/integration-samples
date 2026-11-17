# Call RFC Functions and Receive IDocs with SAP ECC

## Description

A WSO2 Integrator integration that talks to SAP ECC in both directions with the SAP JCo connector. An HTTP API calls the `BAPI_MATERIAL_GET_DETAIL` function module over RFC and returns a material as JSON. An IDoc listener registers at the SAP gateway as a registered server program and receives the `MATMAS` IDocs that SAP sends whenever a material is distributed, maps them to a flat record with the Data Mapper, and logs them.

This is the sample project for the how-to guide [Call RFC Functions and Receive IDocs with SAP ECC](https://wso2.com/integration-platform/docs/integrator/guides/how-to-guides/sap-ecc-rfc-and-idoc-integration). The same project also works with SAP S/4HANA Private Cloud, as described in [Call RFC Functions and Receive IDocs with SAP S/4HANA Private Cloud](https://wso2.com/integration-platform/docs/integrator/guides/how-to-guides/sap-rfc-and-idoc-integration).

## What It Does

- Exposes `GET /materials/{material}` on port `9090`, which calls `BAPI_MATERIAL_GET_DETAIL` through a `jco:Client` connection and returns the material number, description, material type, material group and base unit
- Registers a `jco:Listener` at the SAP gateway under the program ID of an SM59 registered server program destination
- Converts each incoming `MATMAS05` IDoc into typed records with `xmldata:parseAsType`
- Maps the IDoc number, material, first description, material type, material group, base unit, net weight and weight unit to a `MaterialUpdate` record with the `toMaterialUpdate` data mapper, and logs it
- Logs listener errors, such as a refused gateway registration, in `onError`

## Prerequisites

### SAP JCo Libraries

Download the SAP Java Connector (SAP JCo) 3.1 and the SAP Java IDoc Class Library 3.1 from the [SAP Support Portal](https://support.sap.com/en/product/connectors/jco.html) (an SAP user ID is required). SAP does not allow redistributing them, so they are not part of this sample. Copy these files into the `libs` folder of the project:

- `sapjco3.jar`
- `sapidoc3.jar`
- The native JCo library for your operating system: `libsapjco3.dylib` on macOS, `libsapjco3.so` on Linux, or `sapjco3.dll` on Windows

### SAP ECC Setup

- Network access from the machine that runs the integration to the SAP application server (port `32<NN>`) and the SAP gateway (port `33<NN>`), where `<NN>` is the instance number.
- An SAP user that can log on with RFC and call `BAPI_MATERIAL_GET_DETAIL`.
- For the IDoc listener, the SAP-side setup from the how-to guide: an SM59 TCP/IP destination of type **Registered Server Program** (Unicode) with the program ID `WSO2_INTEGRATOR`, a `reginfo` entry in SMGW that allows the program from the integration host, a WE21 transactional RFC port, a BD54 logical system, a WE20 partner profile with outbound `MATMAS` / `MATMAS05`, and a BD64 distribution model entry.

## Configuration

Create a `Config.toml` file in the project root with the following values.

- `sapHost` - SAP application server host (the gateway runs on the same host)
- `sapSystemNumber` - SAP instance number, for example `00`
- `sapClient` - SAP client, for example `800`
- `sapUser` - SAP user
- `sapPassword` - SAP password
- `sapGatewayService` - SAP gateway service, for example `sapgw00` (or the port `3300`)
- `sapProgramId` - program ID of the SM59 registered server program destination

```toml
sapHost = "<SAP_HOST>"
sapSystemNumber = "00"
sapClient = "800"
sapUser = "<SAP_USER>"
sapPassword = "<SAP_PASSWORD>"
sapGatewayService = "sapgw00"
sapProgramId = "WSO2_INTEGRATOR"
```

## Usage Instructions

1. Copy the SAP JCo files into `libs` as described in [SAP JCo Libraries](#sap-jco-libraries).
2. Open the project in WSO2 Integrator and supply the values above under **Configurations**, or create `Config.toml` as shown.
3. Select **Run** on the integration overview, or run `bal run` from the project root.
4. Call the RFC path:

    ```bash
    curl http://localhost:9090/materials/P-100
    ```

5. Send a material from SAP with transaction `BD10` to the logical system of the integration, for example `WSO2INT`. The integration logs the mapped IDoc.

## How It Works

1. `config.bal` declares the seven configurables, and `connections.bal` creates the `jcoClient` connection from them with a `jco:DestinationConfig`.
2. `main.bal` defines the `/materials` HTTP service. The `GET /materials/{material}` resource calls `BAPI_MATERIAL_GET_DETAIL` and returns fields of the `MATERIAL_GENERAL_DATA` structure.
3. `main.bal` also defines the `sapListener` JCo listener and the `jco:IDocService`. `onReceive` gets each IDoc as XML, converts it into the record types in `types.bal`, maps it with `toMaterialUpdate` in `data_mappings.bal`, and logs the result. The listener confirms the IDoc to SAP after `onReceive` returns.
4. `onError` logs listener errors.

## Example Output

RFC path:

```json
{"material":"P-100", "description":"Pump PRECISION 100", "materialType":"FERT", "materialGroup":"001", "baseUnit":"ST"}
```

IDoc path:

```
time=2026-11-17T14:15:36.726+05:30 level=INFO module=wso2/sap_ecc_rfc_and_idoc_integration message="IDoc 0000000003528747 mapped: {\"idocNumber\":\"0000000003528747\", \"material\":\"P-100\", \"description\":\"Pump PRECISION 100\", \"materialType\":\"FERT\", \"materialGroup\":\"001\", \"baseUnit\":\"PCE\", \"netWeight\":\"250.000\", \"weightUnit\":\"KGM\"}"
```

SAP ECC sends unit fields in the IDoc as ISO codes (`PCE`, `KGM`), while the BAPI returns the internal units (`ST`, `KG`).

## References

- [How-to guide: Call RFC Functions and Receive IDocs with SAP ECC](https://wso2.com/integration-platform/docs/integrator/guides/how-to-guides/sap-ecc-rfc-and-idoc-integration)
- [SAP JCo connector](https://wso2.com/integration-platform/docs/integrator/connectors/catalog/erp-business/sap.jco/overview)
- [SAP ECC event integration](https://wso2.com/integration-platform/docs/integrator/develop-and-test/integration-artifacts/event-driven-integration/sap-ecc-events)
