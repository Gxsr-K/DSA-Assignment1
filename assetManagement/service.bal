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

// Assets record with a specific type for the 'status' field.
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

// Main database table for assets.
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

    // Get all assets
    // Returns a list of all assets or a message if the table is empty.
    resource function get assets() returns Assets[]|string {
        if assetsTable.length() == 0 {
            return "No assets found.";
        }
        return assetsTable.toArray();
    }

    // Get a specific asset by its tag
    // Returns the asset data or a message if the asset is not found.
    resource function get assets/[string assetTag]() returns Assets|string {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Asset with tag '" + assetTag + "' not found.";
        }
        return asset;
    }

    // Create a new asset
    // Adds a new asset and returns a success message or a conflict error if the tag already exists.
    resource function post assets(@http:Payload Assets newAsset) returns string|http:Conflict {
        if assetsTable.hasKey(newAsset.assetTag) {
            return "Error: Asset with tag '" + newAsset.assetTag + "' already exists.";
        }
        assetsTable.add(newAsset);
        return "Asset with tag '" + newAsset.assetTag + "' has been created successfully.";
    }

    // Update an existing asset
    // Updates an asset and returns a success message or a not found error if the tag does not exist.
    resource function put assets/[string assetTag](@http:Payload Assets updatedAsset) returns string|http:NotFound {
        if !assetsTable.hasKey(assetTag) {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        assetsTable.put(updatedAsset);
        return "Asset with tag '" + assetTag + "' has been updated successfully.";
    }

    // Delete an asset
    // Deletes an asset and returns a success message or a not found error.
    resource function delete assets/[string assetTag]() returns string|http:NotFound {
        Assets? asset = assetsTable.remove(assetTag);
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        return "Asset with tag '" + assetTag + "' has been deleted successfully.";
    }

    // Get all assets belonging to a specific faculty
    // Returns a list of assets or a message if no assets are found for that faculty.
    resource function get assets/by\-faculty/[string facultyName]() returns Assets[]|string {
        Assets[] assetsByFaculty = from var asset in assetsTable
            where asset.faculty.toLowerAscii() == facultyName.toLowerAscii()
            select asset;

        if assetsByFaculty.length() == 0 {
            return "No assets found for faculty '" + facultyName + "'.";
        }
        return assetsByFaculty;
    }

    // Add a component to an asset
    // Adds a component and returns a success message. Provides specific errors if the asset or a duplicate component is found.
    resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns string|http:NotFound|http:Conflict {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        if asset.components.some(comp => comp.id == newComponent.id) {
            return "Error: Component with ID '" + newComponent.id + "' already exists for asset '" + assetTag + "'.";
        }
        asset.components.push(newComponent);
        return "Component with ID '" + newComponent.id + "' has been added to asset '" + assetTag + "'.";
    }

    // Delete a component from an asset
    // Deletes a component and returns a success message. Provides specific errors if the asset or component is not found.
    resource function delete assets/[string assetTag]/components/[string componentId]() returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        int? index = ();
        foreach int i in 0 ..< asset.components.length() {
            if asset.components[i].id == componentId {
                index = i;
                break;
            }
        }
        if index is () {
            return "Error: Component with ID '" + componentId + "' not found for asset '" + assetTag + "'.";
        }
        _ = asset.components.remove(index);
        return "Component with ID '" + componentId + "' has been deleted successfully from asset '" + assetTag + "'.";
    }
    
    // Check for overdue maintenance schedules
    // Returns a list of assets with overdue schedules or a message if none are found.
    resource function get assets/overdue() returns Assets[]|string {
        time:Civil currentCivilDate = time:utcToCivil(time:utcNow());
        Assets[] overdueAssets = from var asset in assetsTable
                                 where asset.schedules.some(s =>
                                     (s.nextDueDate.year < currentCivilDate.year) ||
                                     (s.nextDueDate.year == currentCivilDate.year && s.nextDueDate.month < currentCivilDate.month) ||
                                     (s.nextDueDate.year == currentCivilDate.year && s.nextDueDate.month == currentCivilDate.month && s.nextDueDate.day < currentCivilDate.day)
                                 )
                                 select asset;

        if overdueAssets.length() == 0 {
            return "No assets with overdue maintenance schedules found.";
        }
        return overdueAssets;
    }

    // Add a schedule to an asset
    // Adds a schedule and returns a success message. Provides specific errors for not found asset or a duplicate schedule.
    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule newSchedule) returns string|http:NotFound|http:Conflict {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        if asset.schedules.some(s => s.id == newSchedule.id) {
            return "Error: Schedule with ID '" + newSchedule.id + "' already exists for asset '" + assetTag + "'.";
        }
        asset.schedules.push(newSchedule);
        return "Schedule with ID '" + newSchedule.id + "' has been added to asset '" + assetTag + "'.";
    }

    // Delete a schedule from an asset
    // Deletes a schedule and returns a success message. Provides specific errors if the asset or schedule is not found.
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        int? index = ();
        foreach int i in 0 ..< asset.schedules.length() {
            if asset.schedules[i].id == scheduleId {
                index = i;
                break;
            }
        }
        if index is () {
            return "Error: Schedule with ID '" + scheduleId + "' not found for asset '" + assetTag + "'.";
        }
        _ = asset.schedules.remove(index);
        return "Schedule with ID '" + scheduleId + "' has been deleted successfully from asset '" + assetTag + "'.";
    }

    // Add a work order to an asset
    // Adds a work order and returns a success message. Provides specific errors for a not found asset or a duplicate work order.
    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder newWorkOrder) returns string|http:NotFound|http:Conflict {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        if asset.workOrders.some(wo => wo.id == newWorkOrder.id) {
            return "Error: Work order with ID '" + newWorkOrder.id + "' already exists for asset '" + assetTag + "'.";
        }
        asset.workOrders.push(newWorkOrder);
        return "Work order with ID '" + newWorkOrder.id + "' has been added to asset '" + assetTag + "'.";
    }

    // Update a work order for an asset
    // Updates a work order and returns a success message. Provides specific errors if the asset or work order is not found.
    resource function put assets/[string assetTag]/workorders/[string workOrderId](@http:Payload WorkOrder updatedWorkOrder) returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        int? index = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].id == workOrderId {
                index = i;
                break;
            }
        }
        if index is () {
            return "Error: Work order with ID '" + workOrderId + "' not found for asset '" + assetTag + "'.";
        }
        asset.workOrders[index] = updatedWorkOrder;
        return "Work order with ID '" + workOrderId + "' has been updated successfully for asset '" + assetTag + "'.";
    }

    // NEW: Delete a work order from an asset
    // Deletes a work order and returns a success message. Provides specific errors if the asset or work order is not found.
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]() returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        int? index = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].id == workOrderId {
                index = i;
                break;
            }
        }
        if index is () {
            return "Error: Work order with ID '" + workOrderId + "' not found for asset '" + assetTag + "'.";
        }
        _ = asset.workOrders.remove(index);
        return "Work order with ID '" + workOrderId + "' has been deleted successfully from asset '" + assetTag + "'.";
    }

    // Add a task to a work order
    // Adds a task and returns a success message. Provides specific errors for a not found asset/work order or a duplicate task.
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task newTask) returns string|http:NotFound|http:Conflict {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        int? workOrderIndex = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].id == workOrderId {
                workOrderIndex = i;
                break;
            }
        }
        if workOrderIndex is () {
            return "Error: Work order with ID '" + workOrderId + "' not found for asset '" + assetTag + "'.";
        }
        WorkOrder workOrder = asset.workOrders[workOrderIndex];
        if workOrder.tasks.some(t => t.id == newTask.id) {
            return "Error: Task with ID '" + newTask.id + "' already exists for work order '" + workOrderId + "'.";
        }
        workOrder.tasks.push(newTask);
        return "Task with ID '" + newTask.id + "' has been added to work order '" + workOrderId + "'.";
    }

    // Delete a task from a work order
    // Deletes a task and returns a success message. Provides specific errors if the asset, work order, or task is not found.
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns string|http:NotFound {
        Assets? asset = assetsTable[assetTag];
        if asset is () {
            return "Error: Asset with tag '" + assetTag + "' not found.";
        }
        int? workOrderIndex = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].id == workOrderId {
                workOrderIndex = i;
                break;
            }
        }
        if workOrderIndex is () {
            return "Error: Work order with ID '" + workOrderId + "' not found for asset '" + assetTag + "'.";
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
            return "Error: Task with ID '" + taskId + "' not found for work order '" + workOrderId + "'.";
        }
        _ = workOrder.tasks.remove(taskIndex);
        return "Task with ID '" + taskId + "' has been deleted successfully from work order '" + workOrderId + "'.";
    }
}
