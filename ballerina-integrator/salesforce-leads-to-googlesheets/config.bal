// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// Salesforce OAuth Configuration
configurable string salesforceRefreshToken = ?;
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceRefreshUrl = ?;
configurable string salesforceBaseUrl = ?;

// Google OAuth Configuration
configurable string googleRefreshToken = ?;
configurable string googleClientId = ?;
configurable string googleClientSecret = ?;

configurable string timezone = "UTC";
configurable string spreadsheetId = "";
configurable string tabName = "Leads";

configurable string[] fieldMapping = [
    "Id",
    "FirstName",
    "LastName",
    "Email",
    "Phone",
    "Company",
    "Title",
    "Status",
    "LeadSource",
    "Industry",
    "Rating",
    "CreatedDate",
    "LastModifiedDate"
];

configurable string soqlFilter = "";
configurable string timeframe = "ALL";
configurable boolean includeConverted = false;

configurable string syncMode = "APPEND";
configurable boolean enableAutoFormat = true;
configurable string splitBy = "";
