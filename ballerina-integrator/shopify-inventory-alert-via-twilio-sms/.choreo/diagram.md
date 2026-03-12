    S([Start]):::startNode
    S --> WEBHOOK[Receive Shopify Order Webhook]:::processNode
    WEBHOOK --> CHECK{Inventory Below Threshold?}:::decisionNode
    CHECK -- No --> E([End]):::endNode
    CHECK -- Yes --> COOLDOWN{Cooldown Expired?}:::decisionNode
    COOLDOWN -- No --> E
    COOLDOWN -- Yes --> SEND[Send SMS Alert via Twilio]:::processNode
    SEND --> E
