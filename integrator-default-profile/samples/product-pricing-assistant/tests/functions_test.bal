import ballerina/test;

@test:Config
function testPlanPrice() returns error? {
    decimal price = check lookupPlanPrice("Business");
    test:assertEquals(price, 12.00d);
    test:assertTrue(lookupPlanPrice("Unknown Plan") is error);
}

@test:Config
function testPlanQuote() returns error? {
    PriceQuote quote = check calculatePlanQuote("Business", 25);
    test:assertEquals(quote.planName, "Business");
    test:assertEquals(quote.pricePerUserPerMonth, 12.00d);
    test:assertEquals(quote.userCount, 25);
    test:assertEquals(quote.totalPricePerMonth, 300.00d);
}

@test:Config
function testInvalidUserCount() {
    test:assertTrue(calculatePlanQuote("Business", 0) is error);
    test:assertTrue(calculatePlanQuote("Business", -1) is error);
}

@test:Config
function testUnknownPlanQuote() {
    test:assertTrue(calculatePlanQuote("Unknown Plan", 25) is error);
}
