# AMLoggerManager

A simple tool used to read logs in an application without the need to connect the device to your Mac. 
Present the controller with a simple gesture and read your logs. You can share them with a simple left swipe on the cell.

![AMLoggerController example](https://github.com/DungeonDev78/AMLoggerManager/blob/master/img001.jpg)

## Installation

Copy the Swift file included in the repo in your project.


## Usage

Create a string with the desired log, ie in your Network Manager:

```
/// Log all the needed parameters of the Request and the relative Response
///
/// - Parameter request: the request needed
func logServiceWith(request: SWRequestable) {
    var log = ("*** BEGIN REQUEST ***\n")
    if let urlRequest = request.urlRequest {
        log += "URL: \(urlRequest)\n"
    }
    log += "HTTP METHOD: \(request.httpMethod.rawValue)\n"

    if let params = request.params {
        log += "PARAMS: \(params)\n"
    }
    log += ("*** END REQUEST: ***\n\n")

    manager?.request(request).responseString { (response) in
        log += ("*** BEGIN RESPONSE ***\n")
        if response.result.isSuccess {
            if let value = response.result.value {
                log += "\(value)\n"
            }
        }
        log += ("*** END RESPONSE: ***\n")
    }
}
```

Add you log string to the manager:
```
AMLoggerManager.shared.add(log)
```

And finally enable the logger in the UIViewController you want:
```
override func viewDidLoad() {
        enableLoggerController()
}
```

You can also use an optional title:
```
AMLoggerManager.shared.configure(title: "NEW TITLE")
```

The default gesture is a **UIScreenEdgePanGesture** but you can configure it as pleased:
```
let tapGesture = UITapGestureRecognizer()
tapGesture.numberOfTapsRequired = 2
tapGesture.numberOfTouchesRequired = 2
AMLoggerManager.shared.configure(gesture: tapGesture)
```


## Author

* **Alessandro "DungeonDev78" Manilii**

## License

This project is licensed under the MIT License
