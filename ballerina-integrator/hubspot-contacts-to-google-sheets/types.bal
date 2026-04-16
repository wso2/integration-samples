// HubSpot Contact Properties
// Fields requested from HubSpot are configurable (see config.bal `fields`).
// We store all fetched properties in an open record so that custom / extra
// fields are never silently discarded.
type ContactProperties record {|
    string?...;
|};

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
