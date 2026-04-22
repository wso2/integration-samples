import ballerinax/microsoft.onedrive;

final onedrive:Client onedriveClient = check new ({auth: {token: oneDriveToken}});
