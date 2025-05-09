import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post survey/[string id](@http:Header string userId, @http:Payload json formData) returns error? {
        map<json[]> partialSurveys = {};
        json[]|() surveyData = partialSurveys[userId];
        if surveyData == () {
            json[] newSurvey = [formData];
            partialSurveys[userId] = newSurvey;
        } else {
            () var1 = surveyData.push(formData);
            if surveyData.length() == 3 {
                http:Response response = check formSubmitClient->/survey/[id]/submit.post({userId: surveyData}, targetType = http:Response);
                json[] remove = partialSurveys.remove(userId);
            }
        }
    }
}
