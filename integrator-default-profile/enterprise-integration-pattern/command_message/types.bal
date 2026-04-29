type UserGroupCreateRequest record {|
    string name;
    string description;
    string team_id;
|};

type UserGroup record {
    string id;
    boolean is_usergroup;
    string 'handle;
    boolean is_external;
    int date_create;
    string created_by;
    string user_count;
    string name;
    string description;
    string team_id;
};

type UserGroupCreationResponse record {
    boolean ok;
    UserGroup usergroup?;
    string 'error?;
};
