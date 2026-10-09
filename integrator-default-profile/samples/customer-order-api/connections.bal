import customer_order_api.dbpersist;

final dbpersist:Client customerDb = check new (dbHost, dbPort, dbUser, dbPassword, dbDatabase);
