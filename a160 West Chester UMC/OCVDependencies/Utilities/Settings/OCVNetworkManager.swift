////
////  OCVNetworkerManager.swift
////  OCVSwift
////
////  Created by Eddie Seay on 1/12/16.
////  Copyright © 2016 OCV,LLC. All rights reserved.
////
//
//import Foundation
//import Alamofire
//import SVProgressHUD
//
//class OCVNetworkManager {
//
//    var taskQueue: [Alamofire.Request] = []
//
//    init() { UIApplication.shared.isNetworkActivityIndicatorVisible = true }
//
//    deinit { self.taskComplete() }
//
//    func downloadDataWithURLCompletionHandler(_ urlIn: String, showProgress: Bool, resultData: @escaping ([String: AnyObject?]) -> Void) -> Void {
//        if showProgress == true {
//            SVProgressHUD.show(withStatus: "Loading")
//        }
//        let newRequest = Alamofire.request(urlIn)
//            .responseJSON { response in switch response.result {
//                case .success(_):
//                guard let jsonData = response.data else {
//                    break
//                }
//                resultData(self.saveFile(response.response?.statusCode ?? 500, path: urlIn, jsonData: jsonData))
//
//                case .failure(let error):
//                print("Request failed with error: \(error)")
//                resultData(self.handleError(error.code, path: urlIn))
//                }
//        }
//            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//                if totalBytesExpectedToRead != -1 {
//                    let currentProgress = Double(totalBytesRead) / Double(totalBytesExpectedToRead)
//                    dispatch_async(dispatch_get_main_queue()) {
//                        if showProgress == true {
//                            SVProgressHUD.showProgress(Float(currentProgress), status: "Loading")
//                        }
//                    }
//                }
//        }
//        taskQueue.append(newRequest)
//    }
//
//    func apiRequest(_ urlPath: String, httpMethod: Alamofire.HTTPMethod, parameters: [String: AnyObject], showProgress: Bool, resultData: @escaping ([String: AnyObject?]) -> Void) {
//        if showProgress == true {
//            SVProgressHUD.show(withStatus: "Loading")
//        }
//        let apiParams = OCVAppUtilities.SharedInstance.apiParamsPlus(parameters)
//        let urlString = "https://api.myocv.com\(urlPath)"
//        let newRequest = Alamofire.request(urlString, method: httpMethod, parameters: apiParams)
//            .responseJSON { response in switch response.result {
//                case .success(_):
//                guard let jsonData = response.data else {
//                    break
//                }
//                if response.response?.statusCode == 500 {
//                    print(response.result.debugDescription)
//                    SVProgressHUD.showError(withStatus: "Error: 500")
//                }
//                resultData(self.saveFile(response.response?.statusCode ?? 500, path: urlString, jsonData: jsonData))
//
//                case .failure(let error):
//                print("Request failed with error: \(error)")
//                resultData(self.handleError(error._code, path: urlString))
//                }
//        }
////        print(newRequest.debugDescription)
//        taskQueue.append(newRequest)
//    }
//
//    // MARK: Helper Methods
//    func saveFile(_ code: Int, path: String, jsonData: Data) -> [String: AnyObject?] {
//        self.taskComplete()
//        if code == 200 {
//            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
//                try? jsonData.write(to: URL(fileURLWithPath: self.createFilePathWithExtention(path, ext: "json")), options: [.atomic])
//            })
//        }
//        return ["completionType": "SUCCESS" as Optional<AnyObject>, "data": jsonData as Optional<AnyObject>, "statusCode": code as Optional<AnyObject>]
//    }
//
//    func handleError(_ code: Int, path: String) -> [String: AnyObject?] {
//        self.taskComplete()
//        if code != 999 {
//            let filePath = self.createFilePathWithExtention(path, ext: "json")
//            return ["completionType": "FAILURE" as Optional<AnyObject>, "data": (try? Data(contentsOf: URL(fileURLWithPath: filePath))) ?? nil]
//        }
//
//        return ["completionType": "UNKNOWN ERROR" as Optional<AnyObject>, "data": nil]
//    }
//
//    func taskComplete() {
//        OCVAppUtilities.finishTask()
//        if taskQueue.count > 1 {
//            taskQueue.removeLast()
//        }
//    }
//
//    func cancelAllRequests() {
//        for request in taskQueue {
//            request.cancel()
//        }
//        taskQueue = []
//        print("All requests canceled")
//    }
//
//    func removeSpecialCharsFromString(_ text: String) -> String {
//        let okayChars: Set<Character> =
//            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-_".characters)
//        return String(text.characters.filter { okayChars.contains($0) })
//    }
//
//    func createFilePathWithExtention(_ nameIn: String, ext: String) -> String {
//        let fileName = self.removeSpecialCharsFromString(nameIn)
//        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let filePath = "/\(dirPath)/\(fileName).\(ext)"
//
//        return filePath
//    }
//}
