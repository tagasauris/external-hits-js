# External HIT SDK

External HIT SDK its a pure JavaScript library for communication with Tagasauris API endpoints.
Its main aim is to simplify and accelerate the creation of new HIT types.

# API endpoints

* TransformResults `GET`, `POST` - http://../transform_results/
* Scores `GET`, `POST` - http://../scores/


# SDK Implementation

### 1. Create simple HTML document

```HTML
<!DOCTYPE html>
<html>
  <head>
    <title>External HIT: Example</title>
  </head>
  <body>
  </body>
</html>
```

### 2. Add our SDK and initialize the client

```HTML
<body>
<script src="http://.../child.min.js"></script>
<script type="text/javascript">
  var client = new Tagasauris.ChildClient();
</script>
</body>
```

### 3. Add some callbacks and listeners

```JavaScript
// Function is triggered when Parent sends "start" message
client.onStart = function() {
    // We are requesting data from API endpont
    client.getData(getDataCallback);
}

// Function is triggered when getData request is completed
var getDataCallback = function(err, response) {
    // if an error occurred we need to notify Parent
    if (err) {
      return client.error(err);
    }
    // In this place we should render data for mTurk user
}
```

`response` has two attributtes config and data. Data is an Array of `MediaObject` model and config is a simple JavaScript object.

### 4. Gathering data

We neeed to gather data from user and serialize them to SDK Model.
Depending on the endpoint is should be `TransformResult` or `Score` model.
Sample jQuery implementation gathering tags from the form inputs:

```JavaScript
var data = [];
$('input').each(function(input){
  var input  = $(this),
      mo     = input.attr('mo'),
      tags   = input.val().split(' ');

    tags.forEach(function(tag){
      var model = new Tagasauris.TransformResult({
        'type': 'tag',
        'mediaObject': parseInt(mo),
        'data': {'tag': tag}
      });

      data.push(model);
    });
});
```

### 5. Sending data
When we have ready our SDK models we need to send them to API endpoint

```JavaScript
client.saveData(data, function(err, response){
  // if an error occurred we need to notify Parent
  if (err) {
    return client.error(err);
  }

  // notifying Parent that everything went fine
  // from that point Parent will do the restt
  client.success();
});
```

### 6. More information

For more information checkout [examples](examples) folder.



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
* transformResult {int}

```JSON
{
    "id": 24,
    "type": "correctness",
    "transformResult": 2,
    "value": 1,
    "semanticValue": -1
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

```JSON
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

```JSON
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