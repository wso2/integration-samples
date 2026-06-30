
public type Probability record {
    decimal neg;
    decimal neutral;
    decimal pos;
};

public type Sentiment record {
    Probability probability;
    string label;
};

public type Post record {
    string text;
};