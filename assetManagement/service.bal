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
//-----------------------------------------------------------------------------------------------------

 
    // Check for overdue maintenance schedules
    resource function get assets/overdue() returns Assets[]|string {
    time:Utc currentUtc = time:utcNow();
    int todayEpoch = currentUtc.time;

    Assets[] overdueAssets = [];

    foreach var asset in assetsTable {
        foreach var schedule in asset.schedules {
            time:Utc dueUtc = time:constructUtcFromDate(schedule.nextDueDate);
            if dueUtc.time < todayEpoch {
                overdueAssets.push(asset);
                break;
            }
        }
    }

    if overdueAssets.length() == 0 {
        return "No overdue maintenance schedules found.";
    }

    return overdueAssets;
}


    // Add a schedule to an asset
    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule newSchedule) returns string|http:NotFound|http:Conflict {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Asset with tag '" + assetTag + "' not found.";
        }
        if asset.schedules.some(s => s.id == newSchedule.id) {
            return http:CONFLICT;
        }
        asset.schedules.push(newSchedule);
        return "Schedule with ID '" + newSchedule.id + "' has been added to asset '" + assetTag + "'.";
    }

    // Delete a schedule from an asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        int? index = ();
        foreach int i in 0 ..< asset.schedules.length() {
            if asset.schedules[i].id == scheduleId {
                index = i;
                break;
            }
        }
        if index is () {
            return http:NOT_FOUND;
        }
        _ = asset.schedules.remove(index);
        return "Schedule with ID '" + scheduleId + "' has been deleted.";
    }

    // Add a work order to an asset
    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder newWorkOrder) returns string|http:NotFound|http:Conflict {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Asset with tag '" + assetTag + "' not found.";
        }
        if asset.workOrders.some(wo => wo.id == newWorkOrder.id) {
            return http:CONFLICT;
        }
        asset.workOrders.push(newWorkOrder);
        return "Work order with ID '" + newWorkOrder.id + "' has been added to asset '" + assetTag + "'.";
    }

    // Update a work order for an asset
    resource function put assets/[string assetTag]/workorders/[string workOrderId](@http:Payload WorkOrder updatedWorkOrder) returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Asset with tag '" + assetTag + "' not found.";
        }
        int? index = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].id == workOrderId {
                index = i;
                break;
            }
        }
        if index is () {
            return "Work order with ID '" + workOrderId + "' not found for asset '" + assetTag + "'.";
        }
        asset.workOrders[index] = updatedWorkOrder;
        return "Work order with ID '" + workOrderId + "' has been updated successfully.";
    }

    // Add a task to a work order
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task newTask) returns string|http:NotFound|http:Conflict {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Asset with tag '" + assetTag + "' not found.";
        }
        int? workOrderIndex = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].id == workOrderId {
                workOrderIndex = i;
                break;
            }
        }
        if workOrderIndex is () {
            return "Work order with ID '" + workOrderId + "' not found for asset '" + assetTag + "'.";
        }
        WorkOrder workOrder = asset.workOrders[workOrderIndex];
        if workOrder.tasks.some(t => t.id == newTask.id) {
            return http:CONFLICT;
        }
        workOrder.tasks.push(newTask);
        return "Task with ID '" + newTask.id + "' has been added to work order '" + workOrderId + "'.";
    }

    // Delete a task from a work order
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        int? workOrderIndex = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].id == workOrderId {
                workOrderIndex = i;
                break;
            }
        }
        if workOrderIndex is () {
            return http:NOT_FOUND;
        }
        WorkOrder workOrder = asset.workOrders[workOrderIndex];
        int? taskIndex = ();
        foreach int i in 0 ..< workOrder.tasks.length() {
            if workOrder.tasks[i].id == taskId {
                taskIndex = i;
                break;
            }
        }
        if taskIndex is () {
            return http:NOT_FOUND;
        }
       _ = workOrder.tasks.remove(taskIndex);
        return "Task with ID '" + taskId + "' has been deleted from work order '" + workOrderId + "'.";
    }
}

