import wso2/destination_researcher;
import wso2/travel_advisor;

# The travel rules for an employee grade.
public type TravelPolicy record {|
    # The employee grade the rules apply to: "staff", "director" or "vp"
    string grade;
    # Trips requested with less notice than this get a warning
    int minNoticeDays;
    # Longer trips need a second approval from the manager's manager
    int maxTripDaysWithoutEscalation;
|};

# The result of checking a trip against the travel policy.
public type PolicyEvaluation record {|
    # False when a blocker stops the request from being submitted
    boolean submittable;
    # Reasons the request cannot be submitted as it is
    string[] blockers;
    # Reasons the request also needs approval from the manager's manager
    string[] secondApprovalReasons;
    # Things the traveler and approvers should know
    string[] warnings;
    # Days between today and the first day of the trip
    int noticeDays;
    # Days away, counting the first and last day
    int tripDays;
    # The FCDO advice level, or nil when it could not be checked
    travel_advisor:AdviceLevel? adviceLevel;
    # Public holidays at the destination during the trip, or nil when they could not be checked
    destination_researcher:PublicHoliday[]? publicHolidays;
|};
