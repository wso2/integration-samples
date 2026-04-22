import ballerina/http;

public function main() returns error? {
    SurveyUpdateRequest message = {
        title: "Customer Satisfaction Survey 2025",
        from_template_id: "customer_satisfaction_template_7",
        footer: true,
        folder_id: "customer_satisfaction",
        theme_id: 789
    };
    http:Response response = check surveyMonkey->/v3/surveys/["1267"].put(message, targetType = http:Response);
}
