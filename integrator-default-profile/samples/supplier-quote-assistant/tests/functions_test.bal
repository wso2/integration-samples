import ballerina/test;

@test:Config
function testQuotationTotal() returns error? {
    Quotation quotation = {
        supplierName: "Supplier A",
        unitPrice: 10.25,
        quantity: 100,
        shippingCharge: 50.50,
        deliveryDate: "2027-06-19"
    };
    QuotationTotal result = check calculateQuotationTotal(quotation);
    test:assertEquals(result.supplierName, "Supplier A");
    test:assertEquals(result.totalCost, 1075.50d);
}

@test:Config
function testBudgetBoundary() returns error? {
    BudgetCheckResult boundary = check checkBudget("Supplier A", 1200.00, 1200.00);
    BudgetCheckResult exceeded = check checkBudget("Supplier A", 1200.01, 1200.00);
    test:assertTrue(boundary.withinBudget);
    test:assertFalse(exceeded.withinBudget);
}

@test:Config
function testInvalidQuotationValues() {
    Quotation base = {
        supplierName: "Supplier A",
        unitPrice: 10.00,
        quantity: 100,
        shippingCharge: 0.00,
        deliveryDate: "2027-06-19"
    };
    foreach int quantity in [0, -1] {
        Quotation invalid = base.clone();
        invalid.quantity = quantity;
        test:assertTrue(calculateQuotationTotal(invalid) is error);
    }
    Quotation negativePrice = base.clone();
    negativePrice.unitPrice = -1.00;
    Quotation negativeShipping = base.clone();
    negativeShipping.shippingCharge = -1.00;
    test:assertTrue(calculateQuotationTotal(negativePrice) is error);
    test:assertTrue(calculateQuotationTotal(negativeShipping) is error);
}

@test:Config
function testNegativeBudgetValues() {
    test:assertTrue(checkBudget("Supplier A", -1.00, 1200.00) is error);
    test:assertTrue(checkBudget("Supplier A", 100.00, -1.00) is error);
}

@test:Config
function testDeadlineBoundary() returns error? {
    DeadlineCheckResult early = check checkDeadline("Supplier A", "2027-06-19", "2027-06-20");
    DeadlineCheckResult onTime = check checkDeadline("Supplier A", "2027-06-20", "2027-06-20");
    DeadlineCheckResult late = check checkDeadline("Supplier A", "2027-06-21", "2027-06-20");
    test:assertTrue(early.meetsDeadline);
    test:assertTrue(onTime.meetsDeadline);
    test:assertFalse(late.meetsDeadline);
}

@test:Config
function testInvalidDates() {
    test:assertTrue(checkDeadline("Supplier A", "not-a-date", "2027-06-20") is error);
    test:assertTrue(checkDeadline("Supplier A", "2027-06-19", "not-a-date") is error);
}
