// HubSpot Contact Properties
type ContactProperties record {
    string email?;
    string firstname?;
    string lastname?;
    string phone?;
    string lifecyclestage?;
};

// HubSpot Contact
type Contact record {
    string id;
    ContactProperties properties;
    string createdAt;
    string updatedAt;
    boolean archived;
};

// HubSpot List Contacts Response
type ContactsListResponse record {
    Contact[] results;
    Paging paging?;
};

// Paging information
type Paging record {
    Next next?;
};

type Next record {
    string after;
    string link?;
};
