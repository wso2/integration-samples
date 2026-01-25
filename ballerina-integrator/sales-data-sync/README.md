# Sales Data Sync with FTP File Integration

## Description

This integration automates the process of syncing sales data from retail stores to a centralized MySQL database. It monitors an FTP server for incoming JSON sales report files, parses the sales data, and loads each item as a separate row in the database.

## Architecture Overview

Retail stores generate daily sales reports as JSON files and upload them to a central FTP server. Your integration must automatically detect new files, parse the sales data, and insert each item as a separate row in a database.

<img width="1000" height="auto" alt="image" src="resources/architecture.png" />

**Flow:**

1. FTP listener monitors `/sales/new` directory for `.json` files
2. Sales report is parsed and validated
3. Each sale item is inserted as a separate row in MySQL `Sales` table
4. Processed files are moved to `/sales/processed/`
5. If any errors are encountered while processing, files are moved to `/sales/error`

Try this in Devant:

[![Deploy to Devant](https://openindevant.choreoapps.dev/images/DeployDevant.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/ballerina-integrator/sales-data-sync&t=file)


## Prerequisites

- **WSO2 Integrator: BI** - Install from [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=WSO2.ballerina-integrator)
- **Docker** - For running MySQL and FTP server containers
- **MySQL Database** - Local or containerized instance
- **FTP Server** - With read/write access to sales directories

## Set up the environment

### Set up MySQL database

Run the MySQL container:

```bash
docker run -d --name mysql-sales \
  -e MYSQL_ROOT_PASSWORD=root@123 \
  -e MYSQL_DATABASE=sales_db \
  -p 3307:3306 \
  mysql:8.0
```

Verify MySQL is running:

```bash
docker ps
docker logs mysql-sales
```

Connect to MySQL and create the Sales table:

```bash
docker exec -it mysql-sales mysql -uroot -proot@123 sales_db
```

Execute the following SQL:

```sql
CREATE TABLE Sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_id VARCHAR(50) NOT NULL,
    store_location VARCHAR(100) NOT NULL,
    sale_date DATE NOT NULL,
    item_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL
);
```

Type `exit` to close the MySQL connection.

### Set up FTP server

Run the FTP server container:

```bash
docker run -d --name ftp-sales \
  -p 21:21 \
  -e "PUBLICHOST=localhost" \
  -e "FTP_USER_NAME=ftpuser" \
  -e "FTP_USER_PASS=ftppass" \
  -e "FTP_USER_HOME=/home/ftpuser" \
  stilliard/pure-ftpd
```

Create the required directories:

```bash
docker exec ftp-sales mkdir -p /home/ftpuser/sales/new /home/ftpuser/sales/processed /home/ftpuser/sales/error

# Fix permissions for write access
docker exec ftp-sales chmod -R 755 /home/ftpuser/sales
```

Verify the FTP server is accessible:

```bash
docker logs ftp-sales
```
### Add sample data to the FTP server

Create a test file `store42.json`:

```json
{
    "storeId": "STORE-42",
    "storeLocation": "Colombo",
    "saleDate": "2024-01-15",
    "items": [
        {"itemId": "ITEM-001", "quantity": 10, "totalAmount": 250.00},
        {"itemId": "ITEM-002", "quantity": 5, "totalAmount": 175.50},
        {"itemId": "ITEM-003", "quantity": 20, "totalAmount": 890.00}
    ]
}
```

Upload the file to the FTP server:

```bash
docker exec ftp-sales sh -c "cat > /home/ftpuser/sales/new/store42.json << 'EOF'
{
    \"storeId\": \"STORE-42\",
    \"storeLocation\": \"Colombo\",
    \"saleDate\": \"2024-01-15\",
    \"items\": [
        {\"itemId\": \"ITEM-001\", \"quantity\": 10, \"totalAmount\": 250.00},
        {\"itemId\": \"ITEM-002\", \"quantity\": 5, \"totalAmount\": 175.50},
        {\"itemId\": \"ITEM-003\", \"quantity\": 20, \"totalAmount\": 890.00}
    ]
}
EOF"
```

## Running the Sales Data Sync Integration

### Step 1: Open the Integration Project

1. Open VS Code with WSO2 Integrator: BI installed
2. Click on the BI icon on the sidebar
3. Open the `sales-data-sync` project

### Step 2: Configure Variables

1. Open the **Configurations** section from the left panel
2. Add values to all configurable fields:

| Field | Value |
|-------|-------|
| `ftpHost` | `localhost` |
| `ftpPort` | `21` |
| `ftpUsername` | `ftpuser` |
| `ftpPassword` | `ftppass` |
| `mysqlHost` | `localhost` |
| `mysqlPort` | `3307` |
| `mysqlUsername` | `root` |
| `mysqlPassword` | `root@123` |

### Step 3: Run the Integration

1. Click the **Run** button in the BI extension
2. Wait for the integration to start (you'll see logs in the output panel)

**Expected Results:**

1. Check the BI logs - you should see:
   - `Processing file from store STORE-42`
   - `File moved to processed: store.json`

2. Verify data in MySQL:

```bash
docker exec -it mysql-sales mysql -uroot -proot@123 sales_db -e "SELECT * FROM Sales;"
```

You should see 3 rows inserted, one for each item in the sales report.

3. Verify file was moved to processed folder:

```bash
ftp localhost 21
# Username: ftpuser
# Password: ftppass

ls sales/new
# Should be empty

ls sales/processed
# Should contain store42-2024-01-15.json

bye
```

## Deploy on Devant

1. Deploy this integration on **Devant** as a **File Integration**
2. Configure the FTP and MySQL connection parameters with your production values
