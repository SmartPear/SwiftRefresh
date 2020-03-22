//
//  SwiftRefreshPresenter.swift
//  SwiftRefresh
//
//  Created by 王欣 on 3/21/20.
//  Copyright © 2020 王欣. All rights reserved.
//

import Foundation

protocol SwiftRefreshProtocol:class{
    
    var scrollView:UIScrollView?{get set}
    
    func beginRefresh()
    
    func endRefreshing()
    
    func dragEnd()
    func initContentOffset(_ ofset:CGPoint)
    func scrollViewContentOffsetDidChange(_ change:CGPoint)
    func scrollViewContentSizeDidChange(_ size:CGSize)
    func gesStateChanged(_ gesState:UIGestureRecognizer.State)
    
}

class SwiftRefreshPresenter:NSObject {
    
    weak var refreshView:SwiftRefreshProtocol?
    
    init(refreshView:SwiftRefreshProtocol) {
        super.init()
        self.refreshView = refreshView
        addObserver()
    }
    
    override private init() {}
    
    func addObserver()  {
        if let scroll = refreshView?.scrollView  {
            scroll.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
            scroll.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
            scroll.panGestureRecognizer.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
    }
    
    
    func removeObserver(){
        if let scroll = refreshView?.scrollView{
            scroll.panGestureRecognizer.removeObserver(self, forKeyPath: "state")
            scroll.removeObserver(self, forKeyPath: "contentOffset")
            scroll.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let refreshView = refreshView else {
            return
        }
        if keyPath == "contentOffset"{
            if let  change = change{
                if let value = change[NSKeyValueChangeKey.newKey] as? CGPoint{
                    refreshView.scrollViewContentOffsetDidChange(value)
                }
            }
        }
        
        if keyPath == "contentSize"{
            
            if let  change = change{
                if let value = change[NSKeyValueChangeKey.newKey] as? CGSize{
                    refreshView.scrollViewContentSizeDidChange(value)
                    
                }
            }
        }
        
        if keyPath == "state"{
            if let  change = change{
                if let value = change[NSKeyValueChangeKey.newKey] as? Int{
                    if let state = UIGestureRecognizer.State.init(rawValue: value){
                        refreshView.gesStateChanged(state)
                    }
                }
            }
        }
    }
    
    deinit {
        removeObserver()
    }
    
    func bindPresenter() {
        
    }
    
    
}
