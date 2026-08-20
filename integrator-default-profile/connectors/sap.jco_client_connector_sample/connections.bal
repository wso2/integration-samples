import ballerinax/sap.jco;

final jco:Client jcoClient = check new (<jco:DestinationConfig>{ashost: sapAshost, sysnr: sapSysnr, jcoClient: sapJcoClientNum, user: sapUsername, passwd: sapPassword});
