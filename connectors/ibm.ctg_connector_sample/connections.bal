import ballerinax/ibm.ctg;

final ctg:Client ctgClient = check new (host = string `${ibmCtgHost}`, port = ibmCtgPort, cicsServer = string `${ibmCtgCicsServer}`, auth = {userId: ibmCtgUserId, password: ibmCtgPassword});
