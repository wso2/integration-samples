import ballerinax/hubspot.crm.obj.contacts;
import ballerinax/googleapis.sheets;

// Clients are declared here and assigned inside init() below.
// init() returns error?, so any misconfiguration surfaces as a clean error
// message before main() is entered — not as an unhandled mid-flight panic.
contacts:Client hubspotClient;
sheets:Client sheetsClient;

// Module init() — runs before main() and propagates errors cleanly.
// Moving the real `check new` calls here (instead of directly on the
// module-level variable declarations) means:
//   • A failed client init exits with a readable error, not a runtime panic.
//   • main() is never entered when configuration is broken.
function init() returns error? {
    hubspotClient = check new (
        config = {
            auth: {
                token: hubspotAccessToken
            }
        }
    );

    sheetsClient = check new (
        config = {
            auth: {
                clientId: googleClientId,
                clientSecret: googleClientSecret,
                refreshToken: googleRefreshToken,
                refreshUrl: googleRefreshUrl
            }
        }
    );
}
