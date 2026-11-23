# UK FCDO advice level for a country.
public type AdviceLevel "AVOID_ALL_TRAVEL"|"ESSENTIAL_TRAVEL_ONLY"|"AVOID_PARTS"|"NO_FCDO_WARNING";

# The FCDO's overall advice for a country.
public type TravelAdvisory record {|
    # The FCDO's name for the country
    string countryName;
    # The strictest advice that applies to the whole country, or to parts of it
    AdviceLevel adviceLevel;
    # The FCDO's alert codes, e.g. `avoid_all_but_essential_travel_to_parts`
    string[] alertStatus;
    # The FCDO's note on its latest change
    string? latestChange;
    # When the FCDO last updated the advice
    string? updatedAt;
    # The start of the "Warnings and insurance" section, as plain text
    string warningsSummary;
    # The advice page on GOV.UK
    string sourceUrl;
|};

# One section of the FCDO advice for a country, such as "Entry requirements".
public type AdviceSection record {|
    # The FCDO's name for the country
    string countryName;
    # The section title
    string title;
    # The section as plain text, cut short if long
    string text;
    # The section on GOV.UK
    string sourceUrl;
|};

// ---- GOV.UK Content API wire types ----

type AdviceCountry record {
    string name;
    string slug;
    string[] synonyms?;
};

type AdviceIndexDetails record {
    AdviceCountry country?;
};

type AdviceIndexChild record {
    string title;
    AdviceIndexDetails details?;
};

type AdviceIndexLinks record {
    AdviceIndexChild[] children;
};

type AdviceIndex record {
    AdviceIndexLinks links;
};

type AdvicePart record {
    string title;
    string slug?;
    string body;
};

type AdviceDetails record {
    string[] alert_status?;
    string? change_description?;
    AdvicePart[] parts?;
};

type AdviceDocument record {
    string title;
    string? public_updated_at?;
    AdviceDetails details;
};
