// Map QuickBooks Customer to Salesforce Account
public isolated function mapQuickBooksCustomerToSalesforceAccount(QuickBooksCustomer qbCustomer) returns SalesforceAccount {
    
    // Build billing address
    // Note: State and Country are appended to the street address to avoid Salesforce State/Country Picklist validation errors
    string? billingStreet = ();
    string? billingCity = ();
    string? billingPostalCode = ();
    
    BillAddr? billAddr = qbCustomer?.BillAddr;
    if billAddr is BillAddr {
        // Combine Line1 and Line2 for street address
        string? line1 = billAddr?.Line1;
        string? line2 = billAddr?.Line2;
        string? state = billAddr?.CountrySubDivisionCode;
        string? country = billAddr?.Country;
        
        string[] addressParts = [];
        
        if line1 is string {
            addressParts.push(line1);
        }
        if line2 is string {
            addressParts.push(line2);
        }
        if state is string {
            addressParts.push(state);
        }
        if country is string {
            addressParts.push(country);
        }
        
        if addressParts.length() > 0 {
            billingStreet = string:'join("\n", ...addressParts);
        }
        
        billingCity = billAddr?.City;
        billingPostalCode = billAddr?.PostalCode;
    }
    
    // Build shipping address
    // Note: State and Country are appended to the street address to avoid Salesforce State/Country Picklist validation errors
    string? shippingStreet = ();
    string? shippingCity = ();
    string? shippingPostalCode = ();
    
    ShipAddr? shipAddr = qbCustomer?.ShipAddr;
    if shipAddr is ShipAddr {
        // Combine Line1, Line2, State, and Country for street address
        string? line1 = shipAddr?.Line1;
        string? line2 = shipAddr?.Line2;
        string? state = shipAddr?.CountrySubDivisionCode;
        string? country = shipAddr?.Country;
        
        string[] addressParts = [];
        
        if line1 is string {
            addressParts.push(line1);
        }
        if line2 is string {
            addressParts.push(line2);
        }
        if state is string {
            addressParts.push(state);
        }
        if country is string {
            addressParts.push(country);
        }
        
        if addressParts.length() > 0 {
            shippingStreet = string:'join("\n", ...addressParts);
        }
        
        shippingCity = shipAddr?.City;
        shippingPostalCode = shipAddr?.PostalCode;
    }
    
    // Extract phone
    string? phone = ();
    PrimaryPhone? primaryPhone = qbCustomer?.PrimaryPhone;
    if primaryPhone is PrimaryPhone {
        phone = primaryPhone?.FreeFormNumber;
    }
    
    // Extract fax
    string? fax = ();
    FaxPhone? faxPhone = qbCustomer?.Fax;
    if faxPhone is FaxPhone {
        fax = faxPhone?.FreeFormNumber;
    }
    
    // Extract website
    string? website = ();
    WebAddress? webAddr = qbCustomer?.WebAddr;
    if webAddr is WebAddress {
        website = webAddr?.URI;
    }
    
    // Build description with QuickBooks attribution
    string? description = ();
    string? notes = qbCustomer?.Notes;
    if notes is string {
        description = notes + "\n\nCreated by QuickBooks";
    } else {
        description = "Created by QuickBooks";
    }
    
    // Map to Salesforce Account
    SalesforceAccount sfAccount = {
        Name: qbCustomer.DisplayName,
        Site: qbCustomer?.CompanyName,
        Phone: phone,
        Fax: fax,
        Website: website,
        BillingStreet: billingStreet,
        BillingCity: billingCity,
        BillingPostalCode: billingPostalCode,
        ShippingStreet: shippingStreet,
        ShippingCity: shippingCity,
        ShippingPostalCode: shippingPostalCode,
        Description: description,
        Type: qbCustomer?.CustomerType,
        QuickbooksSync__c: qbCustomer.Id
    };
    
    return sfAccount;
}

// Map QuickBooks Customer to Salesforce Contact
public isolated function mapQuickBooksCustomerToSalesforceContact(QuickBooksCustomer qbCustomer, string accountId) returns SalesforceContact? {
    
    string? givenName = qbCustomer?.GivenName;
    string? familyName = qbCustomer?.FamilyName;
    
    // Extract email
    string? email = ();
    EmailAddress? emailAddr = qbCustomer?.PrimaryEmailAddr;
    if emailAddr is EmailAddress {
        email = emailAddr?.Address;
    }
    
    // Only create contact if we have at least a last name
    if familyName is () {
        return ();
    }
    
    // Extract phone
    string? phone = ();
    PrimaryPhone? primaryPhone = qbCustomer?.PrimaryPhone;
    if primaryPhone is PrimaryPhone {
        phone = primaryPhone?.FreeFormNumber;
    }
    
    SalesforceContact sfContact = {
        FirstName: givenName,
        LastName: familyName,
        Email: email,
        Phone: phone,
        AccountId: accountId
    };
    
    return sfContact;
}
