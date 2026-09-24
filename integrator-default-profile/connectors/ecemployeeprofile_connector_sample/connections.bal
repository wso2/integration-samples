import ballerinax/sap.successfactors.ecemployeeprofile;

final ecemployeeprofile:Client ecemployeeprofileClient = check new ({auth: {username: userName, password: password}}, hostname);
