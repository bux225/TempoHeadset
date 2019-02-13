//
//  OpenTokDelegate.swift
//  TempoHeadset
//
//  Created by Soltis, Matthew on 2/5/19.
//  Copyright © 2019 Soltis, Matthew. All rights reserved.
//

import Foundation

protocol OpenTokDelegate: class {
    func didPublish(_ myStreamId: String)
    func usersChanged(_ usersOnChannel:[String])
}
