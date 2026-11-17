import wso2/logistics_coordinator;

public type TravelPolicy record {|
    string grade;
    logistics_coordinator:CabinClass defaultCabin;
    # Cabin allowed when the longest flight leg is at least `upgradeAfterHours`
    logistics_coordinator:CabinClass longHaulCabin;
    decimal upgradeAfterHours;
    decimal hotelNightlyCapUsd;
    decimal tripCapUsd;
    int minAdvanceDays;
|};

public type PolicyEvaluation record {|
    boolean compliant;
    decimal totalUsd;
    # The highest cabin the policy allows for this trip; any lower cabin also complies
    logistics_coordinator:CabinClass highestAllowedCabin;
    string[] violations;
    string[] warnings;
|};

public type CurrencyConversion record {|
    decimal amount;
    string fromCurrency;
    decimal converted;
    string toCurrency;
    decimal rate;
    string rateDate;
|};

type FxResponse record {
    string base;
    string date;
    map<decimal> rates;
};
