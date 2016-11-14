//
//  OCVNetworkClient.swift
//  OCVSwift
//
//  Created by Eddie Seay on 5/2/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import Alamofire
import SVProgressHUD

class OCVNetworkClient {

    var taskQueue: [Alamofire.Request] = []
    
    init() { UIApplication.shared.isNetworkActivityIndicatorVisible = true }
    deinit { self.taskComplete() }

    func downloadFrom(url: String, showProgress: Bool, completion: @escaping (_ data: Data?, _ code: Int) -> Void) {
        if showProgress { SVProgressHUD.show(withStatus: "Loading") }
        Alamofire.request(url).responseData { response in
            SVProgressHUD.dismiss()
            completion(response.result.value, response.response?.statusCode ?? 999)
        }
        .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
            if showProgress {
                SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Loading")
            }
        }
    }
    
    func apiRequest(atPath: String, httpMethod: Alamofire.HTTPMethod, parameters: Parameters, showProgress: Bool, completion: @escaping (_ data: Data?, _ code: Int) -> Void) {
        Alamofire.request("https://api.myocv.com\(atPath)", method: httpMethod, parameters: parameters, encoding: JSONEncoding.default).validate()
            .responseData { response in
                completion(response.result.value, response.response?.statusCode ?? 999)
            }
            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                if showProgress {
                    SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Loading")
                }
            }
    }

//    func responseCode(_ code: Int?) -> Int {
//        if let responseCode = code { return responseCode }
//        return 999
//    }

//    func handleResponse(_ code: Int?, path: String, data: Data?) -> Data? {
//        self.taskComplete()
//        if code == 200 && data != nil {
//            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
//                try? data!.write(to: URL(fileURLWithPath: self.createFilePathWithExtention(path, ext: "json")), options: [.atomic])
//            })
//            return data
//        } else if code != nil {
//            let filePath = self.createFilePathWithExtention(path, ext: "json")
//            return (try? Data(contentsOf: URL(fileURLWithPath: filePath)))
//        }
//        return nil
//    }

    func taskComplete() {
        OCVAppUtilities.finishTask()
        if taskQueue.count > 1 { taskQueue.removeLast() }
    }

    func cancelAllRequests() {
        for request in taskQueue { request.cancel() }
        taskQueue = []
        print("All requests canceled")
    }

    func removeSpecialCharsFromString(_ text: String) -> String {
        let okayChars: Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-_".characters)
        return String(text.characters.filter { okayChars.contains($0) })
    }

    func createFilePathWithExtention(_ nameIn: String, ext: String) -> String {
        let fileName = self.removeSpecialCharsFromString(nameIn)
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = "/\(dirPath)/\(fileName).\(ext)"

        return filePath
    }
}
