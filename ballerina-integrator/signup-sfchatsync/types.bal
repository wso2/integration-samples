import ballerina/constraint;

# User record
# 
# + firstName - Required, max length 40 characters (Salesforce first name field limit)
# + lastName - Required, max length 80 characters (Salesforce last name field limit)
# + email - Required, must match basic email regex pattern
type User record {|
    @constraint:String {
        minLength: 1,
        maxLength: 40
    }
    string firstName;
    @constraint:String {
        minLength: 1,
        maxLength: 80
    }
    string lastName;
    @constraint:String { 
        pattern: re `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
    }
    string email;
|};
