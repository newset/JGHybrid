//
//  MethodExtension.swift
//  MLHybrid
//
//  Created by yang cai on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import JGHybrid

class MethodExtension: MLHybridMethodProtocol {

    func methodExtension(command: MLHybirdCommand) {
        print("自定义响应Hybrid命令 ===> \(command.name)")
//        command.callback { (str) in
//
//        }
//
//        command.callback(data: "", err_no: 0, msg: "") { (str) in
//
//        }
    }

}
