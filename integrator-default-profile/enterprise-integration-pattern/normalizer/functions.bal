function normalize(string subject, string comment) returns json {
    return {
        ticket: {
            subject,
            comment: {
                body: comment
            }
        }
    };
}
