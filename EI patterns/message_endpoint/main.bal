import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1/rates on httpListener {
    isolated resource function get covert(Currency base, Currency target, decimal amount = 1.00) returns decimal {
        map<decimal> rates = {
            "AUD": 1.59,
            "INR": 83.24,
            "GBP": 0.83
        };
        decimal baseUsdValue = rates.get(base);
        decimal targetUsdValue = rates.get(target);
        return (targetUsdValue / baseUsdValue) * amount;
    }
}
