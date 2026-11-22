import ballerina/ai;
import ballerina/time;

final readonly & KbArticle[] kbArticles = [
    {
        id: "vpn-setup",
        title: "Connect to the Acme VPN",
        body: "Install the Acme VPN client from the Self Service portal. Open it, enter vpn.acme.com as the server and sign in with your Acme email and password. Approve the multi-factor prompt on your phone. If the connection drops, quit the client, check your internet connection and reconnect. If the problem continues, raise an incident ticket."
    },
    {
        id: "wifi-setup",
        title: "Connect to office Wi-Fi",
        body: "Employees use the Acme-Secure network and guests use Acme-Guest. To join Acme-Secure, choose it from the Wi-Fi list and sign in with your Acme email and password. Forget the network and rejoin if you changed your password recently. Guest passwords are available from the front desk and change every Monday."
    },
    {
        id: "email-mobile",
        title: "Set up Acme email on a mobile phone",
        body: "Install the Microsoft Outlook app from the App Store or Google Play. Tap Add Account, enter your Acme email address and sign in with your Acme password. Approve the multi-factor prompt and accept the device management policy. Native mail apps are not supported. If sign-in fails, make sure your account is not locked."
    },
    {
        id: "printer-setup",
        title: "Add and use office printers",
        body: "Printers are named after their floor, for example Floor2-Color. On Windows open Settings, Printers and scanners, Add device and choose the printer. On Mac open System Settings, Printers and scanners, and add it by name. Release print jobs at the device by tapping your badge. If a job is stuck, cancel it and print again."
    },
    {
        id: "new-laptop",
        title: "Request a new laptop",
        body: "Laptops are replaced every four years. New hires receive a laptop before their start date. To request a new or replacement laptop, your manager must approve the request. After approval the request is fulfilled within five working days. Broken or lost laptops should be reported immediately through an incident ticket."
    },
    {
        id: "password-rules",
        title: "Password rules",
        body: "Passwords must have at least 14 characters and include upper case letters, lower case letters, a number and a symbol. You cannot reuse your last 12 passwords. Passwords expire every 180 days. Accounts lock after five failed sign-in attempts. A locked account can be unlocked by the IT helpdesk after you confirm your employee ID."
    },
    {
        id: "mfa-setup",
        title: "Set up multi-factor authentication",
        body: "Install Microsoft Authenticator on your phone. Sign in to the security info page with your Acme account, choose Add method and scan the QR code. Keep notifications turned on. If you get a new phone, set up the app again before you reset the old one. If you lost your phone, raise an incident ticket."
    },
    {
        id: "software-access",
        title: "App access policy",
        body: "Standard apps are Slack, Zoom, Jira and Confluence, and access is granted immediately on request. Sensitive apps are Salesforce, the AWS console and Payroll. Access to these needs approval from your manager. Access is granted as soon as it is approved."
    }
];

const int maxFailedIdChecks = 3;
const decimal idLockoutSeconds = 900;

// In production, replace this store with Microsoft Entra ID (Microsoft Graph users API).
isolated map<Employee> directory = {
    "alice.johnson@acme.com": {
        email: "alice.johnson@acme.com",
        name: "Alice Johnson",
        employeeId: "E1001",
        department: "Engineering",
        managerEmail: "bob.smith@acme.com",
        status: "Active",
        apps: ["Slack", "Zoom", "Jira", "Confluence"]
    },
    "bob.smith@acme.com": {
        email: "bob.smith@acme.com",
        name: "Bob Smith",
        employeeId: "E1002",
        department: "Engineering",
        managerEmail: "grace.hall@acme.com",
        status: "Active",
        apps: ["Slack", "Zoom", "Jira", "Confluence", "AWS console"]
    },
    "carol.davis@acme.com": {
        email: "carol.davis@acme.com",
        name: "Carol Davis",
        employeeId: "E1003",
        department: "Sales",
        managerEmail: "grace.hall@acme.com",
        status: "Active",
        apps: ["Slack", "Zoom", "Salesforce"]
    },
    "david.lee@acme.com": {
        email: "david.lee@acme.com",
        name: "David Lee",
        employeeId: "E1004",
        department: "Finance",
        managerEmail: "emma.wilson@acme.com",
        status: "Locked",
        apps: ["Slack", "Payroll"]
    },
    "emma.wilson@acme.com": {
        email: "emma.wilson@acme.com",
        name: "Emma Wilson",
        employeeId: "E1005",
        department: "Finance",
        managerEmail: "grace.hall@acme.com",
        status: "Active",
        apps: ["Slack", "Zoom", "Confluence", "Payroll"]
    }
};

// In production, replace this store with ServiceNow requests or Microsoft Entra ID entitlement management.
isolated map<AccessRequest> accessRequests = {};

// In production, replace this store with ServiceNow incidents (Table API).
isolated map<Ticket> tickets = {
    "INC10001": {
        ticketId: "INC10001",
        employeeEmail: "alice.johnson@acme.com",
        category: "Hardware",
        priority: "Medium",
        summary: "Laptop battery drains within one hour. Tried power settings and a different charger.",
        status: "In Progress",
        createdAt: "2026-11-10T09:15:00Z",
        updatedAt: "2026-11-11T14:02:00Z"
    },
    "INC10002": {
        ticketId: "INC10002",
        employeeEmail: "carol.davis@acme.com",
        category: "Network",
        priority: "Medium",
        summary: "VPN disconnects every few minutes from home. Tried reconnecting and switching Wi-Fi networks.",
        status: "Open",
        createdAt: "2026-11-12T16:40:00Z",
        updatedAt: "2026-11-12T16:40:00Z"
    }
};

// In production, replace this store with a shared cache such as Redis, or the identity provider's own throttling.
isolated map<IdCheckFailures> failedIdChecks = {};

function ingestKnowledgeBase() returns error? {
    ai:TextDocument[] documents = [];
    foreach KbArticle article in kbArticles {
        ai:TextDocument document = {
            'type: "text",
            content: string `# ${article.title}

${article.body}`,
            metadata: {fileName: string `${article.id}.md`, mimeType: "text/markdown", "title": article.title}
        };
        documents.push(document);
    }
    check helpdeskKnowledgeBase.ingest(documents);
}

isolated function nowString() returns string {
    return time:utcToString(time:utcNow());
}

isolated function normalizeEmail(string email) returns string {
    return email.trim().toLowerAscii();
}

isolated function isSensitiveApp(App app) returns boolean {
    return app == "Salesforce" || app == "AWS console" || app == "Payroll";
}

isolated function toProfile(Employee employee) returns EmployeeProfile {
    return {
        email: employee.email,
        name: employee.name,
        department: employee.department,
        status: employee.status,
        apps: employee.apps.clone()
    };
}

isolated function toAccessRequestView(AccessRequest request) returns AccessRequestView {
    AccessRequestView view = {
        requestId: request.requestId,
        employeeEmail: request.employeeEmail,
        app: request.app,
        status: request.status,
        requestedAt: request.requestedAt
    };
    string? decidedAt = request.decidedAt;
    if decidedAt is string {
        view.decidedAt = decidedAt;
    }
    string? comment = request.comment;
    if comment is string {
        view.comment = comment;
    }
    return view;
}

isolated function findEmployee(string email) returns Employee? {
    string key = normalizeEmail(email);
    lock {
        Employee? employee = directory[key];
        if employee is Employee {
            return employee.clone();
        }
    }
    return ();
}

isolated function setEmployeeStatus(string email, AccountStatus status) {
    string key = normalizeEmail(email);
    lock {
        Employee? employee = directory[key];
        if employee is Employee {
            employee.status = status;
        }
    }
}

isolated function verifyEmployeeId(string email, string expectedId, string givenId) returns IdCheckResult {
    string key = normalizeEmail(email);
    time:Utc now = time:utcNow();
    lock {
        IdCheckFailures? failures = failedIdChecks[key];
        time:Utc[] recent = [];
        if failures is IdCheckFailures {
            time:Utc[] previous = failures.failedAt;
            int previousCount = previous.length();
            if previousCount >= maxFailedIdChecks {
                time:Utc lastFailure = previous[previousCount - 1];
                decimal elapsed = time:utcDiffSeconds(now, lastFailure);
                if elapsed < idLockoutSeconds {
                    return "LOCKED_OUT";
                }
            }
            foreach time:Utc failedAt in previous {
                decimal age = time:utcDiffSeconds(now, failedAt);
                if age < idLockoutSeconds {
                    recent.push(failedAt.clone());
                }
            }
        }
        if expectedId == givenId.trim().toUpperAscii() {
            _ = failedIdChecks.removeIfHasKey(key);
            return "MATCH";
        }
        recent.push(now);
        failedIdChecks[key] = {failedAt: recent};
        if recent.length() >= maxFailedIdChecks {
            return "LOCKED_OUT";
        }
        return "MISMATCH";
    }
}

isolated function grantAppAccess(string email, App app) {
    string key = normalizeEmail(email);
    lock {
        Employee? employee = directory[key];
        if employee is Employee {
            int? existing = employee.apps.indexOf(app);
            if existing is () {
                employee.apps.push(app);
            }
        }
    }
}

isolated function createAccessRequest(string email, App app, string managerEmail) returns AccessRequest {
    string key = normalizeEmail(email);
    lock {
        foreach AccessRequest existing in accessRequests {
            if existing.employeeEmail == key && existing.app == app && existing.status == "PENDING" {
                return existing.clone();
            }
        }
        string requestId = string `AR-${1001 + accessRequests.length()}`;
        AccessRequest request = {
            requestId,
            employeeEmail: key,
            app,
            managerEmail,
            status: "PENDING",
            requestedAt: nowString()
        };
        accessRequests[requestId] = request;
        return request.clone();
    }
}

isolated function findAccessRequest(string requestId) returns AccessRequest? {
    string key = requestId.trim().toUpperAscii();
    lock {
        AccessRequest? request = accessRequests[key];
        if request is AccessRequest {
            return request.clone();
        }
    }
    return ();
}

isolated function decideAccessRequest(string requestId, string managerEmail, boolean approve, string? comment)
        returns AccessRequest|NotFoundError|ForbiddenError|ConflictError {
    string key = requestId.trim().toUpperAscii();
    AccessRequest decided;
    lock {
        AccessRequest? request = accessRequests[key];
        if request is () {
            return error NotFoundError(string `Access request ${key} was not found.`);
        }
        if normalizeEmail(managerEmail) != normalizeEmail(request.managerEmail) {
            return error ForbiddenError(string `Only the employee's manager can decide access request ${key}.`);
        }
        if request.status != "PENDING" {
            return error ConflictError(string `Access request ${key} was already ${request.status}.`);
        }
        request.status = approve ? "APPROVED" : "REJECTED";
        request.decidedAt = nowString();
        if comment is string {
            request.comment = comment;
        }
        decided = request.clone();
    }
    if approve {
        grantAppAccess(decided.employeeEmail, decided.app);
    }
    return decided;
}

isolated function createTicket(string email, TicketCategory category, TicketPriority priority, string summary)
        returns Ticket {
    string key = normalizeEmail(email);
    string timestamp = nowString();
    lock {
        string ticketId = string `INC${10001 + tickets.length()}`;
        Ticket ticket = {
            ticketId,
            employeeEmail: key,
            category,
            priority,
            summary,
            status: "Open",
            createdAt: timestamp,
            updatedAt: timestamp
        };
        tickets[ticketId] = ticket;
        return ticket.clone();
    }
}

isolated function findTicket(string ticketId) returns Ticket? {
    string key = ticketId.trim().toUpperAscii();
    lock {
        Ticket? ticket = tickets[key];
        if ticket is Ticket {
            return ticket.clone();
        }
    }
    return ();
}

isolated function findTicketsByEmployee(string email) returns Ticket[] {
    string key = normalizeEmail(email);
    lock {
        Ticket[] found = from Ticket ticket in tickets
            where ticket.employeeEmail == key
            select ticket;
        return found.clone();
    }
}
