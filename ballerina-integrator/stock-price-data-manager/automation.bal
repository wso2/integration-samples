import ballerina/io;
import ballerina/log;
import ballerina/time;

public function main() returns error? {
    do {
        StockPriceResponse stockPriceResponse = check httpClient->get("query?function=TOP_GAINERS_LOSERS&apikey=" + stockAPIKey);
        log:printInfo("Stock prices fetched successfully");
        time:Date date = time:utcToCivil(time:utcNow());
        string dateStr = date.year.toBalString() + "-" + date.month.toBalString() + "-" + date.day.toBalString();
        string gainersPath = dateStr + "-top-gainers.csv";
        string losersPath = dateStr + "-top-losers.csv";
        check io:fileWriteCsv("/tmp/" + gainersPath, stockPriceResponse.top_gainers);
        check io:fileWriteCsv("/tmp/" + losersPath, stockPriceResponse.top_losers);
        string[][] gainersFile = check io:fileReadCsv("/tmp/" + gainersPath);
        string[][] losersFile = check io:fileReadCsv("/tmp/" + losersPath);
        check ftpClient->put("/" + gainersPath, gainersFile);
        check ftpClient->put("/" + losersPath, losersFile);
        log:printInfo("Stock data uploaded to the FTP server");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
