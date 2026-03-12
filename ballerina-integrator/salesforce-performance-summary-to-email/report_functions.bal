import ballerina/http;
import ballerinax/salesforce;

public function getReportMetadata(string reportId) returns map<json>|error {
    string endpoint = string `/services/data/v59.0/analytics/reports/${reportId}/describe`;
    http:Client baseClient = check new (salesforceConfig.baseUrl, {
        auth: {
            clientId: salesforceConfig.clientId,
            clientSecret: salesforceConfig.clientSecret,
            refreshToken: salesforceConfig.refreshToken,
            refreshUrl: salesforceConfig.refreshUrl
        }
    });

    json response = check baseClient->get(endpoint);
    return check response.cloneWithType();
}

public function extractMetricLabels(map<json> metadata) returns MetricInfo[]|error {
    MetricInfo[] metrics = [];

    json? reportMetadata = metadata.get("reportMetadata");
    if reportMetadata is () {
        return metrics;
    }

    json? aggregatesJson = check reportMetadata.aggregates;
    if aggregatesJson is () || !(aggregatesJson is json[]) {
        return metrics;
    }

    json[] aggregates = <json[]>aggregatesJson;
    json? extendedMetadata = metadata.get("reportExtendedMetadata");
    if extendedMetadata is () {
        return metrics;
    }

    json? aggregateColumnInfo = check extendedMetadata.aggregateColumnInfo;
    if aggregateColumnInfo is () {
        return metrics;
    }

    map<json> aggregateMap = check aggregateColumnInfo.cloneWithType();

    foreach json aggregateItem in aggregates {
        string aggregateName = aggregateItem is string ? aggregateItem : check aggregateItem.name;
        json? columnInfo = aggregateMap.get(aggregateName);

        if columnInfo is () {
            continue;
        }

        string label = check columnInfo.label;
        metrics.push({
            name: aggregateName,
            label: label,
            value: 0.0
        });
    }

    return metrics;
}

public function executeReportWithFilters(
        string reportId,
        string startDate,
        string endDate
) returns ReportExecutionResult|error {
    salesforce:ReportInstanceResult reportResult = check salesforceClient->runReportSync(reportId);

    string reportName = "";
    if reportResult.attributes is salesforce:SyncReportAttributes {
        salesforce:SyncReportAttributes syncAttrs = <salesforce:SyncReportAttributes>reportResult.attributes;
        reportName = syncAttrs.reportName;
    } else if reportResult.attributes is salesforce:AsyncReportAttributes {
        salesforce:AsyncReportAttributes asyncAttrs = <salesforce:AsyncReportAttributes>reportResult.attributes;
        reportName = asyncAttrs.reportName;
    }

    map<json> factMapData = reportResult.factMap ?: {};
    FactMapAggregates aggregates = check parseFactMap(factMapData);

    return {
        aggregates: aggregates,
        rawFactMap: factMapData,
        reportName: reportName
    };
}

function parseFactMap(map<json> factMap) returns FactMapAggregates|error {
    decimal totalRevenue = 0.0;
    int dealsClosedCount = 0;
    decimal pipelineValue = 0.0;
    int openOpportunitiesCount = 0;

    json? grandTotalJson = factMap.get("T!T");
    if grandTotalJson is () {
        grandTotalJson = factMap.get("0!T");
    }

    if grandTotalJson !is () {
        json? aggregatesJson = check grandTotalJson.aggregates;
        if aggregatesJson is json[] && aggregatesJson.length() > 0 {
            json? valueJson = check aggregatesJson[0].value;
            totalRevenue = valueJson is decimal ? valueJson :
                    valueJson is int ? <decimal>valueJson : 0.0;

            if aggregatesJson.length() > 1 {
                json? valueJson2 = check aggregatesJson[1].value;
                dealsClosedCount = valueJson2 is int ? valueJson2 :
                        valueJson2 is decimal ? <int>valueJson2 : 0;
            }
        }
    }

    return {
        totalRevenue: roundToTwoDecimals(totalRevenue),
        dealsClosedCount: dealsClosedCount,
        pipelineValue: roundToTwoDecimals(pipelineValue),
        openOpportunitiesCount: openOpportunitiesCount
    };
}

function aggregatesToMetrics(FactMapAggregates aggregates) returns PerformanceMetrics {
    decimal averageDealSize = aggregates.dealsClosedCount > 0
        ? roundToTwoDecimals(aggregates.totalRevenue / <decimal>aggregates.dealsClosedCount)
        : 0.0;

    int totalDeals = aggregates.dealsClosedCount + aggregates.openOpportunitiesCount;
    decimal winRate = totalDeals > 0
        ? roundToTwoDecimals((<decimal>aggregates.dealsClosedCount / <decimal>totalDeals) * 100.0)
        : 0.0;

    return {
        totalRevenue: roundToTwoDecimals(aggregates.totalRevenue),
        dealsClosedCount: aggregates.dealsClosedCount,
        pipelineValue: roundToTwoDecimals(aggregates.pipelineValue),
        openOpportunitiesCount: aggregates.openOpportunitiesCount,
        averageDealSize: averageDealSize,
        winRate: winRate
    };
}

public function generateReportBasedSummary(
        string reportId,
        string currentStartDate,
        string currentEndDate,
        string previousStartDate,
        string previousEndDate
) returns PerformanceSummary|error {
    ReportExecutionResult currentResult = check executeReportWithFilters(
            reportId,
            currentStartDate,
            currentEndDate
    );

    ReportExecutionResult previousResult = check executeReportWithFilters(
            reportId,
            previousStartDate,
            previousEndDate
    );

    PerformanceMetrics currentMetrics = aggregatesToMetrics(currentResult.aggregates);
    PerformanceMetrics previousMetrics = aggregatesToMetrics(previousResult.aggregates);

    decimal revenueChange = currentMetrics.totalRevenue - previousMetrics.totalRevenue;
    decimal revenueChangePercent = calculatePercentageChange(
            currentMetrics.totalRevenue,
            previousMetrics.totalRevenue
    );

    int dealsChange = currentMetrics.dealsClosedCount - previousMetrics.dealsClosedCount;
    decimal dealsChangePercent = calculatePercentageChange(
            <decimal>currentMetrics.dealsClosedCount,
            <decimal>previousMetrics.dealsClosedCount
    );

    decimal pipelineChange = currentMetrics.pipelineValue - previousMetrics.pipelineValue;
    decimal pipelineChangePercent = calculatePercentageChange(
            currentMetrics.pipelineValue,
            previousMetrics.pipelineValue
    );

    return {
        currentPeriod: currentMetrics,
        previousPeriod: previousMetrics,
        comparison: {
            revenueChange: revenueChange,
            revenueChangePercent: revenueChangePercent,
            dealsChange: dealsChange,
            dealsChangePercent: dealsChangePercent,
            pipelineChange: pipelineChange,
            pipelineChangePercent: pipelineChangePercent
        },
        repBreakdown: [],
        periodStart: currentStartDate,
        periodEnd: currentEndDate,
        comparisonType: comparisonPeriod
    };
}

public function generateReportSummary(
        string reportId,
        string currentStartDate,
        string currentEndDate,
        string previousStartDate,
        string previousEndDate
) returns ReportSummary|error {
    map<json>|error metadata = getReportMetadata(reportId);
    if metadata is error {
        string errorMsg = metadata.message();
        return error(string `Failed to access report '${reportId}': ${errorMsg}`);
    }
    
    MetricInfo[] metricTemplate = check extractMetricLabels(metadata);

    string reportName = "Salesforce Performance Report";
    json? reportMetadata = metadata.get("reportMetadata");
    if reportMetadata !is () {
        json? nameJson = check reportMetadata.name;
        if nameJson is string {
            reportName = nameJson;
        }
    }

    ReportExecutionResult currentResult = check executeReportWithFilters(
            reportId,
            currentStartDate,
            currentEndDate
    );

    ReportExecutionResult previousResult = check executeReportWithFilters(
            reportId,
            previousStartDate,
            previousEndDate
    );

    MetricInfo[] currentMetrics = check populateMetricsFromFactMap(
            metricTemplate,
            currentResult.rawFactMap
    );

    MetricInfo[] previousMetrics = check populateMetricsFromFactMap(
            metricTemplate,
            previousResult.rawFactMap
    );

    if currentMetrics.length() == 0 {
        return error("No metrics found in report. The report may be empty or missing aggregated fields.");
    }

    return {
        reportId: reportId,
        reportName: reportName,
        currentMetrics: currentMetrics,
        previousMetrics: previousMetrics,
        repBreakdown: [],
        periodStart: currentStartDate,
        periodEnd: currentEndDate
    };
}

function populateMetricsFromFactMap(
        MetricInfo[] metricTemplate,
        map<json> factMap
) returns MetricInfo[]|error {
    MetricInfo[] populatedMetrics = [];

    json? grandTotalJson = factMap.get("T!T");
    if grandTotalJson is () {
        grandTotalJson = factMap.get("0!T");
        if grandTotalJson is () {
            return metricTemplate;
        }
    }

    json? aggregatesJson = check grandTotalJson.aggregates;
    if aggregatesJson is () || !(aggregatesJson is json[]) {
        return metricTemplate;
    }

    json[] aggregates = <json[]>aggregatesJson;

    foreach int i in 0 ..< metricTemplate.length() {
        MetricInfo metric = metricTemplate[i];

        if i < aggregates.length() {
            json? valueJson = check aggregates[i].value;
            decimal value = valueJson is decimal ? valueJson :
                    valueJson is int ? <decimal>valueJson :
                        valueJson is float ? <decimal>valueJson : 0.0;

            populatedMetrics.push({
                name: metric.name,
                label: metric.label,
                value: roundToTwoDecimals(value)
            });
        } else {
            populatedMetrics.push(metric);
        }
    }

    return populatedMetrics;
}
