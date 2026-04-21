// Kafka configuration
configurable string kafkaBootstrapServers = ?;
configurable string kafkaTopic = "shipments-received-v1";

// Kafka SSL configuration - Add paths to your certificate files
configurable string kafkaCaCertPath = ?;
configurable string kafkaClientCertPath = ?;
configurable string kafkaClientKeyPath = ?;

// Email configuration
configurable string smtpHost = "smtp.gmail.com";
configurable string smtpUsername = ?;
configurable string smtpPassword = ?;
configurable int smtpPort = 587;
