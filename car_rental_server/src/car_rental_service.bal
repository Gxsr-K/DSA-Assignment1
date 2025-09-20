import ballerina/grpc;
import ballerina/log;
import ballerina/time;

// adjust this import if your generated stub file name is different
import car_rental_pb = ./car_rental_pb;

listener grpc:Listener grpcListener = new(9090);

map<car_rental_pb:Car> cars = {};
map<string> users = {};
map<string, car_rental_pb:CartItem[]> cartMap = {};
map<string, car_rental_pb:Reservation> reservationsMap = {};

function genId() returns string {
    int t = time:currentTime().time;
    return "res_" + t.toString();
}

function parseDate(string s) returns time:Time|error {
    string[] parts = s.split("-");
    if parts.length() != 3 {
        return error("invalid-date-format");
    }
    int|error y = int:fromString(parts[0]);
    if y is error { return y; }
    int|error m = int:fromString(parts[1]);
    if m is error { return m; }
    int|error d = int:fromString(parts[2]);
    if d is error { return d; }
    return time:createTime(y, m, d);
}

function daysBetween(string start, string end) returns int|error {
    time:Time|error s = parseDate(start);
    if s is error { return s; }
    time:Time|error e = parseDate(end);
    if e is error { return e; }
    int sMs = s.time;
    int eMs = e.time;
    if eMs < sMs { return error("end-before-start"); }
    int delta = (eMs - sMs) / 86400000;
    if delta == 0 { return 1; }
    return delta;
}

service /CarRental on grpcListener {

    remote function AddCar(car_rental_pb:Car req) returns car_rental_pb:AddCarResponse {
        if cars.hasKey(req.plate) {
            return { plate: req.plate, message: "car with plate already exists" };
        }
        cars[req.plate] = req;
        return { plate: req.plate, message: "added" };
    }

    remote function CreateUsers(stream<car_rental_pb:User> usersStream) returns car_rental_pb:CreateUsersResponse|error {
        int created = 0;
        while true {
            var next = usersStream.next();
            if next is car_rental_pb:User {
                users[next.id] = next.role;
                created += 1;
            } else if next is error {
                if next.message() == "EndOfStream" { break; }
                return error("stream-error: " + next.message());
            }
        }
        return { created: created, message: "done" };
    }

    remote function UpdateCar(car_rental_pb:UpdateCarRequest req) returns car_rental_pb:AddCarResponse {
        string plate = req.plate;
        if !cars.hasKey(plate) {
            return { plate: plate, message: "not found" };
        }
        car_rental_pb:Car old = cars[plate];
        car_rental_pb:Car updated = old;
        if req.car.make != "" { updated.make = req.car.make; }
        if req.car.model != "" { updated.model = req.car.model; }
        if req.car.year != 0 { updated.year = req.car.year; }
        if req.car.daily_price != 0.0 { updated.daily_price = req.car.daily_price; }
        if req.car.mileage != 0 { updated.mileage = req.car.mileage; }
        if req.car.status != "" { updated.status = req.car.status; }
        cars[plate] = updated;
        return { plate: plate, message: "updated" };
    }

    remote function RemoveCar(car_rental_pb:RemoveCarRequest req) returns car_rental_pb:CarsList {
        if cars.hasKey(req.plate) { cars.remove(req.plate); }
        car_rental_pb:CarsList out = { cars: [] };
        foreach var [_, c] in cars.entries() { out.cars.push(c); }
        return out;
    }

    remote function ListAvailableCars(car_rental_pb:CarFilter filter) returns stream<car_rental_pb:Car, error?>|error {
        stream<car_rental_pb:Car, error?> out = new;
        string f = filter.text.toLowerAscii();
        foreach var [_, c] in cars.entries() {
            if c.status.toUpperAscii() != "AVAILABLE" { continue; }
            if filter.text != "" {
                if !(c.make.toLowerAscii().contains(f) || c.model.toLowerAscii().contains(f) || c.plate.toLowerAscii().contains(f) || c.year.toString().contains(f)) {
                    continue;
                }
            }
            var send = out.next(c);
            if send is error { log:printError("stream send failed", send); }
        }
        check out.complete();
        return out;
    }

    remote function SearchCar(car_rental_pb:CarFilter req) returns car_rental_pb:SearchResponse {
        string q = req.text;
        if q == "" { return { found: false, available: false, message: "empty query" }; }
        if cars.hasKey(q) {
            car_rental_pb:Car c = cars[q];
            bool avail = c.status.toUpperAscii() == "AVAILABLE";
            return { found: true, available: avail, car: c, message: avail ? "available" : "not available" };
        }
        foreach var [_, c] in cars.entries() {
            if c.plate.toLowerAscii().contains(q.toLowerAscii()) {
                bool avail = c.status.toUpperAscii() == "AVAILABLE";
                return { found: true, available: avail, car: c, message: avail ? "available" : "not available" };
            }
        }
        return { found: false, available: false, message: "not found" };
    }

    remote function AddToCart(car_rental_pb:AddToCartRequest req) returns car_rental_pb:AddToCartResponse {
        string uid = req.user_id;
        car_rental_pb:CartItem it = req.item;
        if it.plate == "" || it.start_date == "" || it.end_date == "" {
            return { ok: false, message: "plate and dates required (YYYY-MM-DD)" };
        }
        if !cars.hasKey(it.plate) { return { ok: false, message: "car not found" }; }
        var d = daysBetween(it.start_date, it.end_date);
        if d is error { return { ok: false, message: "date error: " + d.message() }; }
        car_rental_pb:CartItem[] arr = [];
        if cartMap.hasKey(uid) { arr = cartMap[uid]; }
        arr.push(it);
        cartMap[uid] = arr;
        return { ok: true, message: "added to cart" };
    }

    remote function PlaceReservation(car_rental_pb:User user) returns car_rental_pb:PlaceReservationResponse {
        string uid = user.id;
        if !cartMap.hasKey(uid) { return { ok: false, message: "cart empty", reservations: [] }; }
        car_rental_pb:CartItem[] userCart = cartMap[uid];
        car_rental_pb:Reservation[] placed = [];
        foreach var item in userCart {
            if !cars.hasKey(item.plate) { return { ok: false, message: "car " + item.plate + " not found", reservations: [] }; }
            car_rental_pb:Car c = cars[item.plate];
            if c.status.toUpperAscii() != "AVAILABLE" { return { ok: false, message: "car " + item.plate + " not available", reservations: [] }; }
            var d = daysBetween(item.start_date, item.end_date);
            if d is error { return { ok: false, message: "date error: " + d.message(), reservations: [] }; }
            double price = d * c.daily_price;
            string rid = genId();
            car_rental_pb:Reservation r = { reservation_id: rid, user_id: uid, item: item, price: price };
            reservationsMap[rid] = r;
            placed.push(r);
            c.status = "UNAVAILABLE";
            cars[item.plate] = c;
        }
        cartMap.remove(uid);
        return { ok: true, message: "reserved", reservations: placed };
    }

    remote function ListReservations(car_rental_pb:Empty _) returns stream<car_rental_pb:Reservation, error?>|error {
        stream<car_rental_pb:Reservation, error?> out = new;
        foreach var [_, r] in reservationsMap.entries() {
            var send = out.next(r);
            if send is error { log:printError("stream send failed", send); }
        }
        check out.complete();
        return out;
    }
}
