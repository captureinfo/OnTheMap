//
//  NetworkService.swift
//  OnTheMap
//
//  Created by Yang Gao on 3/7/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation

class NetworkService {
    static func addCredentialsToRequest(_ request: NSMutableURLRequest) -> NSMutableURLRequest {
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
}
