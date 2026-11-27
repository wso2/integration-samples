import ballerinax/shopify.admin;

final admin:Client shopifyClient = check new ({xShopifyAccessToken: shopifyAccessToken}, shopifyStoreServiceUrl);
