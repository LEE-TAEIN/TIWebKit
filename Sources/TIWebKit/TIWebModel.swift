/**
 * @Title: TIWebModel.swift
 * @Brief: Data model for WKWebView
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 **/

import Foundation
import Combine
import WebKit


public class TIWebModel: ObservableObject {
    
    public init() {
    }

    // MARK: WebView Navigation event ---------- ---------- ---------- ---------- ----------
    /**
     * @Brief: Javascript interface
     * @Detail: Publish to string for javascript excute(function)
     **/
    public enum NAVIGATION_EVENT: String {
        case didCommit
        case didFinish
        case didFail
        case didRefresh
    }
    public typealias TIWebNavigation = (WKWebView, NAVIGATION_EVENT, Int)
    @Published public var webNavigationSubject = PassthroughSubject<TIWebNavigation, Never>()
    @Published public var webRefreshSubject = CurrentValueSubject<Bool, Never>(false)
    
    
    // MARK: About alert ---------- ---------- ---------- ---------- ----------
    /**
     * @Brief: Bool variable for 'Alert' execution.
     * @Detail: Three types of 'alerts' provided by the JavaScript panel in WKWebView.
     **/
    @Published public var alertShowVoid: Bool = false
    @Published public var alertShowConfirm: Bool = false
    @Published public var alertShowInput: Bool = false
    
    /**
     * @Brief: String variable for 'Alert' execution.
     * @Detail: Three types of 'alerts' provided by the JavaScript panel in WKWebView.
     * @Variable:
     *  - alertMessage : The message to the user.
     *  - alertPrompt: Prompt to user input.
     *  - alertInput: The value write by the user.
     **/
    @Published public var alertMessage: String = ""
    @Published public var alertPrompt: String = ""
    @Published public var alertInput: String = ""
    
    /**
     * @Brief: Callback handlers for 'Alert' execution.
     * @Detail: Three types of 'alerts' provided by the JavaScript panel in WKWebView.
     * @Variable:
     *  - alertVoidCompletion : When need to just for guidance.
     *  - alertConfirmCompletion: When need to choose.
     *  - alertInputCompletion: When need to input value.
     **/
    @Published public var alertVoidCompletion: () -> Void = { }
    @Published public var alertConfirmCompletion: (Bool) -> Void = {_ in }
    @Published public var alertInputCompletion: (String) -> Void = {_ in }
    
    /**
     * @Brief: enum variable for 'Alert' execution.
     * @Detail: Three types of 'alerts' provided by the JavaScript panel in WKWebView.
     **/
    public enum ALERT_TYPE {
        case alert_simple
        case alert_confirm
        case alert_input
    }
    @Published public var alertType: ALERT_TYPE = .alert_simple
    
    // MARK: Alert completion Handlers ---------- ---------- ---------- ---------- ----------
    public func voidAlertAction() -> () -> Void {
        return {
            self.alertVoidCompletion()
        }
    }

    public func confirmAlertAction(_ confirm: Bool) -> () -> Void {
        return {
            self.alertConfirmCompletion(confirm)
        }
    }

    public func cancelInputAlertAction() -> () -> Void {
        return {
            self.alertInputCompletion(self.alertMessage)
            self.alertInput = ""
        }
    }

    public func confirmInputAlertAction() -> () -> Void {
        return {
            self.alertInputCompletion(self.alertInput)
            self.alertInput = ""
        }
    }


    // MARK: JavaScript alert ---------- ---------- ---------- ---------- ----------
    /**
     * @Brief: Javascript interface
     * @Detail: Publish to string for javascript excute(function)
     **/
    @Published public var javascriptCall = PassthroughSubject<String, Never>()
}
