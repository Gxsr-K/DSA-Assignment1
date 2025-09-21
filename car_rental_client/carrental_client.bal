import ballerina/io;
import ballerina/grpc;
import ballerina/grpc;


CarRentalClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    io:println("=== Car Rental System Demo ===");
    io:println("Running comprehensive tests...\n");
    
    // Run all test operations
    check runAllTests();
    
    
    // check runInteractiveMode();
}

function runAllTests() returns error? {
    //  Add cars to the system
    io:println("TEST 1: Adding cars to the system");
    Car car1 = {
        plate: "ABC123", 
        make: "Toyota", 
        model: "Camry", 
        year: 2022, 
        daily_price: 50.0, 
        mileage: 15000, 
        status: "AVAILABLE"
    };
    AddCarResponse addResponse1 = check ep->AddCar(car1);
    io:println("Add Car 1 Response: " + addResponse1.toString());
    
    Car car2 = {
        plate: "XYZ789", 
        make: "Honda", 
        model: "Civic", 
        year: 2021, 
        daily_price: 45.0, 
        mileage: 20000, 
        status: "AVAILABLE"
    };
    AddCarResponse addResponse2 = check ep->AddCar(car2);
    io:println("Add Car 2 Response: " + addResponse2.toString() + "\n");

    //  Create users via streaming
    io:println("TEST 2: Creating users");
    CreateUsersStreamingClient streamClient = check ep->CreateUsers();
    
    // Create admin user (note: using 'name' field as in your protobuf)
    User adminUser = {id: "admin1", name: "Admin User", role: "ADMIN"};
    check streamClient->sendUser(adminUser);
    
    // Create customer user
    User customerUser = {id: "customer1", name: "John Doe", role: "CUSTOMER"};
    check streamClient->sendUser(customerUser);
    
    check streamClient->complete();
    CreateUsersResponse? usersResponse = check streamClient->receiveCreateUsersResponse();
    io:println("Create Users Response: " + usersResponse.toString() + "\n");

    //  Update car information
    io:println("TEST 3: Updating car information");
    UpdateCarRequest updateReq = {
        plate: "ABC123",
        car: {
            plate: "ABC123",
            make: "Toyota",
            model: "Camry",
            year: 2022,
            daily_price: 55.0, // Updated price
            mileage: 15000,
            status: "AVAILABLE"
        }
    };
    AddCarResponse updateResponse = check ep->UpdateCar(updateReq);
    io:println("Update Car Response: " + updateResponse.toString() + "\n");

    //  Search for cars
    io:println("TEST 4: Searching for cars");
    CarFilter searchFilter = {text: "ABC123"};
    SearchResponse searchResponse = check ep->SearchCar(searchFilter);
    io:println("Search Car Response: " + searchResponse.toString() + "\n");

    //  List available cars
    io:println("TEST 5: Listing available cars");
    CarFilter listFilter = {text: ""}; // No filter
    stream<Car, grpc:Error?> carStream = check ep->ListAvailableCars(listFilter);
    io:println("Available Cars:");
    check carStream.forEach(function(Car car) {
        io:println("  - " + car.toString());
    });
    io:println("");

    //  Add items to cart
    io:println("TEST 6: Adding items to cart");
    AddToCartRequest cartReq1 = {
        user_id: "customer1",
        item: {
            plate: "ABC123",
            start_date: "2024-03-01",
            end_date: "2024-03-05"
        }
    };
    AddToCartResponse cartResponse1 = check ep->AddToCart(cartReq1);
    io:println("Add to Cart 1 Response: " + cartResponse1.toString());

    AddToCartRequest cartReq2 = {
        user_id: "customer1",
        item: {
            plate: "XYZ789",
            start_date: "2024-03-10",
            end_date: "2024-03-12"
        }
    };
    AddToCartResponse cartResponse2 = check ep->AddToCart(cartReq2);
    io:println("Add to Cart 2 Response: " + cartResponse2.toString() + "\n");

    //  Place reservations
    io:println("TEST 7: Placing reservations");
    User customer = {id: "customer1", name: "John Doe", role: "CUSTOMER"};
    PlaceReservationResponse reservationResponse = check ep->PlaceReservation(customer);
    io:println("Place Reservation Response: " + reservationResponse.toString() + "\n");

    // List all reservations (admin function)
    io:println("TEST 8: Listing all reservations");
    Empty emptyReq = {};
    stream<Reservation, grpc:Error?> reservationStream = check ep->ListReservations(emptyReq);
    io:println("All Reservations:");
    check reservationStream.forEach(function(Reservation reservation) {
        io:println("  - " + reservation.toString());
    });
    io:println("");

    //  Remove a car
    io:println("TEST 9: Removing a car");
    RemoveCarRequest removeReq = {plate: "XYZ789"};
    CarsList removeResponse = check ep->RemoveCar(removeReq);
    io:println("Remove Car Response - Remaining cars:");
    foreach Car car in removeResponse.cars {
        io:println("  - " + car.toString());
    }
    
    io:println("\n=== ALL TESTS COMPLETED SUCCESSFULLY! ===");
}

// Interactive mode for manual testing
function runInteractiveMode() returns error? {
    while true {
        io:println("\n=== Car Rental System ===");
        io:println("1. Admin Operations");
        io:println("2. Customer Operations"); 
        io:println("3. Exit");
        
        string choice = io:readln("Choose an option: ");
        
        match choice {
            "1" => { check adminMenu(); }
            "2" => { check customerMenu(); }
            "3" => { 
                io:println("Goodbye!");
                break;
            }
            _ => { io:println("Invalid choice!"); }
        }
    }
}

//  Admin menu with all admin operations
function adminMenu() returns error? {
    while true {
        io:println("\n--- Admin Menu ---");
        io:println("1. Add Car");
        io:println("2. Update Car");
        io:println("3. Remove Car");
        io:println("4. List All Reservations");
        io:println("5. Create Users");
        io:println("6. Back to Main Menu");
        
        string choice = io:readln("Choose an option: ");
        
        match choice {
            "1" => { check addCarInteractive(); }
            "2" => { check updateCarInteractive(); }
            "3" => { check removeCarInteractive(); }
            "4" => { check listReservationsInteractive(); }
            "5" => { check createUsersInteractive(); }
            "6" => { break; }
            _ => { io:println("Invalid choice!"); }
        }
    }
}

//  Customer menu with customer operations
function customerMenu() returns error? {
    string customerId = io:readln("Enter your customer ID: ");
    
    while true {
        io:println("\n--- Customer Menu ---");
        io:println("1. List Available Cars");
        io:println("2. Search Car");
        io:println("3. Add Car to Cart");
        io:println("4. Place Reservation");
        io:println("5. Back to Main Menu");
        
        string choice = io:readln("Choose an option: ");
        
        match choice {
            "1" => { check listAvailableCarsInteractive(); }
            "2" => { check searchCarInteractive(); }
            "3" => { check addToCartInteractive(customerId); }
            "4" => { check placeReservationInteractive(customerId); }
            "5" => { break; }
            _ => { io:println("Invalid choice!"); }
        }
    }
}

//  Interactive add car function
function addCarInteractive() returns error? {
    io:println("\n--- Add New Car ---");
    string plate = io:readln("Enter plate number: ");
    string make = io:readln("Enter make: ");
    string model = io:readln("Enter model: ");
    string yearStr = io:readln("Enter year: ");
    string priceStr = io:readln("Enter daily price: ");
    string mileageStr = io:readln("Enter mileage: ");
    
    int year = check int:fromString(yearStr);
    float price = check float:fromString(priceStr);
    int mileage = check int:fromString(mileageStr);
    
    Car car = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        daily_price: price,
        mileage: mileage,
        status: "AVAILABLE"
    };
    
    AddCarResponse response = check ep->AddCar(car);
    io:println("Result: " + response.message);
}

// Interactive update car function  
function updateCarInteractive() returns error? {
    io:println("\n--- Update Car ---");
    string plate = io:readln("Enter plate number to update: ");
    
    // Get current car first
    CarFilter searchReq = {text: plate};
    SearchResponse searchResp = check ep->SearchCar(searchReq);
    
    if !searchResp.found {
        io:println("Car not found!");
        return;
    }
    
    io:println("Current car: " + searchResp.car.toString());
    io:println("Enter new values (press Enter to keep current):");
    
    string make = io:readln("Make [" + searchResp.car.make + "]: ");
    string model = io:readln("Model [" + searchResp.car.model + "]: ");
    string yearStr = io:readln("Year [" + searchResp.car.year.toString() + "]: ");
    string priceStr = io:readln("Daily price [" + searchResp.car.daily_price.toString() + "]: ");
    string mileageStr = io:readln("Mileage [" + searchResp.car.mileage.toString() + "]: ");
    string status = io:readln("Status [" + searchResp.car.status + "]: ");
}