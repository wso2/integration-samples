import ballerina/test;

@test:Config
function testOrderLookup() returns error? {
    Order result = check lookupOrder("ORD-1042");
    test:assertEquals(result.itemName, "Wireless Headset");
    test:assertEquals(result.deliveredDaysAgo, 12);
    test:assertTrue(lookupOrder("UNKNOWN") is error);
}

@test:Config
function testReturnWindowBoundary() returns error? {
    EligibilityResult today = check checkReturnWindowEligibility(0);
    EligibilityResult boundary = check checkReturnWindowEligibility(30);
    EligibilityResult expired = check checkReturnWindowEligibility(31);
    test:assertTrue(today.withinReturnWindow);
    test:assertTrue(boundary.withinReturnWindow);
    test:assertFalse(expired.withinReturnWindow);
    test:assertEquals(boundary.returnWindowDays, 30);
}

@test:Config
function testNegativeDeliveryAge() {
    test:assertTrue(checkReturnWindowEligibility(-1) is error);
}

@test:Config
function testReplacementStock() {
    test:assertEquals(checkReplacementStock("Wireless Headset"), 5);
    test:assertEquals(checkReplacementStock("Bluetooth Speaker"), 0);
    test:assertEquals(checkReplacementStock("Unknown Item"), 0);
}
