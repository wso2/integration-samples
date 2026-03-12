A(["Begin"]):::startNode
B["Receive Order Event Through Webhook"]:::processNode
C["Apply Filters"]:::processNode
D{"Is The Sheet <br/> Empty?"}:::decisionNode
E["Initialize Sheet with Headers"]:::processNode
F{"Which <br/> Append Mode?"}:::decisionNode
G["Find Existing Order"]:::processNode
H{"Order <br/> Exists?"}:::decisionNode
I["Update Existing Row(s)"]:::processNode
J["Add New Row(s) to Sheet"]:::processNode
K(["Complete"]):::endNode

A --> B
B --> C
C --> D
D -- Yes --> E
E --> F
D -- No --> F
F -- Upsert --> G
G --> H
F -- Append --> J
H -- Yes --> I
H -- No --> J
I --> K
J --> K