import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post data/patient(PatientReq patintReq) returns error? {
        Patient patient;
        if patintReq is PatientReqV1 {
            patient = {
                dob: patintReq.dob,
                fullName: patintReq.firstName + " " + patintReq.lastName,
                diagnosis: patintReq.diagnosis
            };
        } else {
            patient = {
                dob: patintReq.patient.dob,
                fullName: patintReq.patient.fullName,
                diagnosis: patintReq.patient.diagnosis
            };
        }
        http:Response response = check patientClient->/patient.post(patient, targetType = http:Response);
    }

    resource function post patient(Patient patient) returns error? {
        http:Response response = check patientClient->/patient.post(patient, targetType = http:Response);
    }
}
