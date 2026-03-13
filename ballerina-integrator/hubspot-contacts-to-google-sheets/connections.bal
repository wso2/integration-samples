import ballerinax/hubspot.crm.obj.contacts;
import ballerinax/googleapis.sheets;

// Clients are declared without `final` so they can be re-assigned inside
// init() below.  The placeholder values use empty credentials; HTTP client
// constructors do not make network calls at construction time and will not
// fail here.  All real credential assignment happens inside init() which
// returns error?, so any misconfiguration surfaces as a clean error message
// before main() is entered — not as an unhandled mid-flight panic.
contacts:Client hubspotClient = check new (config = {auth: {token: ""}});
sheets:Client sheetsClient = check new (config = {
    auth: {
        token: ""
    }
});

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
