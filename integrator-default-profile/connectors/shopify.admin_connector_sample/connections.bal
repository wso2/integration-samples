import ballerinax/shopify.admin;

final admin:Client adminClient = check new ({xShopifyAccessToken: shopifyAccessToken}, string `${shopifyServiceUrl}`);
