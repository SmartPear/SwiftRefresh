//
//  RefreshUnity.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit

var freshBeginHeight:CGFloat = 75
var CriticalProgress:CGFloat = 1
var refreshAnimationTime = 0.25
var noMoreDataText = "没有更多数据"

enum RefreshState {
    case idle
    case willRefresh
    case pulling //正在被拉动
    case refreshing
    case end
    case noMoreData
}


class RefreshUnity: NSObject {

}

internal func Log(_ messsage : Any...) {
    
    #if DEBUG
    
    debugPrint("\(messsage):linenum=\(#line) funcName =  \(#function)")
    
    #endif
    
}
