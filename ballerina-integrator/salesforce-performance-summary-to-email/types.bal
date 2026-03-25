import ballerina/time;

public type ReportMetadata record {
    string reportFormat?;
    ReportFilter[] reportFilters?;
};

public type ReportFilter record {
    string column;
    string operator;
    string value;
};

public type FactMapAggregates record {
    decimal totalRevenue;
    int dealsClosedCount;
    decimal pipelineValue;
    int openOpportunitiesCount;
};

public type PerformanceMetrics record {
    decimal totalRevenue;
    int dealsClosedCount;
    decimal pipelineValue;
    int openOpportunitiesCount;
    decimal averageDealSize;
    decimal winRate;
};

public type ComparisonMetrics record {
    decimal revenueChange;
    decimal revenueChangePercent;
    int dealsChange;
    decimal dealsChangePercent;
    decimal pipelineChange;
    decimal pipelineChangePercent;
};

public type RepPerformance record {
    string repName;
    string repId;
    decimal revenue;
    int dealsCount;
    decimal pipelineValue;
};

public type PerformanceSummary record {
    PerformanceMetrics currentPeriod;
    PerformanceMetrics previousPeriod;
    ComparisonMetrics comparison;
    RepPerformance[] repBreakdown;
    time:Civil periodStart;
    time:Civil periodEnd;
    string comparisonType;
};

public type ReportExecutionResult record {
    FactMapAggregates aggregates;
    map<json> rawFactMap;
    string reportName;
};

public type MetricInfo record {
    string name;
    string label;
    decimal value;
};

public type ReportSummary record {
    string reportId;
    string reportName;
    MetricInfo[] currentMetrics;
    MetricInfo[] previousMetrics;
    RepPerformance[] repBreakdown;
    time:Civil periodStart;
    time:Civil periodEnd;
};
