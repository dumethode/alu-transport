# ALU Transport: Entity Relationship Diagram

The diagram matches the Firestore collections exactly. Field names in the
diagram are the field names in Firestore and in the `toMap()` methods.

```mermaid
erDiagram
    USERS {
        string uid PK "document id = Firebase Auth uid"
        string fullName
        string email
        string role "student or driver"
        string pickupPointId FK "students only"
        string avatarSeed "DiceBear avatar seed"
        timestamp createdAt
        timestamp updatedAt
    }
    REMINDERS {
        string roundId PK "document id, also FK to ROUNDS"
        timestamp createdAt
    }
    PICKUP_POINTS {
        string id PK "document id, e.g. kimironko"
        string name
        int order "position on the route"
        int minutesFromCampus
    }
    ROUNDS {
        string id PK "auto id"
        string label
        string period "morning or evening"
        timestamp departureTime
        array stopIds FK "ordered PICKUP_POINTS ids"
        string status "planned, on_the_way, at_stop, delayed, full, ended"
        int currentStopIndex
        int seatsTotal
        int seatsLeft
        string driverId FK
        string note
        timestamp createdAt
        timestamp updatedAt
    }
    STATUS_UPDATES {
        string id PK "auto id"
        string roundId FK
        string driverId FK
        string type "leaving_campus, at_pickup, delayed, bus_full, round_ended, no_more_rounds"
        string stopId FK "set for at_pickup"
        string note
        timestamp createdAt
    }
    UPDATE_REQUESTS {
        string id PK "auto id"
        string roundId FK
        string studentId FK
        string pickupPointId FK
        string status "open or answered"
        string reply
        timestamp createdAt
        timestamp answeredAt
    }
    DRIVER_WHITELIST {
        string email PK "document id, lower case"
    }

    USERS ||--o{ REMINDERS : "sets (sub-collection users/uid/reminders)"
    ROUNDS ||--o{ REMINDERS : "is reminded in"
    PICKUP_POINTS ||--o{ USERS : "is the pickup of"
    USERS ||--o{ ROUNDS : "drives"
    PICKUP_POINTS }o--o{ ROUNDS : "is a stop of"
    ROUNDS ||--o{ STATUS_UPDATES : "has"
    USERS ||--o{ STATUS_UPDATES : "posts"
    PICKUP_POINTS ||--o{ STATUS_UPDATES : "is reported at"
    ROUNDS ||--o{ UPDATE_REQUESTS : "receives"
    USERS ||--o{ UPDATE_REQUESTS : "asks"
    PICKUP_POINTS ||--o{ UPDATE_REQUESTS : "is asked from"
    DRIVER_WHITELIST ||--o| USERS : "approves driver role"
```

## How the ERD maps to Firestore

| Entity           | Firestore path                    | Who can write (see `firestore.rules`)                                   |
| ---------------- | --------------------------------- | ----------------------------------------------------------------------- |
| USERS            | `users/{uid}`                     | Only the owner. Role and email cannot change after setup.               |
| REMINDERS        | `users/{uid}/reminders/{roundId}` | Only the owner. Doc id = round id, so no duplicates.                    |
| PICKUP_POINTS    | `pickup_points/{id}`              | Drivers only. Everyone signed in can read.                              |
| ROUNDS           | `rounds/{id}`                     | The driver who owns the round. Seats must stay between 0 and the total. |
| STATUS_UPDATES   | `status_updates/{id}`             | Drivers create and delete their own; nobody edits.                      |
| UPDATE_REQUESTS  | `update_requests/{id}`            | Students create and delete their own; the driver can only add a reply.  |
| DRIVER_WHITELIST | `driver_whitelist/{email}`        | Nobody from the app. The transport office adds emails in the console.   |

No data is copied between collections. Names (stop name, round name, driver
name) are looked up by id when a screen shows them.

## Indexes

Two composite indexes are in `firestore.indexes.json`:

1. `update_requests`: `status` ascending, `createdAt` descending (driver's open requests).
2. `update_requests`: `studentId` ascending, `createdAt` descending (a student's own requests).

All other queries use one field only, which Firestore indexes automatically.
