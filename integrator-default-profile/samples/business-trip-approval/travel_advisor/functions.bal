# The UK FCDO travel advice for a country (GOV.UK Content API).
# + countryName - Country name in English, or a common synonym such as "United States"
# + return - The advice level and a summary of current warnings
public isolated function travelAdvisory(string countryName) returns TravelAdvisory|error {
    AdviceCountry country = check findAdviceCountry(countryName);
    AdviceDocument advice = check advisoryClient->/foreign\-travel\-advice/[country.slug];
    return toAdvisory(country, advice);
}

# One section of the FCDO advice for a country.
# + countryName - Country name in English
# + sectionTitle - The section title, e.g. "Entry requirements", "Safety and security" or "Health"
# + return - The section as plain text
public isolated function adviceSection(string countryName, string sectionTitle) returns AdviceSection|error {
    AdviceCountry country = check findAdviceCountry(countryName);
    AdviceDocument advice = check advisoryClient->/foreign\-travel\-advice/[country.slug];
    string wanted = sectionTitle.toLowerAscii();
    foreach AdvicePart part in advice.details.parts ?: [] {
        if part.title.toLowerAscii() == wanted {
            return toSection(country, part);
        }
    }
    return error(string `The FCDO advice for ${country.name} has no '${sectionTitle}' section`);
}

isolated function findAdviceCountry(string countryName) returns AdviceCountry|error {
    AdviceIndex index = check advisoryClient->/foreign\-travel\-advice;
    string wanted = countryName.trim().toLowerAscii();
    foreach AdviceIndexChild child in index.links.children {
        AdviceIndexDetails? details = child.details;
        AdviceCountry? country = details is () ? () : details?.country;
        if country is () {
            continue;
        }
        if country.name.toLowerAscii() == wanted || country.slug == wanted {
            return country;
        }
        string[] synonyms = country.synonyms ?: [];
        foreach string synonym in synonyms {
            if synonym.toLowerAscii() == wanted {
                return country;
            }
        }
    }
    return error(string `No FCDO travel advice page found for '${countryName}'`);
}
