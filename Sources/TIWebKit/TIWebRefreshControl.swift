/**
 * @Title: TIWebRefreshControl.swift
 * @Brief: WKScriptMessageHandler
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 **/

import Foundation
import SwiftUI
import UIKit
import WebKit


protocol TIWebRefreshControlDelegate {
    func completeRefreshControl(value: Bool)
}


class TIWebRefreshControlHelper {
    
    var refreshControl : UIRefreshControl?
    var delegate: TIWebRefreshControlDelegate?
    var model: TIWebModel?

    @objc func didRefresh(){
        if self.refreshControl != nil && self.model != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.refreshControl!.endRefreshing()
                self.model?.webRefreshSubject.value.toggle()
            }
        }
    }
}
