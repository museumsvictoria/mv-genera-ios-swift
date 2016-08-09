//
//  Constants.swift
//  genera-swift
//
//  Created by Simon Sherrin on 21/01/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import Foundation

struct NotificationType {
    
    static let DidRefreshDatabase = "DidRefreshDatabaseNotificationName"
    static let DataUpdateAvailable = "DataUpdateAvailable"
    static let DataUpdateFinished = "DataUpdateFinished"
    static let DataUpdateInformation = "DataUpdateInformation"
    static let AppReadyToCheckForUpdates = "AppReadyToCheckForUpdates"
    static let DatabaseBeingBuilt = "DatabaseBeingBuilt"
    static let DatabaseBuildFinished = "DatabaseBuildFinished"
    static let DatabasePercentComplete = "DatabasePercentComplete"
}

class LocalDefaults {
    var hasGallery:Bool = true
    
    static let sharedInstance = LocalDefaults()
    
}