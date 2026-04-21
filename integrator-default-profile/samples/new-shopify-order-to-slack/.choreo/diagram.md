A(["Begin"]):::startNode
B["Receive Order Creation Event from Shopify"]:::processNode
C["Send Formatted Message to Slack"]:::processNode
D(["Complete"]):::endNode

A --> B --> C --> D
