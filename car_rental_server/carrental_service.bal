import ballerina/grpc;
import ballerina/log;
import ballerina/time;

public const string CAR_RENTAL_DESC = "0A106361725F72656E74616C2E70726F746F120963617272656E74616C22AC010A0343617212140A05706C6174651801200128095205706C61746512120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121F0A0B6461696C795F7072696365180520012801520A6461696C79507269636512180A076D696C6561676518062001280552076D696C6561676512160A067374617475731807200128095206737461747573223E0A0455736572120E0A0269641801200128095202696412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6522490A134372656174655573657273526573706F6E736512180A076372656174656418012001280552076372656174656412180A076D65737361676518022001280952076D65737361676522400A0E416464436172526573706F6E736512140A05706C6174651801200128095205706C61746512180A076D65737361676518022001280952076D657373616765224A0A105570646174654361725265717565737412140A05706C6174651801200128095205706C61746512200A0363617218022001280B320E2E63617272656E74616C2E436172520363617222280A1052656D6F76654361725265717565737412140A05706C6174651801200128095205706C617465222E0A08436172734C69737412220A046361727318012003280B320E2E63617272656E74616C2E436172520463617273221F0A0943617246696C74657212120A04746578741801200128095204746578742280010A0E536561726368526573706F6E736512140A05666F756E641801200128085205666F756E64121C0A09617661696C61626C651802200128085209617661696C61626C6512200A0363617218032001280B320E2E63617272656E74616C2E436172520363617212180A076D65737361676518042001280952076D657373616765225A0A08436172744974656D12140A05706C6174651801200128095205706C617465121D0A0A73746172745F64617465180220012809520973746172744461746512190A08656E645F646174651803200128095207656E644461746522540A10416464546F436172745265717565737412170A07757365725F6964180120012809520675736572496412270A046974656D18022001280B32132E63617272656E74616C2E436172744974656D52046974656D223D0A11416464546F43617274526573706F6E7365120E0A026F6B18012001280852026F6B12180A076D65737361676518022001280952076D657373616765228C010A0B5265736572766174696F6E12250A0E7265736572766174696F6E5F6964180120012809520D7265736572766174696F6E496412170A07757365725F6964180220012809520675736572496412270A046974656D18032001280B32132E63617272656E74616C2E436172744974656D52046974656D12140A057072696365180420012801520570726963652280010A18506C6163655265736572766174696F6E526573706F6E7365120E0A026F6B18012001280852026F6B12180A076D65737361676518022001280952076D657373616765123A0A0C7265736572766174696F6E7318032003280B32162E63617272656E74616C2E5265736572766174696F6E520C7265736572766174696F6E7322070A05456D70747932D3040A0943617252656E74616C12330A06416464436172120E2E63617272656E74616C2E4361721A192E63617272656E74616C2E416464436172526573706F6E736512400A0B4372656174655573657273120F2E63617272656E74616C2E557365721A1E2E63617272656E74616C2E4372656174655573657273526573706F6E7365280112430A09557064617465436172121B2E63617272656E74616C2E557064617465436172526571756573741A192E63617272656E74616C2E416464436172526573706F6E7365123D0A0952656D6F7665436172121B2E63617272656E74616C2E52656D6F7665436172526571756573741A132E63617272656E74616C2E436172734C697374123B0A114C697374417661696C61626C654361727312142E63617272656E74616C2E43617246696C7465721A0E2E63617272656E74616C2E4361723001123C0A0953656172636843617212142E63617272656E74616C2E43617246696C7465721A192E63617272656E74616C2E536561726368526573706F6E736512460A09416464546F43617274121B2E63617272656E74616C2E416464546F43617274526571756573741A1C2E63617272656E74616C2E416464546F43617274526573706F6E736512480A10506C6163655265736572766174696F6E120F2E63617272656E74616C2E557365721A232E63617272656E74616C2E506C6163655265736572766174696F6E526573706F6E7365123E0A104C6973745265736572766174696F6E7312102E63617272656E74616C2E456D7074791A162E63617272656E74616C2E5265736572766174696F6E3001620670726F746F33";

listener grpc:Listener ep = new (9090);

//  In-memory storage using the correct types from your protobuf
map<Car> cars = {};
map<string> users = {}; 
map<CartItem[]> userCarts = {}; 
map<Reservation> reservations = {}; 

//  Helper function to generate unique IDs
function generateId() returns string {
    time:Utc currentTime = time:utcNow();
    return "res_" + currentTime[0].toString();
}

//  Date validation helper
function isValidDateFormat(string date) returns boolean {
    string[] parts = re `-`.split(date);
    return parts.length() == 3;
}

//  Calculate days between dates (simplified)
function calculateDays(string startDate, string endDate) returns int {
    
    return 1;
}

@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRental" on ep {

    //  Implement AddCar with proper validation
    remote function AddCar(Car value) returns AddCarResponse|error {
        log:printInfo("Adding car: " + value.plate);
        
        // Check if car already exists
        if cars.hasKey(value.plate) {
            return {plate: value.plate, message: "Car with this plate already exists"};
        }
        
        // Validate required fields
        if value.plate == "" || value.make == "" || value.model == "" {
            return {plate: value.plate, message: "Invalid car data - plate, make, and model are required"};
        }
        
        // Set default status if empty
        Car newCar = value;
        if newCar.status == "" {
            newCar.status = "AVAILABLE";
        }
        
        // Store the car
        cars[value.plate] = newCar;
        log:printInfo("Car added successfully: " + value.plate);
        
        return {plate: value.plate, message: "Car added successfully"};
    }

    //  Implement UpdateCar with field-by-field updates
    remote function UpdateCar(UpdateCarRequest value) returns AddCarResponse|error {
        log:printInfo("Updating car: " + value.plate);
        
        // Check if car exists
        if !cars.hasKey(value.plate) {
            return {plate: value.plate, message: "Car not found"};
        }
        
        // Get existing car and create updated version
        Car existingCar = cars[value.plate];
        Car updatedCar = existingCar.clone();
        
        // Update only non-empty/non-zero fields
        if value.car.make != "" { updatedCar.make = value.car.make; }
        if value.car.model != "" { updatedCar.model = value.car.model; }
        if value.car.year != 0 { updatedCar.year = value.car.year; }
        if value.car.daily_price != 0.0 { updatedCar.daily_price = value.car.daily_price; }
        if value.car.mileage != 0 { updatedCar.mileage = value.car.mileage; }
        if value.car.status != "" { updatedCar.status = value.car.status; }
        
        // Save updated car
        cars[value.plate] = updatedCar;
        log:printInfo("Car updated successfully: " + value.plate);
        
        return {plate: value.plate, message: "Car updated successfully"};
    }

    //  Implement RemoveCar and return updated inventory
    remote function RemoveCar(RemoveCarRequest value) returns CarsList|error {
        log:printInfo("Removing car: " + value.plate);
        
        // Remove car if exists
        if cars.hasKey(value.plate) {
            _ = cars.remove(value.plate);
            log:printInfo("Car removed: " + value.plate);
        }
        
        // Return all remaining cars
        Car[] remainingCars = [];
        foreach Car car in cars {
            remainingCars.push(car);
        }
        
        return {cars: remainingCars};
    }

    //  Implement SearchCar with partial matching
    remote function SearchCar(CarFilter value) returns SearchResponse|error {
        log:printInfo("Searching for car: " + value.text);
        
        string searchText = value.text.toLowerAscii();
        
        if searchText == "" {
            return {
                found: false,
                available: false,
                message: "Search text cannot be empty",
                car: {plate: "", make: "", model: "", year: 0, daily_price: 0.0, mileage: 0, status: ""}
            };
        }
        
        // Try exact plate match first
        if cars.hasKey(value.text) {
            Car foundCar = cars[value.text];
            boolean isAvailable = foundCar.status == "AVAILABLE";
            return {
                found: true,
                available: isAvailable,
                message: isAvailable ? "Car found and available" : "Car found but not available",
                car: foundCar
            };
        }
        
        // Try partial matching
        foreach Car car in cars {
            string carDetails = (car.plate + " " + car.make + " " + car.model).toLowerAscii();
            if carDetails.includes(searchText) {
                boolean isAvailable = car.status == "AVAILABLE";
                return {
                    found: true,
                    available: isAvailable,
                    message: isAvailable ? "Car found and available" : "Car found but not available",
                    car: car
                };
            }
        }
        
        return {
            found: false,
            available: false,
            message: "No car found matching the search criteria",
            car: {plate: "", make: "", model: "", year: 0, daily_price: 0.0, mileage: 0, status: ""}
        };
    }

    //  Implement AddToCart with comprehensive validation
    remote function AddToCart(AddToCartRequest value) returns AddToCartResponse|error {
        log:printInfo("Adding to cart for user: " + value.user_id);
        
        // Validate user ID
        if value.user_id == "" {
            return {ok: false, message: "User ID is required"};
        }
        
        // Validate car exists
        if !cars.hasKey(value.item.plate) {
            return {ok: false, message: "Car not found"};
        }
        
        // Check car availability
        Car car = cars[value.item.plate];
        if car.status != "AVAILABLE" {
            return {ok: false, message: "Car is not available for rental"};
        }
        
        // Validate dates
        if !isValidDateFormat(value.item.start_date) || !isValidDateFormat(value.item.end_date) {
            return {ok: false, message: "Invalid date format. Use YYYY-MM-DD"};
        }
        
        if value.item.start_date >= value.item.end_date {
            return {ok: false, message: "Start date must be before end date"};
        }
        
        // Add to user's cart
        CartItem[] currentCart = [];
        if userCarts.hasKey(value.user_id) {
            currentCart = userCarts[value.user_id];
        }
        
        currentCart.push(value.item);
        userCarts[value.user_id] = currentCart;
        
        log:printInfo("Item added to cart for user: " + value.user_id);
        return {ok: true, message: "Item added to cart successfully"};
    }

    //  Implement PlaceReservation with conflict checking and pricing
    remote function PlaceReservation(User value) returns PlaceReservationResponse|error {
        log:printInfo("Placing reservation for user: " + value.id);
        
        // Check if user has items in cart
        if !userCarts.hasKey(value.id) || userCarts[value.id].length() == 0 {
            return {
                ok: false,
                message: "Cart is empty",
                reservations: []
            };
        }
        
        CartItem[] cartItems = userCarts[value.id];
        Reservation[] newReservations = [];
        
        // Process each cart item
        foreach CartItem item in cartItems {
            // Verify car still exists and is available
            if !cars.hasKey(item.plate) {
                return {
                    ok: false,
                    message: "Car " + item.plate + " no longer exists",
                    reservations: []
                };
            }
            
            Car car = cars[item.plate];
            if car.status != "AVAILABLE" {
                return {
                    ok: false,
                    message: "Car " + item.plate + " is no longer available",
                    reservations: []
                };
            }
            
            // Calculate price
            int days = calculateDays(item.start_date, item.end_date);
            float totalPrice = <float>days * car.daily_price;
            
            // Create reservation
            string reservationId = generateId();
            Reservation newReservation = {
                reservation_id: reservationId,
                user_id: value.id,
                item: item,
                price: totalPrice
            };
            
            // Store reservation
            reservations[reservationId] = newReservation;
            newReservations.push(newReservation);
            
            // Update car status to RENTED
            Car updatedCar = car.clone();
            updatedCar.status = "RENTED";
            cars[item.plate] = updatedCar;
        }
        
        // Clear user's cart
        userCarts[value.id] = [];
        
        log:printInfo("Reservations placed successfully for user: " + value.id);
        return {
            ok: true,
            message: "Reservations placed successfully",
            reservations: newReservations
        };
    }

    //  Implement CreateUsers with streaming and validation
    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        log:printInfo("Creating users via streaming...");
        int createdCount = 0;
        
        error? result = clientStream.forEach(function(User user) {
            // Validate user data
            if user.id == "" {
                log:printError("User creation failed: empty user ID");
                return;
            }
            
            // Validate role
            if user.role != "ADMIN" && user.role != "CUSTOMER" {
                log:printError("User creation failed: invalid role for user " + user.id);
                return;
            }
            
            // Store user
            users[user.id] = user.role;
            userCarts[user.id] = []; // Initialize empty cart
            
            createdCount += 1;
            log:printInfo("User created: " + user.id + " with role: " + user.role);
        });
        
        if result is error {
            return error("Error processing user stream: " + result.message());
        }
        
        return {created: createdCount, message: "Users created successfully"};
    }

    //  Implement ListAvailableCars with filtering and streaming
    remote function ListAvailableCars(CarFilter value) returns stream<Car, error?>|error {
        log:printInfo("Listing available cars with filter: " + value.text);
        
        Car[] availableCars = [];
        string filterText = value.text.toLowerAscii();
        
        foreach Car car in cars {
            // Only include available cars
            if car.status != "AVAILABLE" {
                continue;
            }
            
            // Apply filter if provided
            if filterText != "" {
                string carInfo = (car.make + " " + car.model + " " + car.plate + " " + car.year.toString()).toLowerAscii();
                if !carInfo.includes(filterText) {
                    continue;
                }
            }
            
            availableCars.push(car);
        }
        
        log:printInfo("Found " + availableCars.length().toString() + " available cars");
        return availableCars.toStream();
    }

    // Implement ListReservations for admin users
    remote function ListReservations(Empty value) returns stream<Reservation, error?>|error {
        log:printInfo("Listing all reservations");
        
        Reservation[] allReservations = [];
        
        foreach Reservation reservation in reservations {
            allReservations.push(reservation);
        }
        
        log:printInfo("Found " + allReservations.length().toString() + " reservations");
        return allReservations.toStream();
    }
}
