import ballerina/lang.regexp;
import ballerina/time;

public function today() returns string {
    return formatDate(time:utcToCivil(time:utcNow()));
}

public function tommorrow() returns string {
    return formatDate(time:utcToCivil(time:utcAddSeconds(time:utcNow(), 86400)));
}

public function formatDate(time:Civil value) returns string {
    return string `${value.year}-${value.month < 10 ? "0" + value.month.toString() : value.month.toString()}-${value.day < 10 ? "0" + value.day.toString() : value.day.toString()}`;
}

# Converts a SuccessFactors OData date string, e.g. `/Date(1790208000000)/` or
# `/Date(1608132315000+0000)/`, into a plain `YYYY-MM-DD` date the Google Calendar API accepts.
public function odataDateToIsoDate(string odataDate) returns string|error {
    regexp:Span span = check (re `\d+`.find(odataDate) ?: error(string `Invalid OData date: ${odataDate}`));
    int epochMillis = check int:fromString(span.substring());
    return formatDate(time:utcToCivil([epochMillis / 1000, <decimal>(epochMillis % 1000) / 1000.0d]));
}
