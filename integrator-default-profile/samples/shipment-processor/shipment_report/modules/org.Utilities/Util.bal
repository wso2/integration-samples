import shipment_report.java.lang as javalang;
import shipment_report.java.util as javautil;

import ballerina/jballerina.java;
import ballerina/jballerina.java.arrays as jarrays;

# Ballerina class mapping for the Java `org.Utilities.Util` class.
@java:Binding {'class: "org.Utilities.Util"}
public distinct class Util {

    *java:JObject;
    *javalang:Object;

    # The `handle` field that stores the reference to the `org.Utilities.Util` object.
    public handle jObj;

    # The init function of the Ballerina class mapping the `org.Utilities.Util` Java class.
    #
    # + obj - The `handle` value containing the Java reference of the object.
    public function init(handle obj) {
        self.jObj = obj;
    }

    # The function to retrieve the string representation of the Ballerina class mapping the `org.Utilities.Util` Java class.
    #
    # + return - The `string` form of the Java object instance.
    public function toString() returns string {
        return java:toString(self.jObj) ?: "";
    }

    # The function that maps to the `equals` method of `org.Utilities.Util`.
    #
    # + arg0 - The `javalang:Object` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function 'equals(javalang:Object arg0) returns boolean {
        return org_Utilities_Util_equals(self.jObj, arg0.jObj);
    }

    # The function that maps to the `getClass` method of `org.Utilities.Util`.
    #
    # + return - The `javalang:Class` value returning from the Java mapping.
    public function getClass() returns javalang:Class {
        handle externalObj = org_Utilities_Util_getClass(self.jObj);
        javalang:Class newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `hashCode` method of `org.Utilities.Util`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function hashCode() returns int {
        return org_Utilities_Util_hashCode(self.jObj);
    }

    # The function that maps to the `notify` method of `org.Utilities.Util`.
    public function notify() {
        org_Utilities_Util_notify(self.jObj);
    }

    # The function that maps to the `notifyAll` method of `org.Utilities.Util`.
    public function notifyAll() {
        org_Utilities_Util_notifyAll(self.jObj);
    }

    # The function that maps to the `wait` method of `org.Utilities.Util`.
    #
    # + return - The `javalang:InterruptedException` value returning from the Java mapping.
    public function 'wait() returns javalang:InterruptedException? {
        error|() externalObj = org_Utilities_Util_wait(self.jObj);
        if (externalObj is error) {
            javalang:InterruptedException e = error javalang:InterruptedException(javalang:INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `org.Utilities.Util`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `javalang:InterruptedException` value returning from the Java mapping.
    public function wait2(int arg0) returns javalang:InterruptedException? {
        error|() externalObj = org_Utilities_Util_wait2(self.jObj, arg0);
        if (externalObj is error) {
            javalang:InterruptedException e = error javalang:InterruptedException(javalang:INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `org.Utilities.Util`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + return - The `javalang:InterruptedException` value returning from the Java mapping.
    public function wait3(int arg0, int arg1) returns javalang:InterruptedException? {
        error|() externalObj = org_Utilities_Util_wait3(self.jObj, arg0, arg1);
        if (externalObj is error) {
            javalang:InterruptedException e = error javalang:InterruptedException(javalang:INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

}

# The constructor function to generate an object of `org.Utilities.Util`.
#
# + return - The new `Util` class generated.
public function newUtil1() returns Util {
    handle externalObj = org_Utilities_Util_newUtil1();
    Util newObj = new (externalObj);
    return newObj;
}

# The function that maps to the `aggregateShipments` method of `org.Utilities.Util`.
#
# + return - The `javautil:Map` value returning from the Java mapping.
public function Util_aggregateShipments() returns javautil:Map {
    handle externalObj = org_Utilities_Util_aggregateShipments();
    javautil:Map newObj = new (externalObj);
    return newObj;
}

# The function that maps to the `main` method of `org.Utilities.Util`.
#
# + arg0 - The `string[]` value required to map with the Java method parameter.
# + return - The `error?` value returning from the Java mapping.
public function Util_main(string[] arg0) returns error? {
    org_Utilities_Util_main(check jarrays:toHandle(arg0, "java.lang.String"));
}

function org_Utilities_Util_aggregateShipments() returns handle = @java:Method {
    name: "aggregateShipments",
    'class: "org.Utilities.Util",
    paramTypes: []
} external;

function org_Utilities_Util_equals(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "equals",
    'class: "org.Utilities.Util",
    paramTypes: ["java.lang.Object"]
} external;

function org_Utilities_Util_getClass(handle receiver) returns handle = @java:Method {
    name: "getClass",
    'class: "org.Utilities.Util",
    paramTypes: []
} external;

function org_Utilities_Util_hashCode(handle receiver) returns int = @java:Method {
    name: "hashCode",
    'class: "org.Utilities.Util",
    paramTypes: []
} external;

function org_Utilities_Util_main(handle arg0) = @java:Method {
    name: "main",
    'class: "org.Utilities.Util",
    paramTypes: ["[Ljava.lang.String;"]
} external;

function org_Utilities_Util_notify(handle receiver) = @java:Method {
    name: "notify",
    'class: "org.Utilities.Util",
    paramTypes: []
} external;

function org_Utilities_Util_notifyAll(handle receiver) = @java:Method {
    name: "notifyAll",
    'class: "org.Utilities.Util",
    paramTypes: []
} external;

function org_Utilities_Util_wait(handle receiver) returns error? = @java:Method {
    name: "wait",
    'class: "org.Utilities.Util",
    paramTypes: []
} external;

function org_Utilities_Util_wait2(handle receiver, int arg0) returns error? = @java:Method {
    name: "wait",
    'class: "org.Utilities.Util",
    paramTypes: ["long"]
} external;

function org_Utilities_Util_wait3(handle receiver, int arg0, int arg1) returns error? = @java:Method {
    name: "wait",
    'class: "org.Utilities.Util",
    paramTypes: ["long", "int"]
} external;

function org_Utilities_Util_newUtil1() returns handle = @java:Constructor {
    'class: "org.Utilities.Util",
    paramTypes: []
} external;

