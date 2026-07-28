import ballerina/time;

public type UsersType record {|
    int id;
    string name;
    string mobileNumber;
    time:Date|() birthDate;
|};

type NewPost record {|
    string description;
    string tags;
    string category;
|};

type ErrorMessage record {|
    string msg;
|};

public type UserType record {|
    int id;
|};

type Created record {|
    string msg;
|};
