// Represents a single timesheet record from the CSV file
type TimesheetRecord record {|
    string contractor_id;
    string date;
    decimal hours_worked;
    string site_code;
|};
