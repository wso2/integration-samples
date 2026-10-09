function toPatient(PatientReqV1 req) returns Patient => {
    dob: req.dob,
    fullName: req.firstName + " " + req.lastName,
    diagnosis: req.diagnosis
};
