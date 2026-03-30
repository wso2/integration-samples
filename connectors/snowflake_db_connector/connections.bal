import ballerinax/snowflake;

final snowflake:Client snowflakeClient = check new (snowflakeAccountIdentifier, snowflakeUsername, snowflakePassword, {properties: {"db": snowflakeDatabase, "schema": snowflakeSchema, "warehouse": snowflakeWarehouse, "role": snowflakeRole}});
