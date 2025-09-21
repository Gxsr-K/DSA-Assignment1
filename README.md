# DSA612S Assignment 1 - Distributed Systems and Applications

**Course:** Distributed Systems and Applications (DSA612S)  
**Institution:** Namibia University of Science and Technology (NUST)  
**Assignment:** First Assignment  
**Released:** 27/08/2025  
**Due Date:** 21/09/2025 at 23:59  
**Total Marks:** 100  

---

##  Overview

This repository contains the implementation of **two distributed systems applications** using the **Ballerina programming language**:

1. **RESTful API for Asset Management System** (Question 1)  
2. **gRPC-based Car Rental System** (Question 2)  

The project demonstrates REST principles, gRPC remote invocation, streaming, and in-memory data management using maps/tables.

---

## Project Structure

```

DSA-Assignment1/
├── assessment\_management/              # Question 1: Asset Management System
│   ├── service.bal                     # RESTful API service implementation
│   └── client/
│       └── client.bal                  # REST API client application
├── carrental\_service/                  # Question 2: Car Rental System
│   └── carrental\_service\_service.bal   # gRPC server implementation
├── carrental\_client/
│   └── carrentalservice\_client.bal     # gRPC client application
└── README.md                           # Documentation file

````

---

##  Question 1: Asset Management System (RESTful API)

###  Description
A RESTful service for NUST’s **Facilities Directorate** to manage institutional assets such as laboratory equipment, servers, and vehicles. The system also handles components, maintenance schedules, work orders, and tasks.

###  Features
- **Asset Management**: Create, update, retrieve, delete assets  
- **Component Management**: Add/remove asset components  
- **Schedule Management**: Manage servicing schedules and due dates  
- **Work Orders & Tasks**: Open, update, close work orders and manage tasks  
- **Faculty Filtering**: Retrieve assets belonging to a specific faculty  
- **Overdue Tracking**: Detect assets with overdue maintenance  

###  API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/assets` | Retrieve all assets |
| GET    | `/assets/{assetTag}` | Get asset by tag |
| POST   | `/assets` | Create new asset |
| PUT    | `/assets/{assetTag}` | Update asset |
| DELETE | `/assets/{assetTag}` | Delete asset |
| GET    | `/assets/by-faculty/{facultyName}` | Filter assets by faculty |
| GET    | `/assets/overdue` | List assets with overdue schedules |
| POST   | `/assets/{assetTag}/components` | Add component |
| DELETE | `/assets/{assetTag}/components/{componentId}` | Remove component |
| POST   | `/assets/{assetTag}/schedules` | Add schedule |
| DELETE | `/assets/{assetTag}/schedules/{scheduleId}` | Remove schedule |
| POST   | `/assets/{assetTag}/workorders` | Add work order |
| PUT    | `/assets/{assetTag}/workorders/{workOrderId}` | Update work order |
| DELETE | `/assets/{assetTag}/workorders/{workOrderId}` | Remove work order |
| POST   | `/assets/{assetTag}/workorders/{workOrderId}/tasks` | Add task |
| DELETE | `/assets/{assetTag}/workorders/{workOrderId}/tasks/{taskId}` | Remove task |

###  Running the Service
```bash
# Start the service
cd assessment_management
bal run service.bal

# Run the client
cd assessment_management/client
bal run client.bal
````

---

##  Question 2: Car Rental System (gRPC)

###  Description

A **gRPC-based Car Rental System** supporting **Admin** and **Customer** roles. It enables real-time car inventory management, rental reservations, and streaming data between client and server.

###  User Roles

* **Admins**: Manage cars, users, reservations
* **Customers**: Browse cars, add to cart, place reservations

###  Features

#### Admin Operations

* Add, update, remove cars
* Batch user creation (streaming)
* View all reservations

#### Customer Operations

* Browse available cars (with filters)
* Search car by plate
* Add cars to rental cart with dates
* Place reservations and view history

###  gRPC Services

* **Unary RPCs**: `AddCar()`, `UpdateCar()`, `RemoveCar()`, `SearchCar()`, `AddToCart()`, `PlaceReservation()`, `ViewCart()`, `GetUserProfile()`
* **Streaming RPCs**: `CreateUsers()` (client streaming), `ListAvailableCars()` (server streaming), `ListAllReservations()` (server streaming)

###  Running the Service

```bash
# Start gRPC server
cd carrental_service
bal run carrental_service_service.bal

# Run the client
cd carrental_client
bal run carrentalservice_client.bal
```

---

##  Technical Implementation

* **Language**: Ballerina Swan Lake
* **Protocols**: REST (HTTP/JSON), gRPC (Protocol Buffers)
* **Storage**: In-memory maps/tables
* **Patterns**: RESTful design, gRPC streaming, CRUD operations
* **Error Handling**: Validation & structured error responses

---

##  Testing

* **Asset Management Client**: Tests CRUD, filtering, and relationships
* **Car Rental Client**: Interactive menus for Admin & Customer roles

---

##  Assignment Requirements Compliance

### Question 1 (50 marks)

* Working Solution (7)
* Service Implementation (35)
* Client Implementation (10)

### Question 2 (50 marks)

*  Protocol Buffer Contract (15)
*  gRPC Client (10)
*  gRPC Server (25)

**Total:** 100 Marks

---

## 👥 Group Members

* Rejoice Kaulumah – 224061135
* Prince-Lee Shigwedha – 224029126
* Jian Cloete – 224063561
* Mitchum Winston Januarie – 221049924
* Kiami L. Q. Quinga – 224008714
* Kuze Mulanda – 224070770

Group contributions are tracked through Git commits. Each member’s participation is visible in the commit history.

---
# DSA-Assignment1
