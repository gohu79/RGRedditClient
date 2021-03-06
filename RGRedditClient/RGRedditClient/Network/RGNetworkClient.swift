//
//  RGRequest.swift
//  RGRedditClient
//
//  Created by Jose Humberto Partida Garduno on 11/25/18.
//  Copyright © 2018 Jose Humberto Partida Garduno. All rights reserved.
//

import Foundation

typealias ClientSuccess = (_ data: Data?,_ response: URLResponse?) -> Void
typealias ClientFail = (_ response: URLResponse?,_ error: Error?) -> Void

protocol RGNetworkFetchable {
    func getResults(success: @escaping ClientSuccess,fail: @escaping ClientFail)
    func setClientQueryParameters(query: [String: String]?)
}

public final class RGNetworkClient: NSObject,RGNetworkFetchable {
    public static var defaultSession: RGSession = URLSession.shared
    public lazy var session: RGSession = RGNetworkClient.defaultSession

    private var dataTask: DataTask?
    private var request: RGRequest
    
    var baseUrl: String? {
        get {
            return self.request.urlRequestValue.url?.absoluteString
        }
    }
    // MARK: Initialization
    private init(baseURL: URL) {
        self.request = RGRequest.createRGRequest(withURL: baseURL, method: .GET)
        super.init()
    }
    
    static func createRGNetworkClient(withBaseUrl url: URL, andSession session: RGSession?) -> RGNetworkClient {
        let client = RGNetworkClient(baseURL: url)
        if let localSession = session {
            client.session = localSession
        }
        return client
    }
    
    func getResults(success: @escaping ClientSuccess,fail: @escaping ClientFail) {
        self.dataTask?.cancel()
        dataTask = self.session.dataTask(request: self.request) { (data, response, error) in
            DispatchQueue.main.async {
                if error == nil {
                    success(data, response)
                } else {
                    fail(response, error)
                }
            }
        }
        dataTask?.resume()
    }
    
    func setClientQueryParameters(query: [String: String]?) {
        self.request.queryParameters = query
    }
}
