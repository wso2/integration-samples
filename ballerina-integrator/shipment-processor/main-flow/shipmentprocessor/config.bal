// HTTP service configuration
configurable int httpPort = 8080;

// FTP configuration
configurable string ftpHost = ?;
configurable int ftpPort = 22;
configurable string ftpUsername = ?;
// Store password as raw string - let the FTP client handle encoding
configurable string ftpPassword = ?;
configurable string ftpDirectory = ?;

// FTP Listener configuration for file polling
configurable decimal ftpListenerPollingInterval = 30; // seconds
configurable string ftpListenerFilePattern = ".*_shipments\\.csv$"; // regex pattern for files to process

// File renaming configuration after processing
configurable string processedFilePrefix = "processed_";
configurable string processedFileDirectory = ?;

// Processing configuration
configurable int batchSize = 1000;
configurable int maxRetryAttempts = 2; //Shipment API
configurable int retryDelaySeconds = 5;

// Database batch processing configuration
configurable int maxDatabaseBatchSize = 50; // Process max N records at a time for database operations

// File processing optimization
configurable boolean enableFileTrackingOptimization = true; // Skip already processed files during polling

// API configuration                     
configurable string shipmentApiBaseUrl = ?;
// NDJSON output configuration
configurable boolean enableNdjsonOutput = true;
configurable string ndjsonOutputDirectory = ?;
configurable string ndjsonFilePrefix = "enriched_";
configurable string ndjsonFileExtension = ".ndjson";

// MySQL database configurations
configurable boolean enableDatabaseStorage = true;
configurable string dbHost = ?;
configurable int dbPort = 24547;
configurable string dbName = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
//log configuration
configurable boolean enableEnrichResponseLogging = true;

// Kafka configuration
configurable string kafkaBootstrapServers = ?;
configurable string kafkaTopic = "shipments-received-v1";
configurable string reportGenerationurl = ?;

configurable string kafkaCaCertPath = ?;
configurable string kafkaClientCertPath = ?;
configurable string kafkaClientKeyPath = ?;
configurable int kafkaEventPublishCount = 1;
