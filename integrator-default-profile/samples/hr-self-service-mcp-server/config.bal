// Public base URL of this server (no path), for example https://hr-mcp.example.com
configurable string serverPublicUrl = ?;

// Issuer of the access tokens. Must equal the `iss` claim.
configurable string oauthIssuer = ?;

// JWKS endpoint of the identity provider, used to verify token signatures.
configurable string oauthJwksUrl = ?;

// Audience the access tokens are issued for (the `aud` claim). Use the MCP server URL when the
// provider supports resource indicators, otherwise the API identifier registered at the provider.
configurable string oauthAudience = ?;

// Name of the token claim that carries the scopes ("scope" for most providers, "scp" for some).
configurable string oauthScopeClaim = "scope";

// Name of the token claim that identifies the signed-in user. Matched against employee email or id.
configurable string userClaim = "email";
