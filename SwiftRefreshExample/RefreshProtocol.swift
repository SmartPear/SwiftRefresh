//
//  RefreshProtocol.swift
//  SwiftRefreshExample
//
//  Created by 王欣 on 2019/6/11.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit

protocol RefreshProtocol :NSObject{
//    var state:RefreshState = .idle

    func dragEnd()
    func initContentOffset(_ ofset:CGPoint)
    func scrollViewContentOffsetDidChange(_ change:CGPoint)
    func scrollViewContentSizeDidChange(_ size:CGSize)
    func gesStateChanged(_ state:UIGestureRecognizer.State)
    
}


class RefreshCommon: NSObject {
    
    private var initSrollViewOfset = false
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
        print("销毁presenter")
        removeObservers()
    }
    
    func addObservers() {
        if let scroll = self.scrollView {
            scroll.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
            scroll.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
            self.pan = scroll.panGestureRecognizer
            self.pan?.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
    }
    
    func removeObservers(){
        if let scroll = self.scrollView{
            scroll.removeObserver(self, forKeyPath: "contentOffset")
            scroll.removeObserver(self, forKeyPath: "contentSize")
        }
        
        if let pan = self.pan{
            pan.removeObserver(self, forKeyPath: "state")
            self.pan = nil
        }
    }
    
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let scroll = self.scrollView{
            if keyPath == "contentOffset"{
                if let  change = change{
                    if let value = change[NSKeyValueChangeKey.newKey] as? CGPoint{
                        if initSrollViewOfset == false{
                            self.viewTool?.initContentOffset(scroll.contentOffset)
                            return
                        }
                        viewTool!.scrollViewContentOffsetDidChange(value)
                    }
                }
            }
            
            if keyPath == "contentSize"{
                if let  change = change{
                    if let value = change[NSKeyValueChangeKey.newKey] as? CGSize{
                        viewTool!.scrollViewContentSizeDidChange(value)
                    }
                }
            }
            
            if keyPath == "state"{
                initSrollViewOfset = true
                if let  change = change{
                    if let value = change[NSKeyValueChangeKey.newKey] as? Int{
                        if let state = UIGestureRecognizer.State.init(rawValue: value){
                            viewTool!.gesStateChanged(state)
                        }
                    }
                }
            }
        }
    }
    
}
