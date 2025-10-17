import ballerina/ftp;
import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/kafka;
import ballerinax/mysql;

// FTP client configuration
ftp:ClientConfiguration ftpConfig = {
    protocol: ftp:SFTP,
    host: ftpHost,
    port: ftpPort,
    auth: {
        credentials: {
            username: ftpUsername,
            password: ftpPassword
        }
    }
};

// Initialize FTP client 
ftp:Client? ftpClient = ();

// Initialize FTP client 
function initializeFtpClient() returns ftp:Client|error {

    ftp:Client|ftp:Error ftpClientInstance = new (ftpConfig);
    if ftpClientInstance is ftp:Error {
        return error("Failed to initialize FTP client: " + ftpClientInstance.message() +
                    ". Please verify credentials and server connectivity.");
    }

    return ftpClientInstance;
}

// HTTP client configuration for shipment API
http:ClientConfiguration httpConfig = {
    timeout: 30
};

// Initialize HTTP client for shipment API
http:Client shipmentApiClient = check new (shipmentApiBaseUrl, httpConfig);

// MySQL client configuration
mysql:Options mysqlOptions = {
    ssl: {},
    connectTimeout: 30,
    socketTimeout: 0
};

// Initialize MySQL client conditionally
mysql:Client? mysqlClient = ();

// Initialize MySQL client 
function initializeMysqlClient() returns mysql:Client|error {

    mysql:Client|sql:Error mysqlClientInstance = new (
        host = dbHost,
        user = dbUsername,
        password = dbPassword,
        database = dbName,
        port = dbPort,
        options = mysqlOptions
    );

    if mysqlClientInstance is sql:Error {
        string errorMsg = "Failed to initialize MySQL client: " + mysqlClientInstance.message();
        log:printError(errorMsg);
        return error(errorMsg);
    }

    return mysqlClientInstance;
}

// Function to get or reinitialize FTP client
public function getFtpClient() returns ftp:Client|error {
    ftp:Client? currentFtpClient = ftpClient;
    if currentFtpClient is ftp:Client {
        return currentFtpClient;
    }

    // Try to reinitialize if not available
    ftp:Client|error ftpClientInstance = initializeFtpClient();
    if ftpClientInstance is ftp:Client {
        ftpClient = ftpClientInstance;
        return ftpClientInstance;
    }

    return ftpClientInstance;
}

// Function to get or reinitialize MySQL client
public function getMysqlClient() returns mysql:Client|error {
    mysql:Client? currentMysqlClient = mysqlClient;
    if currentMysqlClient is mysql:Client {
        return currentMysqlClient;
    }

    // Try to reinitialize if not available
    mysql:Client|error mysqlClientInstance = initializeMysqlClient();
    if mysqlClientInstance is mysql:Client {
        mysqlClient = mysqlClientInstance;
        return mysqlClientInstance;
    }

    return mysqlClientInstance;
}

final http:Client reportGenerationClient = check new (reportGenerationurl);


// Kafka producer configuration with SSL for Aiven
kafka:ProducerConfiguration producerConfig = {
    securityProtocol: kafka:PROTOCOL_SSL,
    secureSocket: {
        cert: kafkaCaCertPath,
        key: {
            certFile: kafkaClientCertPath,
            keyFile: kafkaClientKeyPath
        },
        protocol: {
            name: "TLS"
        }
    }
};

// Kafka producer for publishing shipment events
kafka:Producer kafkaProducer = check new (
    bootstrapServers = kafkaBootstrapServers,
    securityProtocol = kafka:PROTOCOL_SSL,
    secureSocket = {
        cert: kafkaCaCertPath,
        key: {
            certFile: kafkaClientCertPath,
            keyFile: kafkaClientKeyPath
        },
        protocol: {
            name: "TLS"
        }
    }
);
