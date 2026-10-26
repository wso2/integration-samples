import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

@sql:Name {value: "users"}
public type User record {|
    @sql:Generated
    readonly int id;
    @sql:Varchar {length: 255}
    string name;
    @sql:Name {value: "mobile_number"}
    @sql:Varchar {length: 15}
    string mobileNumber;
    @sql:Name {value: "birth_date"}
    time:Date? birthDate;
    Follower[] followers;
    Follower[] followers1;
    Post[] posts;
|};

@sql:Name {value: "posts"}
public type Post record {|
    @sql:Generated
    readonly int id;
    @sql:Varchar {length: 255}
    string description;
    @sql:Varchar {length: 255}
    string? category;
    @sql:Varchar {length: 255}
    string? tags;
    @sql:Name {value: "created_date"}
    time:Date? createdDate;
    @sql:Name {value: "user_id"}
    @sql:Index {name: "user_id"}
    int userId;
    @sql:Relation {keys: ["userId"]}
    User user;
|};

@sql:Name {value: "followers"}
public type Follower record {|
    @sql:Generated
    readonly int id;
    @sql:Name {value: "leader_id"}
    @sql:UniqueIndex {name: "leader_id"}
    int leaderId;
    @sql:Name {value: "follower_id"}
    @sql:Index {name: "follower_id"}
    @sql:UniqueIndex {name: "leader_id"}
    int followerId;
    @sql:Name {value: "created_date"}
    time:Date? createdDate;
    @sql:Relation {keys: ["leaderId"]}
    User user;
    @sql:Relation {keys: ["followerId"]}
    User user1;
|};
