
function toMaterialUpdate(MATMAS05 matmas) returns MaterialUpdate => {
    baseUnit: matmas.IDOC.E1MARAM.MEINS,
    netWeight: matmas.IDOC.E1MARAM.NTGEW.trim(),
    material: matmas.IDOC.E1MARAM.MATNR,
    materialGroup: matmas.IDOC.E1MARAM.MATKL,
    materialType: matmas.IDOC.E1MARAM.MTART,
    description: matmas.IDOC.E1MARAM.E1MAKTM[0].MAKTX,
    idocNumber: matmas.IDOC.EDI_DC40.DOCNUM,
    weightUnit: matmas.IDOC.E1MARAM.GEWEI
};
