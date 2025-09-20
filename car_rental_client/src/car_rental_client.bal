import ballerina/io;
import ballerina/grpc;
import ballerina/log;

// change import path if your generated stub file has a different path/name
import car_rental_pb = ./car_rental_pb;

public function main() returns error? {
    car_rental_pb:CarRentalClient client = check new("http://localhost:9090");

    // Add a sample car
    var add = client->AddCar({ plate: "ABC123", make: "Toyota", model: "Corolla", year: 2020, daily_price: 30.0, mileage: 50000, status: "AVAILABLE" });
    io:println("AddCar result -> ", add);

    // Create users via client-streaming
    stream<car_rental_pb:User, error?> s = new;
    check s.next({ id: "u1", name: "Alice", role: "CUSTOMER" });
    check s.next({ id: "admin1", name: "Sam", role: "ADMIN" });
    check s.complete();
    var created = client->CreateUsers(s);
    io:println("CreateUsers -> ", created);

    // List available cars
    var availStream = client->ListAvailableCars({ text: "" });
    if availStream is stream<car_rental_pb:Car, error?> {
        while true {
            var n = availStream.next();
            if n is car_rental_pb:Car { io:println("Car:", n.plate, n.make, n.model, n.daily_price.toString()); }
            else if n is error {
                if n.message() == "EndOfStream" { break; }
                io:println("stream error:", n);
                break;
            }
        }
    }

    // Add to cart and place reservation
    var atc = client->AddToCart({ user_id: "u1", item: { plate: "ABC123", start_date: "2025-10-01", end_date: "2025-10-03" }});
    io:println("AddToCart ->", atc);

    var res = client->PlaceReservation({ id: "u1", name: "Alice", role: "CUSTOMER" });
    io:println("PlaceReservation ->", res);

    // List reservations
    var rstream = client->ListReservations({});
    if rstream is stream<car_rental_pb:Reservation, error?> {
        while true {
            var n = rstream.next();
            if n is car_rental_pb:Reservation { io:println("Reservation:", n.reservation_id, n.item.plate, n.price.toString()); }
            else if n is error {
                if n.message() == "EndOfStream" { break; }
                io:println("stream error:", n);
                break;
            }
        }
    }
}
