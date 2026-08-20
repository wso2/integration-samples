import ballerina/smb;

final smb:Client smbClient = check new ({host: smbHost, share: smbShare, auth: {credentials: {username: smbUsername, password: smbPassword}}});
