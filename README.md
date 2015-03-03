# Deferred

Simple, straightforward, promise library written in Swift.

A promise represents the eventual value or error that is provided by an asynchronous function. To interact with this eventual value or error, we give the promise a new callback by calling `then` with a fulfilled and a rejected block.

## Basic usage

In this example, assume `fetchName` is some function that returns a promise. The promise will be either fulfilled with a name (`String`) if the async operation completes, or rejected with an error (`NSError`) if async operation fails.

```Swift
fetchName.then({ (name: String) in
  // fetched name successfully
  println("Hello, \(name)!")
}, { (error: NSError) in
  // failed to fetch name
  println(error)
})
```
