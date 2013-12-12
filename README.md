# API endpoints

* TransformResults `GET`, `POST` - http://../transform_results/
* Scores `GET`, `POST` - http://../scores/

# Models

### MediaObject
* id {int}
* type {string}
* attribute {object}
* items [MediaObjectItem]
* results [TransformResult]

```JSON
{
    "id": 1,
    "type": "image",
    "attributes": {
        "caption":"Image"
    },
    "items": [MediaObjectItem...],
    "results": [TransformResult...]
 }
```

### MediaObjectItem
* id {int}
* type {string}
* src {string}
* width {int}
* height {int}


```JSON
{
    "id": 1,
    "type": "image",
    "src": "http://.../image.png",
    "width": 1920,
    "height": 1200
}
```

### TransformResult
* id {int}
* type {string}
* data {object}
* mediaObject {int}

```JSON
{
    "id": 52,
    "type": "tag",
    "data": {
          "tag": "test"
    },
    "media_object": 1
}
```

### Score
* id {int}
* type {string}
* value {int}
* semanticValue {int}
* semanticValue {int}

```JSON
{
    "id": 52,
    "type": "tag",
    "data": {
          "tag": "test"
    },
    "media_object": 1
}
```

### TransformResults


`GET` **Request sample**

```
curl -v -X GET http://../transform_results/?state=098f6bcd4621d373cade4e832627b4f6
```

`GET` **Response sample**

```JSON
{
   "data":[
      {
         "id": 2,
         "type": "image",
         "attributes":{
            "caption":"Test"
         },
         "items":[
            {
               "id":2,
               "type":"image",
               "src":"http://.../image.png",
               "width":1600,
               "height":1200
            }
         ],
         "results":[
            {
               "id":53,
               "type":"tag",
               "data":{
                  "tag":"test"
               },
               "media_object":2
            }
         ],
      }
   ],
   "config":{

   }
}
```

`POST` **Request sample**

```
curl -v -X GET http://../transform_results/?state=098f6bcd4621d373cade4e832627b4f6 \
-d '[
    {
       "type":"tag",
       "data":{
          "tag":"test"
       },
       "media_object":2
    }
]'
```

`POST` **Response sample**

```
[
    {
      "id": 10,
      "type":"tag",
      "data":{
          "tag":"test"
      },
      "media_object":2
    }
]
```

### Scores


`GET` **Request sample**

```
curl -v -X GET http://../scores/?state=098f6bcd4621d373cade4e832627b4f6
```

`GET` **Response sample**

```JSON
{
   "data":[
      {
         "id": 2,
         "type": "image",
         "attributes":{
            "caption":"Test"
         },
         "items":[
            {
               "id":2,
               "type":"image",
               "src":"http://.../image.png",
               "width":1600,
               "height":1200
            }
         ],
         "results":[
            {
               "id":53,
               "type":"tag",
               "data":{
                  "tag":"test"
               },
               "media_object":2
            }
         ],
      }
   ],
   "config":{

   }
}
```

`POST` **Request sample**

```
curl -v -X GET http://../scores/?state=098f6bcd4621d373cade4e832627b4f6 \
-d '[
    {
        "type": "correctness",
        "transformResult": 2,
        "value": 1,
        "semanticValue": -1
    }
]'
```

`POST` **Response sample**

```
[
    {
        "id": 24,
        "type": "correctness",
        "transformResult": 2,
        "value": 1,
        "semanticValue": -1
    }
]
```