A(["Begin"]):::startNode
B["Apply Filters"]:::processNode
C{"Append Mode?"}:::decisionNode
D["Find Existing Order"]:::processNode
E{"Order <br/> Exists?"}:::decisionNode
F["Update Existing Row(s)"]:::processNode
G["Add New Row(s) to Sheet"]:::processNode
H(["Complete"]):::endNode

A --> B
B --> C

C -- Upsert --> D
D --> E
C -- Append --> G

E -- Yes --> F
E -- No --> G

F --> H
G --> H