# AsynchronousSwift

[![Version](https://img.shields.io/cocoapods/v/AsynchronousSwift.svg?style=flat)](http://cocoapods.org/pods/AsynchronousSwift)
[![License](https://img.shields.io/cocoapods/l/AsynchronousSwift.svg?style=flat)](http://cocoapods.org/pods/AsynchronousSwift)
[![Platform](https://img.shields.io/cocoapods/p/AsynchronousSwift.svg?style=flat)](http://cocoapods.org/pods/AsynchronousSwift)

## Description

**AsynchronousSwift** provides many tools for efficient asynchronous work based on [Grand Central Dispatch](https://developer.apple.com/documentation/dispatch).

Unlike other asynchronous libraries, **AsynchronousSwift** attempt to optimize the usage of threads to limit the number of [context switch](https://en.wikipedia.org/wiki/Context_switch).  
At the moment we can find different tools:  
- ThreadSafe
- Future & Promise
- Async & Await

## Usage
### ThreadSafe
#### Init
```swift
let threadSafeArray = ThreadSafe<[Int]>([0])
```
#### Value
```swift
let value = threadSafeArray.value // Safe only with Duplicable
threadSafeArray.value = [1]
threadSafeArray <- [1]
```

#### OnChange
```swift
threadSafeArray.onChange(on: .global(qos: .background)) { newValue in
   print("New Array : \(newValue)")
 }
```

#### ReadOnly
```swift
let count = threadSafeArray.readOnly.sync { value in value.count }
print("Array size : \(count)")

threadSafeArray.readOnly.async { value in
  print("Array size : \(value.count)")
}
```

#### ReadAndWrite
```swift
let element = threadSafeArray.readAndWrite.sync { value in value.remove(at: 0) }
print("First element was : \(element)")

threadSafeArray.readAndWrite.async { value in
  print("First element was : \(value.remove(at: 0))")
}
```

### Future & Promise
#### Promise
```swift
let promise = Promise<Int>()

let future = promise.reject(with: NSError(domain: "", code: 0))

let future = promise.resolve { 1 }
```

#### Future
```swift
let future = promise.future

future.then { value in /* code */ }
      .then(qos: .background) { value in /* code */ }
      .catch{ error in /* code */ }
      .finally { /* code */ }

let result = future.sync { value in return /* code */ }

future.isFulfilled
future.isPending
future.isRejected
```



### Async & Await
```swift
let future = async { return /* code */ }
result = try? await(future)
```
## Installation

AsynchronousSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AsynchronousSwift'
```

## License

AsynchronousSwift is available under the MIT license. See the LICENSE file for more info.
