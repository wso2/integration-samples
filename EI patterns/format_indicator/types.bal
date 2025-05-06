type PatientReqV1 record {|
    "1.0" version = "1.0";
    string firstName;
    string lastName;
    string dob;
    string diagnosis;
|};

type PatientReqV2 record {|
    "2.0" version = "2.0";
    Patient patient;
|};

type PatientReq PatientReqV1|PatientReqV2;

type Patient record {|
    string fullName;
    string dob;
    string diagnosis;
|};
