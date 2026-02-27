A(["Begin"]):::startNode
B[/"Receive REST API Call"/]:::inputNode
C["Create Salesforce Contact"]:::processNode
D["Notify on Google Chat"]:::processNode
E(["Complete"]):::endNode

A --> B --> C --> D --> E