type ShopifyConfig record {
    string apiSecretKey;
};

type SheetConfig record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string spreadsheetId;
};

enum InsertMode {
    APPEND = "APPEND",
    UPSERT = "UPSERT"
}
