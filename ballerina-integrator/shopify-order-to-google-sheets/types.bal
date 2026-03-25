type ShopifyConfig record {
    # Secret used to sign webhook requests by Shopify
    string webhookSecret;
};

type SheetConfig record {
    # Google OAuth2 client ID for Sheets API access
    string clientID;
    # Google OAuth2 client secret for Sheets API access
    string clientSecret;
    # Google OAuth2 refresh token for Sheets API access
    string refreshToken;
    # Google sheet ID
    string sheetID;
};

enum InsertMode {
    APPEND = "append",
    UPSERT = "upsert"
}
