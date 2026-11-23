const SUMMARY_LIMIT = 1500;
const SECTION_LIMIT = 3000;

isolated function toAdvisory(AdviceCountry country, AdviceDocument advice) returns TravelAdvisory {
    AdviceDetails details = advice.details;
    string[] alertStatus = details.alert_status ?: [];
    AdvicePart[] parts = details.parts ?: [];
    string summary = parts.length() > 0 ? toPlainText(html = parts[0].body, maxChars = SUMMARY_LIMIT) : "";
    return {
        countryName: country.name,
        adviceLevel: toAdviceLevel(alertStatus),
        alertStatus,
        latestChange: details?.change_description,
        updatedAt: advice?.public_updated_at,
        warningsSummary: summary,
        sourceUrl: pageUrl(country)
    };
}

isolated function toSection(AdviceCountry country, AdvicePart part) returns AdviceSection => {
    countryName: country.name,
    title: part.title,
    text: toPlainText(html = part.body, maxChars = SECTION_LIMIT),
    sourceUrl: part?.slug is string ? string `${pageUrl(country)}/${part?.slug ?: ""}` : pageUrl(country)
};

isolated function pageUrl(AdviceCountry country) returns string =>
    string `https://www.gov.uk/foreign-travel-advice/${country.slug}`;

isolated function toAdviceLevel(string[] alertStatus) returns AdviceLevel {
    if alertStatus.indexOf("avoid_all_travel_to_whole_country") !is () {
        return "AVOID_ALL_TRAVEL";
    }
    if alertStatus.indexOf("avoid_all_but_essential_travel_to_whole_country") !is () {
        return "ESSENTIAL_TRAVEL_ONLY";
    }
    return alertStatus.length() > 0 ? "AVOID_PARTS" : "NO_FCDO_WARNING";
}

isolated function toPlainText(string html, int maxChars) returns string {
    string withoutTags = re `<[^>]*>`.replaceAll(html, " ");
    string collapsed = re `\s+`.replaceAll(withoutTags, " ").trim();
    return collapsed.length() > maxChars ? collapsed.substring(0, maxChars) + "…" : collapsed;
}
