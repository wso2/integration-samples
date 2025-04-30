
type IncidentRequest record {
    string phoneNo;
    Incident incident;
};

type Incident record {|
    string description;
    string date;
    string time;
|};
