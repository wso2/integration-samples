
type ProjectRequest record {|
    string projectName;
    string description;
    string customerName;
|};

type Project record {|
    string projectID;
    Task[] tasks;
    string projectName;
    string description;
    string customerName;
|};

type Task record {|
    string taskID;
    string description;
|};
