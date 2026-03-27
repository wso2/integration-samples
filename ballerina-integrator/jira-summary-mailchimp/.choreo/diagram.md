A(["Begin"]):::startNode
B["Fetch Issues from Jira"]:::processNode
C{"Are there <br/> Issues?"}:::decisionNode
D["Populate Issues"]:::processNode
E["Send Email via Mailchimp"]:::processNode
F(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D --> E --> F
C -- No --> F
