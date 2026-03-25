A(["Begin"]):::startNode
B["Fetch Completed Sprints from Jira"]:::processNode
C{"New Sprint<br/>Found?"}:::decisionNode
D["Generate Summary & Send Email"]:::processNode
E(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D --> E
C -- No --> E





  