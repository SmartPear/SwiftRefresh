//
//  SwiftRefresh.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

private var RefreshHeaderKey = "RefreshHeaderKey"
private var RefreshFooterKey = "RefreshFooterKey"


extension UIScrollView {
    
  @objc public var header:RefreshHeader?{
        get{
            return objc_getAssociatedObject(self, &RefreshHeaderKey) as? RefreshHeader
        }
        
        set{
            if self.header != nil{
                self.header?.removeFromSuperview()
            }
            
            objc_setAssociatedObject(self, &RefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let newValue = newValue{
                self.addSubview(newValue)
            }
        }
    }
    
  @objc public var footer:RefreshFooter?{
        
        get{
            return objc_getAssociatedObject(self, &RefreshFooterKey) as? RefreshFooter
        }
        set{
            if self.footer != nil{
                self.footer?.removeFromSuperview()
            }
            if let newValue = newValue{
                self.addSubview(newValue)
            }
            objc_setAssociatedObject(self, &RefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         
        }
    }
    
    var re_inset:UIEdgeInsets{
        get{
            if #available(iOS 11, *){
                return self.adjustedContentInset
            }else{
                return self.contentInset
            }
        }
    }
    
    var re_insetTop:CGFloat{
        
        get{
            return re_inset.top
        }
        set{
            var inset = self.contentInset
            inset.top = newValue
            if #available(iOS 11, *){
                inset.top -= adjustedContentInset.top - contentInset.top
            }
            self.contentInset = inset
        }
        
    }
    var re_insetBottom:CGFloat{
        
        get{
            return re_inset.bottom
        }
        set{
            var inset = self.contentInset
            inset.bottom = newValue
            if #available(iOS 11, *){
                inset.bottom -= adjustedContentInset.bottom - contentInset.bottom
            }
            self.contentInset = inset
        }
        
    }
    
    
    
}
