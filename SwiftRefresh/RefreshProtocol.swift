//
//  RefreshProtocol.swift
//  SwiftRefreshExample
//
//  Created by 王欣 on 2019/6/11.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit

protocol RefreshProtocol :NSObject{
    
    func dragEnd()
    func initContentOffset(_ ofset:CGPoint)
    func scrollViewContentOffsetDidChange(_ change:CGPoint)
    func scrollViewContentSizeDidChange(_ size:CGSize)
    func gesStateChanged(_ gesState:UIGestureRecognizer.State)
    
}


class RefreshCommon: NSObject {
    
    
    weak var viewTool:RefreshProtocol?
    weak var scrollView:UIScrollView?
    weak var pan:UIPanGestureRecognizer?
    
    init(viewTool:RefreshProtocol) {
        self.viewTool = viewTool
    }
    
    func updateScrollView(_ scroll:UIScrollView)  {
        self.scrollView = scroll
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func addObservers() {
        if let scroll = self.scrollView {
            scroll.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
            scroll.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
            scroll.panGestureRecognizer.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
    }
    
    func removeObservers(){
        if let scroll = self.scrollView{
            scroll.panGestureRecognizer.removeObserver(self, forKeyPath: "state")
            scroll.removeObserver(self, forKeyPath: "contentOffset")
            scroll.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else {
            return
        }
        if keyPath == "contentOffset"{
            
            if let value = change[NSKeyValueChangeKey.newKey] as? CGPoint{
                viewTool!.scrollViewContentOffsetDidChange(value)
            }
        }
        
        if keyPath == "contentSize"{
            
            if let value = change[NSKeyValueChangeKey.newKey] as? CGSize{
                viewTool!.scrollViewContentSizeDidChange(value)
                
            }
        }
        
        if keyPath == "state"{
            if let value = change[NSKeyValueChangeKey.newKey] as? Int{
                if let state = UIGestureRecognizer.State.init(rawValue: value){
                    viewTool!.gesStateChanged(state)
                }
            }
        }
    }
    
}
