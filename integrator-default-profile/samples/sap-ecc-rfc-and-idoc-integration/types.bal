import ballerina/data.xmldata;

type EDI_DC40 record {
    string DOCNUM;
    string IDOCTYP;
    string MESTYP;
    string SNDPRN;
    @xmldata:Attribute
    string SEGMENT;
};

type E1MAKTM record {
    string SPRAS_ISO;
    string MAKTX;
    @xmldata:Attribute
    string SEGMENT;
};

type E1MARAM record {
    string MATNR;
    string MTART;
    string MATKL;
    string MEINS;
    string NTGEW;
    string GEWEI;
    E1MAKTM[] E1MAKTM;
    @xmldata:Attribute
    string SEGMENT;
};

type IDOC record {
    EDI_DC40 EDI_DC40;
    E1MARAM E1MARAM;
    @xmldata:Attribute
    string BEGIN;
};

type MATMAS05 record {
    IDOC IDOC;
};

type MaterialUpdate record {|
    string idocNumber;
    string material;
    string description;
    string materialType;
    string materialGroup;
    string baseUnit;
    string netWeight;
    string weightUnit;
|};
