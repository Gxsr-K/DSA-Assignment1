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

    // CHANGED: The function now checks if the table is empty.
    resource function get assets() returns Assets[]|string {
        if assetsTable.length() == 0 {
            return "No assets found.";
        }
        return assetsTable.toArray();
    }

    // CHANGED: Returns a string message if the asset is not found.
    resource function get assets/[string assetTag]() returns Assets|string {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Asset with tag '" + assetTag + "' not found.";
        }
        return asset;
    }

    // CHANGED: Returns a string message upon successful creation.
    resource function post assets(@http:Payload Assets newAsset) returns string|http:Conflict {
        if assetsTable.hasKey(newAsset.assetTag) {
            return http:CONFLICT;
        }
        assetsTable.add(newAsset);
        return "Asset with tag '" + newAsset.assetTag + "' has been created successfully.";
    }

    // CHANGED: Returns a string message upon successful deletion.
    resource function delete assets/[string assetTag]() returns string|http:NotFound {
        Assets? asset = assetsTable.remove(assetTag);
        if asset is () {
            return http:NOT_FOUND;
        }
        return "Asset with tag '" + assetTag + "' has been deleted successfully.";
    }

 resource function get assets/by\-faculty/[string facultyName]() returns Assets[]|string {
 Assets[] assetsByFaculty = from var asset in assetsTable
 where asset.faculty.toLowerAscii() == facultyName.toLowerAscii()
 select asset;

 if assetsByFaculty.length() == 0 {
 return "No assets found for faculty '" + facultyName + "'.";
 }
return assetsByFaculty;
 }

    // UPDATED: Checks for duplicate component and returns a success message.
 resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns string|http:NotFound|http:Conflict {
 Assets? asset = assetsTable[assetTag];
 if asset is () {
 // Return a specific message if asset is not found.
 return "Asset with tag '" + assetTag + "' not found.";
 }
 // Check for an existing component with the same ID.
     if asset.components.some(comp => comp.id == newComponent.id) {
    return http:CONFLICT;
 }
 asset.components.push(newComponent);
 // Return a success message.
     return "Component with ID '" + newComponent.id + "' has been added to asset '" + assetTag + "'.";
 }

    // UPDATED: Returns a string message upon successful deletion.
    resource function delete assets/[string assetTag]/components/[string componentId]() returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        int? index = ();
        foreach int i in 0 ..< asset.components.length() {
            if asset.components[i].id == componentId {
                index = i;
                break;
            }
        }
        if index is () {
            return http:NOT_FOUND;
        }
        _ = asset.components.remove(index);
        return "Component with ID '" + componentId + "' has been deleted.";
    }
 // NEW: Added PUT for updating an existing asset.
resource function put assets/[string assetTag](@http:Payload Assets updatedAsset) returns string|http:NotFound {
    if !assetsTable.hasKey(assetTag) {
        return http:NOT_FOUND;
    }
    assetsTable.put(updatedAsset);
    return "Asset with tag '" + assetTag + "' has been updated successfully.";
}

}