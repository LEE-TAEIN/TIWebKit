/**
 * @Title: TIWebView.swift
 * @Brief: WKWebView
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 * @Usage:
         VStack {
             let webData: TIWebData = self.initWebData(testIndex: 3)
             let webview: TIWebView = TIWebView(webData: webData, model: model)
             webview
                 .environmentObject(model)
                 .onReceive(model.webNavigationDelegate, perform: { value in
                     /**
                      * @Brief: Navigation Delegate Event
                      * @Usage: Value.0.func
                      **/
                     switch value.1 {
                     case .didCommit:
                         break
                     case .didFinish:
                         break
                     case .didFail:
                         break
                     case .didRefresh:
                         break
                    }
                 })
                 .onReceive(model.javascriptCall) { value in
                     print("\(value)")
                 }
                 .alert("알림", isPresented: $model.alertShowVoid, actions: {
                     Button("확인", action: model.voidAlertAction())
                 }, message: {
                     Text(model.alertMessage)
                 })
                 .alert("알림", isPresented: $model.alertShowConfirm, actions: {
                     Button("취소", role: .cancel, action: model.confirmAlertAction(false))
                     Button("확인", action: model.confirmAlertAction(true))
                 }, message: {
                     Text(model.alertMessage)
                 })
                 .alert("알림", isPresented: $model.alertShowInput, actions: {
                     TextField(
                         "타이틀",
                         text: $model.alertInput,
                         prompt: Text(model.alertMessage).foregroundColor(.gray)
                     )
                     Button("취소", role: .cancel, action: model.cancelInputAlertAction())
                     Button("확인", action: model.confirmInputAlertAction())
                 }, message: {
                     Text(model.alertPrompt)
                 })
         }
         func initWebData(testIndex: Int) -> TIWebData {
             let webData: TIWebData = TIWebData(index: 0, string: urls[testIndex], type: .load_url)
             webData.timeoutInterval = 3.0
             webData.isRefreshConterol = true
             webData.filePath = "messageHandlers"
             webData.fileExtension = "txt"
             webData.cookieString = cookies[testIndex]
             webData.agentString = agents[testIndex]
             return webData
         }
 **/


import SwiftUI
import WebKit
import Combine
import os


public struct TIWebView: UIViewRepresentable, TIWebRefreshControlDelegate {

    /**
     * @Variable:
     *  - webData : For setting
     *  - model: For Combine
     *  - scriptSubscriber: For excute to evaluateJavaScript
     **/
    let data: TIWebData
    let model: TIWebModel // @ObservedObject var model: TIWebModel

    let refreshHelper: TIWebRefreshControlHelper = TIWebRefreshControlHelper()
    var cancellable = Set<AnyCancellable>()


    public init(webData: TIWebData, model: TIWebModel) {
        self.data = webData
        self.model = model
    }

    private func generateWebView(configrations: WKWebViewConfiguration)->WKWebView {
        /**
         * @Brief: Initialize of WKWebView.
         * @Parameters: WKWebViewConfiguration
         * @Return: WKWebView
         * @TODO 'scrollView.bounces', Change to option if necessary(When use to 'RefreshControl').
         **/
        let webview: WKWebView = WKWebView(frame: .zero, configuration: configrations)
        webview.autoresizingMask = [.flexibleWidth,
            .flexibleHeight,
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin]
        webview.allowsBackForwardNavigationGestures = true
        webview.scrollView.isScrollEnabled = true
        webview.scrollView.indicatorStyle = .default
        webview.scrollView.showsVerticalScrollIndicator = data.isIndicatorToVertival
        webview.scrollView.showsHorizontalScrollIndicator =  data.isIndicatorToHorizontal
        webview.scrollView.bounces = data.isBounce

        if data.isRefreshConterol == true {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = UIColor.black
            refreshControl.addTarget(refreshHelper, action: #selector(refreshHelper.didRefresh), for: .valueChanged)
            refreshHelper.delegate = self
            refreshHelper.refreshControl = refreshControl
            refreshHelper.model = model
            webview.scrollView.refreshControl = refreshControl
        }
        return webview
    }

    private func generateConfigrations()->WKWebViewConfiguration {
        /**
         * @Brief: Generate of  WKWebViewConfiguration.
         * @Return: WKWebViewConfiguration
         **/
        let configration: WKWebViewConfiguration = WKWebViewConfiguration()
        configration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configration.defaultWebpagePreferences.allowsContentJavaScript = true
        configration.allowsInlineMediaPlayback = true
        configration.allowsAirPlayForMediaPlayback = false
        configration.allowsPictureInPictureMediaPlayback = false
        configration.processPool = WKProcessPool()

        if let handlers: [String] = data.handlerStrings, !handlers.isEmpty {
            print("handlers items: \(handlers)")
            let userContentController = WKUserContentController()
            for handler in handlers {
                let trimmedHandler = handler.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedHandler.isEmpty {
                    print("handler name: \(trimmedHandler)")
                    userContentController.add(self.makeCoordinator(), name: trimmedHandler)
                }
            }
            configration.userContentController = userContentController
        }


        return configration
    }
    
    private func generateRequest() -> URLRequest? {
        /**
         * @Brief: Generate of  URLRequest
         * @Return: URLRequest
         **/
        guard let urlString = data.getUrlString(), !urlString.isEmpty,
              let url = URL(string: urlString) else {
            print("Fail to make 'URL': \(data.getUrlString() ?? "")")
            return nil
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: data.timeoutInterval)

        if let cookieString = data.cookieString, !cookieString.isEmpty {
            request.setValue(cookieString, forHTTPHeaderField: "Cookie")
        }

        return request
    }
    
    private func runWebView(webview: WKWebView) {
        /**
         * @Brief: WKWebView load from 'URLRequest' or 'HTMLString'
         * @Parameters: WKWebView(self)
         **/
        DispatchQueue.main.async {
            switch data.loadType {
            case .load_url:
                webview.load(self.generateRequest()!)
            case .load_html:
                webview.loadHTMLString(data.getHtmlString() ?? "", baseURL: nil)
            }
        }
    }
    
    func completeRefreshControl(value: Bool) {
    }

    // MARK: Representation ---------- ---------- ---------- ---------- ----------
    public func makeUIView(context: Context) -> WKWebView {
        /**
         * @Brief: Initialize of UIKit
         * @Parameters: UIViewRepresentableContext<WebView>
         * @Return: WKWebView
         * @Warning: 'navigationDelegate' and 'uiDelegate', Do not move to 'updateUIView' because some times lose from memory.
         **/
        let view: WKWebView = self.generateWebView(configrations: self.generateConfigrations())
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator

        if let agentString = data.agentString, !agentString.isEmpty {
            view.evaluateJavaScript("navigator.userAgent") { result, error in
                guard let userAgent = result as? String else {
                    print("Fail to get 'User Agent': \(data.getUrlString() ?? "")")
                    return
                }
                let agentEdit = "\(userAgent)/\(agentString)"
                view.customUserAgent = agentEdit
    
                self.runWebView(webview: view)
            }
        } else {
            self.runWebView(webview: view)
        }
        
        return view
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        /**
         * @Brief: Update of UIKit
         * @Parameters: WKWebView, Context
         * @Note: If out to another app(safari or chrome, etc.) and comeback, the webview refreshes, so keep the code as annotation and the load on "makeUIView".
         **/
    }
    
    public func makeCoordinator() -> TIWebView.Coordinator {
        return TIWebView.Coordinator(webview: self)
    }
    
    public class Coordinator: NSObject {
        var webview: TIWebView
        
        init(webview: TIWebView) {
            self.webview = webview
        }
    }
}
 
extension TIWebView {
   func callJavaScript(webview: WKWebView, scriptString: String) {
        print("callJavaScript: \(scriptString)")
        webview.evaluateJavaScript(scriptString) { result, error in
            if let error {
                print("Error \(error.localizedDescription)")
                return
            }

            if result == nil {
                print("It's void function")
                return
            }

            print("Received Data \(result ?? "")")
        }
    }
}

extension TIWebView {
    func getLog()->OSLog {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "TIWebVew Component")
        return log
    }
    
    func printLog(message: String, level: OSLogType) {
        os_log("%@", log: self.getLog(), type: level, message)
    }
}
