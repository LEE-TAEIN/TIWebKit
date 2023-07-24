/**
 * @Title: TIWebNavigationDelegate.swift
 * @Brief: WKNavigationDelegate
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 **/


import WebKit


extension TIWebView.Coordinator: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        /**
         * @Brief: Creates a new web view, If you do not implement this method, the web view will cancel the navigation.
         * @Detail: 새 웹보기를 만듭니다, 이 메소드를 구현하지 않으면 웹보기가 탐색을 취소합니다.
         **/
        self.webview.printLog(message: String(format: "WKUIDelegate createWebViewWith: %@", configuration.preferences.description),
                              level: .debug)

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }

    public func webViewDidClose(_ webView: WKWebView) {
        /**
         * @Brief: Notifies your app that the DOM window closed successfully.
         * @Detail: DOM 윈도우가 성공적으로 닫혔다는 것을 앱에 알립니다.
         **/
        self.webview.printLog(message: String(format: "WKUIDelegate webViewDidClose: %@", webView.url!.absoluteString),
                              level: .debug)
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        /**
         * @Brief: Displays a JavaScript alert panel.
         * @Detail: 자바 스크립트 경고 패널을 표시합니다.
         **/
        self.webview.printLog(message: String(format: "WKUIDelegate runJavaScriptAlertPanelWithMessage: %@", webView.url!.absoluteString),
                              level: .debug)

        self.webview.model.alertType = .alert_simple
        self.webview.model.alertMessage = message
        self.webview.model.alertShowVoid = true
        self.webview.model.alertVoidCompletion = completionHandler
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        /**
         * @Brief: Displays a JavaScript Confirm panel.
         * @Detail: 자바 스크립트 확인 패널을 표시합니다.
         **/
        self.webview.printLog(message: String(format: "WKUIDelegate runJavaScriptConfirmPanelWithMessage: %@", webView.url!.absoluteString),
                              level: .debug)
        self.webview.model.alertType = .alert_confirm
        self.webview.model.alertMessage = message
        self.webview.model.alertShowConfirm = true
        self.webview.model.alertConfirmCompletion = completionHandler
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        /**
         * @Brief: Displays a JavaScript text input panel.
         * @Detail: JavaScript 텍스트 입력 패널을 표시합니다.
         **/
        self.webview.printLog(message: String(format: "WKUIDelegate runJavaScriptTextInputPanelWithPrompt: %@", webView.url!.absoluteString),
                              level: .debug)
        self.webview.model.alertType = .alert_input
        self.webview.model.alertPrompt = prompt
        self.webview.model.alertMessage = defaultText ?? ""
        self.webview.model.alertShowInput = true
        self.webview.model.alertInputCompletion = completionHandler
    }
}
