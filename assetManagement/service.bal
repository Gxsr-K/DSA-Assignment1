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

        // Added: POST /assets - Create a new asset.
    resource function post assets(@http:Payload Assets newAsset) returns http:Created|http:Conflict {
        if assetsTable.hasKey(newAsset.assetTag) {
            // Return 409 Conflict if assetTag already exists
            return http:CONFLICT;
        }
        assetsTable.add(newAsset);
        // Return 201 Created on success
        return http:CREATED;
    }

    // Added: DELETE /assets/[assetTag] - Delete an asset.
    resource function delete assets/[string assetTag]() returns http:NoContent|http:NotFound {
        Assets? asset = assetsTable.remove(assetTag);
        if asset is () {
            return http:NOT_FOUND;
        }
        // Return 204 No Content on successful deletion
        return http:NO_CONTENT;
    }
        // Added: GET /assets/by-faculty/[facultyName] - Get assets by faculty.
    resource function get assets/by\-faculty/[string facultyName]() returns Assets[] {
        Assets[] assetsByFaculty = from var asset in assetsTable
            where asset.faculty.toLowerAscii() == facultyName.toLowerAscii()
            select asset;
        return assetsByFaculty;
    }
        // Added: POST /assets/[assetTag]/components - Add a component to an asset.
    resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns Component[]|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        asset.components.push(newComponent);
        return asset.components;
    }




    }