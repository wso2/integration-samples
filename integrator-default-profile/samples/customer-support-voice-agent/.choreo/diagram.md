A(["Begin"]):::startNode
B["Receive a customer message by voice or chat"]:::processNode
C["Customer support agent reads the message"]:::processNode
D{"Which request?"}:::decisionNode
E["Look up the order status"]:::processNode
F["Explain the return policy"]:::processNode
G["Create a support ticket"]:::processNode
H["Reply in one or two short sentences"]:::processNode
I(["Complete"]):::endNode

A --> B --> C --> D
D -->|Order status| E --> H
D -->|Returns| F --> H
D -->|Problem to report| G --> H
H --> I
