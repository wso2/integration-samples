// What the tracker remembers between runs, saved on the share itself.
type Snapshot record {|
    // The share's files at the previous run: file path -> entity tag.
    map<string> entries = {};
|};
