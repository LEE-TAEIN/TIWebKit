/**
 * @Title: TIWebUserInterface.swift
 * @Brief: WKScriptMessageHandler
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 **/


import WebKit
import os


extension TIWebView.Coordinator: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.webview.printLog(message: String(format: "WKScriptMessageHandler userContentController message name: %@, message body : %@",
                                              message.name,
                                              message.body as! CVarArg),
                              level: .debug)

//        if(NETWORK_TYPE == network_none) {
//            [DELEGATE showNetworkAlert];
//            return;
//        }
//
//        if(_WKUserInterfaceDelegate == nil) {
//            return;
//        }
        
//        if message.name == self.webview.webData.bridgeString {
//            print("message name : \(message.name)")
//            print("post Message : \(message.body)")
//        }
        
//        switch message.name {
//        case "interface": break
//        default:
//        }
    }
}
