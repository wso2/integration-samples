    Start([Start]):::startNode --> Poll[Poll Jira API<br/>closedSprints]:::processNode
    Poll --> Detect[Detect New<br/>Completed Sprints]:::processNode
    Detect --> Generate[Fetch Issues &<br/>Generate Summary]:::processNode
    Generate --> Format[Format HTML<br/>Email]:::processNode
    Format --> Send[Send via Gmail<br/>to Recipients]:::processNode
    Send --> End([End]):::endNode
    classDef startNode fill:#90EE90,stroke:#333,stroke-width:2px,color:#000
    classDef processNode fill:#87CEEB,stroke:#333,stroke-width:2px,color:#000
    classDef endNode fill:#F08080,stroke:#333,stroke-width:2px,color:#000




  