import ballerina/http;

listener http:Listener httpListener = new (9000);

service /text\-processing on httpListener {
    resource function post api/sentiment(@http:Payload Post post) returns Sentiment|error {
        do {
            Probability probability = {
                "neg": 0.30135019761690551,
                "neutral": 0.27119050546800266,
                "pos": 0.69864980238309449
            };
            Sentiment sentiment = {
                probability: probability,
                label: "pos"
            };
            return sentiment;
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
