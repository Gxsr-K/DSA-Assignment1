import ballerina/io;
import ballerina/http;
import ballerina/time;

// This record matches the structure of the Asset record in the service.
public type Assets record {|
    readonly string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    time:Date acquiredDate;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
|};

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

// WorkOrder record
public type WorkOrder record {|
    string id;
    string description;
    Task[] tasks;
    string status;
|};

// Task record
public type Task record {|
    string id;
    string description;
|};

// The HTTP client that interacts with our service.
final http:Client assetManagementClient = check new ("http://localhost:9090/assetManagement");

public function main() returns error? {
    // A. Add a new asset
    io:println("\n--- 1. Adding a new asset (Laptop EQ-001) ---");
    Assets newLaptop = {
        assetTag: "EQ-001",
        name: "Laptop",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: {year: 2024, month: 3, day: 10},
        components: [],
        schedules: [],
        workOrders: []
    };
    string postResponse = check assetManagementClient->post("/assets", newLaptop, targetType = string);
    io:println(postResponse);

    // B. Add another asset to test the overdue check
    io:println("\n--- 2. Adding an asset with an overdue schedule (Server S-202) ---");
    // Create a date in the past for testing overdue schedules
    time:Date overdueDate = {year: 2020, month: 1, day: 1};
    Assets newServer = {
        assetTag: "S-202",
        name: "Server Rack",
        faculty: "Engineering",
        department: "Data Engineering",
        status: "ACTIVE",
        acquiredDate: {year: 2023, month: 6, day: 25},
        components: [],
        schedules: [
            {id: "SCH-001", description: "Quarterly check", nextDueDate: overdueDate}
        ],
        workOrders: []
    };
    postResponse = check assetManagementClient->post("/assets", newServer, targetType = string);
    io:println(postResponse);

    // C. View all assets
    io:println("\n--- 3. Viewing all assets ---");
    Assets[] allAssets = check assetManagementClient->get("/assets");
    io:println(allAssets);

    // D. View assets by faculty
    io:println("\n--- 4. Viewing assets for 'Engineering' faculty ---");
    Assets[] engineeringAssets = check assetManagementClient->get("/assets/by-faculty/Engineering");
    io:println(engineeringAssets);

    // E. Update an asset
    io:println("\n--- 5. Updating asset 'EQ-001' to 'UNDER_REPAIR' status ---");
    Assets updatedLaptop = {
        assetTag: "EQ-001",
        name: "Laptop",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "UNDER_REPAIR", // Status changed here
        acquiredDate: {year: 2024, month: 3, day: 10},
        components: [],
        schedules: [],
        workOrders: []
    };
    string putResponse = check assetManagementClient->put("/assets/EQ-001", updatedLaptop, targetType = string);
    io:println(putResponse);

    // Verify the update
    io:println("\n--- 6. Viewing updated asset 'EQ-001' ---");
    Assets updatedAsset = check assetManagementClient->get("/assets/EQ-001");
    io:println(updatedAsset);

    // F. Manage a component (add and remove) for an asset
    io:println("\n--- 7. Adding a new component (SSD) to asset 'EQ-001' ---");
    Component newComponent = {id: "COMP-101", name: "SSD"};
    string addCompResponse = check assetManagementClient->post("/assets/EQ-001/components", newComponent, targetType = string);
    io:println(addCompResponse);

    io:println("\n--- 8. Deleting component 'COMP-101' from asset 'EQ-001' ---");
    string delCompResponse = check assetManagementClient->delete("/assets/EQ-001/components/COMP-101", targetType = string);
    io:println(delCompResponse);

    // G. Check for overdue items
    io:println("\n--- 9. Checking for assets with overdue maintenance schedules ---");
    Assets[] overdueAssets = check assetManagementClient->get("/assets/overdue");
    io:println(overdueAssets);

    // H. Delete an asset
    io:println("\n--- 10. Deleting asset 'EQ-001' ---");
    string deleteResponse = check assetManagementClient->delete("/assets/EQ-001", targetType = string);
    io:println(deleteResponse);

return;
}