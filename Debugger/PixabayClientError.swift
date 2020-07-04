//
//  InvalidURLError.swift
//  Debugger
//
//  Created by Gerry Low on 2020-07-04.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation

enum PixabayClientError: Error {
    case invalidURLError
}

extension PixabayClientError: LocalizedError {
    
    public var localizedDescription: String {
        switch self {
        case .invalidURLError: return NSLocalizedString("The image could not be downloaded since the URL provided by Pixabay API is invalid.", comment: "")
        }
    }
    
}
