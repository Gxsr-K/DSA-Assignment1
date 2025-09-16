import ballerina/http;
import ballerina/time;

// Component record
public type Component record {|
    string id;
    string name;
|};

// Schedule record
public type Schedule record {|
    string id;
    string description;
    time:Date nextDueDate;
|};

// Task record
public type Task record {|
    string id;
    string description;
|};

// WorkOrder record
public type WorkOrder record {|
    string id;
    string description;
    Task[] tasks;
    string status; // e.g., "OPEN", "CLOSED"
|};

public type AssetStatus "ACTIVE"|"UNDER_REPAIR"|"DISPOSED";

// Corrected Assets record with a more specific type for the 'status' field.
public type Assets record {|
    readonly string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status;
    time:Date acquiredDate;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
|};
public type newAssets record {|
    string name;
    string faculty;
    string department;
    AssetStatus status;
    time:Date acquiredDate;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
|};

// Your table is correctly defined.
table<Assets> key(assetTag) assetsTable = table [
    {
        assetTag: "A001",
        name: "Laptop",
        faculty: "Engineering",
        department: "Computer Science",
        status: "ACTIVE",
        acquiredDate: {year: 2022, month: 1, day: 15},
        components: [],
        schedules: [],
        workOrders: []
    },
    {
        assetTag: "A002",
        name: "Projector",
        faculty: "Arts",
        department: "Media Studies",
        status: "UNDER_REPAIR",
        acquiredDate: {year: 2021, month: 5, day: 20},
        components: [],
        schedules: [],
        workOrders: []
    }
];
 

// Service implementation
service /assetManagement on new http:Listener(9090) {

    // get all assets
    // The resource function name should be assets, and the path should be '/assets' which is
    // inferred from the service name '/assetManagement' and the resource name 'assets'.
    resource function get assets() returns Assets[] {
        return assetsTable.toArray();
    }

    // get asset by assetTag
    // The path parameter 'assetTag' is defined in the resource name as '[string assetTag]'.
    // The return type is a union of 'Assets' or the built-in 'http:NotFound' type.
    resource function get assets/[string assetTag]() returns Assets|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            // Return the http:NotFound constant to indicate a 404 error.
            return http:NOT_FOUND;
        }
        return asset;
    }
}