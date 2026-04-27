
service class BookInfo {
    function init() {
    }

    resource function get title() returns string {
        do {
            panic error("Unimplemented function");
        } on fail error err {
            //handle error
            panic error("Unhandled error");
        }
    }

    resource function get author() returns string {
        do {
            panic error("Unimplemented function");
        } on fail error err {
            //handle error
            panic error("Unhandled error");
        }
    }
}
