import ballerinax/mailchimp.marketing;

final marketing:Client marketingClient = check new ({
    auth: {
        username: "mailchimpUsername",
        password: "mailchimpPassword"
    }
});
