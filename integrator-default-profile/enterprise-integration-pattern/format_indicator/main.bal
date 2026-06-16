import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post data/patient(PatientReq patientReq) returns error? {
        Patient patient;
        if patientReq is PatientReqV1 {
            patient = toPatient(patientReq);
        } else {
            patient = {
                dob: patientReq.patient.dob,
                fullName: patientReq.patient.fullName,
                diagnosis: patientReq.patient.diagnosis
            };
        }
        http:Response response = check patientClient->/patient.post(patient, targetType = http:Response);
    }

    resource function post patient(Patient patient) returns error? {
        http:Response response = check patientClient->/patient.post(patient, targetType = http:Response);
    }
}
