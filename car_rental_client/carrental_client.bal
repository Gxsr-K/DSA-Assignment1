import ballerina/io;

CarRentalClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    Car addCarRequest = {plate: "ballerina", make: "ballerina", model: "ballerina", year: 1, daily_price: 1, mileage: 1, status: "ballerina"};
    AddCarResponse addCarResponse = check ep->AddCar(addCarRequest);
    io:println(addCarResponse);

    UpdateCarRequest updateCarRequest = {plate: "ballerina", car: {plate: "ballerina", make: "ballerina", model: "ballerina", year: 1, daily_price: 1, mileage: 1, status: "ballerina"}};
    AddCarResponse updateCarResponse = check ep->UpdateCar(updateCarRequest);
    io:println(updateCarResponse);

    RemoveCarRequest removeCarRequest = {plate: "ballerina"};
    CarsList removeCarResponse = check ep->RemoveCar(removeCarRequest);
    io:println(removeCarResponse);

    CarFilter searchCarRequest = {text: "ballerina"};
    SearchResponse searchCarResponse = check ep->SearchCar(searchCarRequest);
    io:println(searchCarResponse);

    AddToCartRequest addToCartRequest = {user_id: "ballerina", item: {plate: "ballerina", start_date: "ballerina", end_date: "ballerina"}};
    AddToCartResponse addToCartResponse = check ep->AddToCart(addToCartRequest);
    io:println(addToCartResponse);

    User placeReservationRequest = {id: "ballerina", name: "ballerina", role: "ballerina"};
    PlaceReservationResponse placeReservationResponse = check ep->PlaceReservation(placeReservationRequest);
    io:println(placeReservationResponse);

    CarFilter listAvailableCarsRequest = {text: "ballerina"};
    stream<Car, error?> listAvailableCarsResponse = check ep->ListAvailableCars(listAvailableCarsRequest);
    check listAvailableCarsResponse.forEach(function(Car value) {
        io:println(value);
    });

    Empty listReservationsRequest = {};
    stream<Reservation, error?> listReservationsResponse = check ep->ListReservations(listReservationsRequest);
    check listReservationsResponse.forEach(function(Reservation value) {
        io:println(value);
    });

    User createUsersRequest = {id: "ballerina", name: "ballerina", role: "ballerina"};
    CreateUsersStreamingClient createUsersStreamingClient = check ep->CreateUsers();
    check createUsersStreamingClient->sendUser(createUsersRequest);
    check createUsersStreamingClient->complete();
    CreateUsersResponse? createUsersResponse = check createUsersStreamingClient->receiveCreateUsersResponse();
    io:println(createUsersResponse);
}
