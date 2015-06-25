//
//  UIImage.swift
//  Deferred
//
//  Created by Giles Van Gruisen on 6/25/15.
//  Copyright (c) 2015 Remarkable.io. All rights reserved.
//

let NetworkQueue = dispatch_queue_create("com.gilesvangruisen.deferred.networkQueue", DISPATCH_QUEUE_SERIAL)

public extension NSData {

    public class func deferred(url: NSURL?) -> Deferred<NSData> {

        let deferred = Deferred<NSData>()

        // Make async
        dispatch_async(NetworkQueue) {
            if let url = url {

                // Make request
                if let data = NSData(contentsOfURL: url) {

                    // Resolve
                    deferred.resolve(data)
                } else {

                    // Invalid URL
                    deferred.reject(NSError(domain: "Deferred NSData", code: 0, userInfo: ["Invalid URL": url]))
                }
            } else {

                // Empty optional
                deferred.reject(NSError(domain: "Deferred NSData", code: 0, userInfo: ["No URL": url as! AnyObject]))
            }
        }

        return deferred
    }

}

public extension UIImage {

    public class func deferred(url: NSURL?) -> Deferred<UIImage> {

        return NSData.deferred(url).then({ data -> Deferred<UIImage> in

            let deferred = Deferred<UIImage>()

            if let image = UIImage(data: data) {

                // Resolve
                deferred.resolve(image)
            } else {

                // Invalid image data
                deferred.reject(NSError(domain: "Deferred NSData", code: 0, userInfo: ["Invalid image": data as AnyObject]))
            }
            
            return deferred
            
        })
    }
    
}