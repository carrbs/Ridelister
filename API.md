# API Documentation for Ridelister

## GET Rides

GET Rides returns a paginated JSON list of rides in descending score order for a given driver.

Optional parameters allow the caller to:

- specify a proximity to search for rides, based on the given `driver_id`.
- request a specific page number
- customize the quantity of rides per page

### Request

`GET /api/v1/rides`

#### Parameters

---

| **`driver_id`** `int` (required) |
| -------------------------------- |
| The `id` of the driver.          |

---

| `proximity` `int` (optional)                                                      |
| --------------------------------------------------------------------------------- |
| The maximum distance (in miles) from the driver's home address to consider rides. |

---

| `page` `int` (optional)                     |
| ------------------------------------------- |
| The page number to retrieve. Defaults to 1. |

---

| `rides_per_page` `int` (optional)                      |
| ------------------------------------------------------ |
| The number of rides to return per page. Defaults to 5. |

#### Example

```bash
curl -X GET 'http://localhost:3000/api/v1/rides?driver_id=1&proximity=10&page=1&rides_per_page=5'
```

### Response

#### Success Response

**Condition** : When a valid request is processed, a JSON object is returned, which includes:

- `driver_address`: The address associated with the provided `driver_id`
- `rides`: An array of rides for the given page
- `total_pages`: an integer representing the total count of pages of rides for the given parameters

**Code** : `200 OK`

**Content example**

```json
{
  "driver_address": "111 SW 5th Ave, Portland, OR 97204",
  "rides": [
    {
      "id": 11,
      "start_address": "1005 W Burnside St, Portland, OR 97209",
      "destination_address": "1 N Center Ct St, Portland, OR 97227",
      "score": 1.25,
      "distance": 2.7961695,
      "duration": 6.3,
      "commute_distance": 0.505795994,
      "commute_duration": 3.316666666666667
    }
    // ... more rides ...
  ],
  "total_pages": 20
}
```

#### Error Responses

---

**`driver_id`**

**Condition** : If `driver_id` is not provided or is invalid.

**Code** : `400 BAD REQUEST`

**Content** : `"Invalid driver_id parameter, must be a positive integer"`

**Condition** : If no driver found with provided driver_id'

**Code** : `404 NOT FOUND`

**Content** : `"Driver (ID: <id-for-non-existent-driver>) not found"`

---

**`proximity`**

**Condition** : If optional `proximity` provided is invalid.

**Code** : `400 BAD REQUEST`

**Content** : `Invalid proximity parameter, must be a positive integer less than 100`

---

**`page`**

**Condition** : If the 'page' parameter is invalid.

**Code** : `400 BAD REQUEST`

**Content** : `"Invalid page number, must be a positive integer"`

---

**`rides_per_page`**

**Condition** : If the 'page' parameter is invalid.

**Code** : `400 BAD REQUEST`

**Content** : `"Invalid rides per page, must be a positive integer"`

---

Ridelister leverages the [ Google Directions API ](https://developers.google.com/maps/documentation/directions/overview) to find up-to-date directional information. If for any reason this service is unavailable, Ridelister will respond with an error, e.g.:

**Code** : `503 SERVICE UNAVAILABLE`

**Content** : `Unexpected response format from Google Directions API.`
