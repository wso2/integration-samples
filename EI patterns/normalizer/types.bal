type ZendeskResponse record {
    record {|
        string url;
        int id;
        string subject;
    |} ticket;
};
