import ballerinax/aws.redshift;

final redshift:Client redshiftClient = check new (string `${jdbcUrl}`, string `${dbUser}`, string `${dbPassword}`);
