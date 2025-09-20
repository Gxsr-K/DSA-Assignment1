import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRental" on ep {

    remote function AddCar(Car value) returns AddCarResponse|error {
    }

    remote function UpdateCar(UpdateCarRequest value) returns AddCarResponse|error {
    }

    remote function RemoveCar(RemoveCarRequest value) returns CarsList|error {
    }

    remote function SearchCar(CarFilter value) returns SearchResponse|error {
    }

    remote function AddToCart(AddToCartRequest value) returns AddToCartResponse|error {
    }

    remote function PlaceReservation(User value) returns PlaceReservationResponse|error {
    }

    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
    }

    remote function ListAvailableCars(CarFilter value) returns stream<Car, error?>|error {
    }

    remote function ListReservations(Empty value) returns stream<Reservation, error?>|error {
    }
}
