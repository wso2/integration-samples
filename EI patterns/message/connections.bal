import ballerina/http;

final http:Client surveyMonkey = check new ("http://api.surveymonkey.com/v3/surveys");
