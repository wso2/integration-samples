function mapShopifyCustomerToSalesforceContact(ShopifyCustomer customer, string? accountId) returns SalesforceContact {
    SalesforceContact contact = {
        LastName: customer.last_name ?: "Unknown",
        Email: customer.email,
        Phone: customer.phone,
        FirstName: customer.first_name,
        AccountId: accountId,
        RecordTypeId: defaultRecordType,
        LeadSource: defaultLeadSource,
        OwnerId: defaultOwnerId
    };
    return contact;
}
