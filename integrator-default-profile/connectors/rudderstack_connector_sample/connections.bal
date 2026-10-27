import ballerinax/rudderstack;

final rudderstack:Client rudderstackClient = check new ({auth: {writeKey: rudderstackWriteKey}}, string `${rudderstackDataPlaneUrl}`);
