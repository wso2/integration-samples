import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerina/time;

public function main() returns error? {
    do {
        stream<record {}, error?> sfStream = check salesforceClient->query("SELECT Email, FirstName, LastName, Phone, MailingStreet FROM Contact WHERE Email != null");
        map<Customer> sfCustomers = {};
        check from record {} rec in sfStream
            do {
                string email = (rec["Email"]).toString().toLowerAscii();
                sfCustomers[email] = {
                    email,
                    firstName: (rec["FirstName"]).toString(),
                    lastName: (rec["LastName"]).toString(),
                    phone: (rec["Phone"]).toString(),
                    address: (rec["MailingStreet"]).toString()
                };
            };
        stream<Customer, sql:Error?> pgStream = postgresqlClient->query(
            `SELECT email, first_name AS firstName, last_name AS lastName, phone, address
                FROM customers`
        );
        map<Customer> pgCustomers = {};
        check from Customer c in pgStream
            do {
                pgCustomers[c.email.toLowerAscii()] = c;
            };
        Discrepancy[] discrepancies = [];

        foreach [string, Customer] [email, sfCustomer] in sfCustomers.entries() {
            Customer? pg = pgCustomers[email];
            if pg is () {
                discrepancies.push({email, discrepancyType: "missing_in_db", fieldMismatches: []});
                continue;
            } else {
                FieldMismatch[] mismatches = [];
                if sfCustomer.firstName != pg.firstName {
                    mismatches.push({fieldName: "firstName", salesforceValue: sfCustomer.firstName, databaseValue: pg.firstName});
                }
                if sfCustomer.lastName != pg.lastName {
                    mismatches.push({fieldName: "lastName", salesforceValue: sfCustomer.lastName, databaseValue: pg.lastName});
                }
                if sfCustomer.phone != pg.phone {
                    mismatches.push({fieldName: "phone", salesforceValue: sfCustomer.phone, databaseValue: pg.phone});
                }
                if sfCustomer.address != pg.address {
                    mismatches.push({fieldName: "address", salesforceValue: sfCustomer.address, databaseValue: pg.address});
                }
                if mismatches.length() > 0 {
                    discrepancies.push({email, discrepancyType: "field_mismatch", fieldMismatches: mismatches});
                }
            }

        }
        foreach string pgEmail in pgCustomers.keys() {
            if !sfCustomers.hasKey(pgEmail) {
                discrepancies.push({email: pgEmail, discrepancyType: "missing_in_sf", fieldMismatches: []});
            }
        }
        int missingInDb = discrepancies.filter(d => d.discrepancyType == "missing_in_db").length();
        int missingInSf = discrepancies.filter(d => d.discrepancyType == "missing_in_sf").length();

        int fieldMismatchCount = discrepancies.filter(d => d.discrepancyType == "field_mismatch").length();
        time:Utc generatedAt = time:utcNow();
        ReconciliationReport report = {
            generatedAt: time:utcToString(generatedAt),
            totalSalesforceRecords: sfCustomers.length(),
            totalDatabaseRecords: pgCustomers.length(),
            matchedRecords: sfCustomers.length() - missingInDb - fieldMismatchCount,
            mismatchedRecords: fieldMismatchCount,
            missingInDatabase: missingInDb,
            missingInSalesforce: missingInSf,
            discrepancies: discrepancies
        };
        string fileName = string `./reports/reconciliation-${time:utcToString(generatedAt)}.json`;
        check io:fileWriteJson(string `${fileName}`, report);
        log:printInfo("Reconciliation complete", matched = report.matchedRecords, mismatched = report.mismatchedRecords, missingInDb = report.missingInDatabase, missingInSf = report.missingInSalesforce);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
