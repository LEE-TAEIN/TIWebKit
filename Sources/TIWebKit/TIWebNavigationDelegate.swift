/**
 * @Title: TIWebNavigationDelegate.swift
 * @Brief: WKNavigationDelegate
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 **/


import WebKit


extension TIWebView.Coordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        /**
         * @Brief: Called when the web view begins to receive web content.
         * @Detail: 웹뷰에서 웹 콘텐츠를 받기 시작할 때 호출됩니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate navigation didCommit : %@", webView.url!.absoluteString),
                              level: .debug)
        let index: Int = self.webview.data.getIndex()
        self.webview.model.webNavigationSubject.send((webView, .didCommit, index))
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /**
         * @Brief: Called when the navigation is complete.
         * @Detail: 네비게이션이 완료하면 호출됩니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate navigation didFinish : %@", webView.url!.absoluteString),
                              level: .debug)
        let index: Int = self.webview.data.getIndex()
        self.webview.model.webNavigationSubject.send((webView, .didFinish, index))

        /**
         * @Brief: Start observe to refresh action
         * @Detail: 리프레쉬 플래그 값의 변경을 감시합니다.
         **/
        self.webview.model.webRefreshSubject.sink { value in
            if value == true {
                self.webview.printLog(message: String(format: "WKNavigationDelegate navigation didRefresh : %@", webView.url!.absoluteString),
                                      level: .debug)
                webView.reload()
                self.webview.model.webRefreshSubject.value.toggle()
                self.webview.cancellable.removeAll(keepingCapacity: false)
                self.webview.model.webNavigationSubject.send((webView, .didRefresh, index))
            }
        }
        .store(in: &self.webview.cancellable)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        /**
         * @Brief: Called when an error occurs during navigation.
         * @Detail: 네비게이션 중 에러가 발생하면 호출됩니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate navigation didFail reason: %@", error.localizedDescription),
                              level: .debug)
        let index: Int = self.webview.data.getIndex()
        self.webview.model.webNavigationSubject.send((webView, .didFail, index))
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        /**
         * @Brief: Decides whether to allow or cancel a navigation.
         * @Detail: 네비게이션의 탐색을 허용할지 아니면 취소할지 결정합니다.
         **/
        let findScheme: String = navigationAction.request.url!.scheme!
        let findUrl: String = navigationAction.request.url!.absoluteString

        self.webview.printLog(message: String(format: "WKNavigationDelegate decidePolicyFor scheme: %@, url: %@", findScheme, findUrl),
                              level: .debug)

        if findUrl == "about:blank" {
            decisionHandler(.cancel)
        } else {
            if findScheme == "tel" {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        /**
         * @Brief: Decides whether to allow or cancel a navigation after its response is known.
         * @Detail: 네비게이션으로 부터  응답을 수신 후 탐색을 허용할지 아니면 취소할지 결정합니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate decidePolicyFor response : %@",
                                              navigationResponse.response.description),
                              level: .debug)
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        /**
         * @Brief: Called when web content begins to load in a web view.
         * @Detail: 웹 컨텐트가 웹뷰로 로드되기 시작할 때 호출됩니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate didStartProvisionalNavigation : %@",
                                              webView.url!.absoluteString),
                              level: .debug)
    }

    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        /**
         * @Brief: Called when a web view receives a server redirect.
         * @Detail: 웹뷰가 서버 리디렉션을 수신하면 호출됩니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate didReceiveServerRedirectForProvisionalNavigation : %@",
                                              webView.url!.absoluteString),
                              level: .debug)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        /**
         * @Brief: Called when an error occurs while the web view is loading content.
         * @Detail: 웹뷰에서 콘텐츠를 로드하는 중에 오류가 발생하면 호출됩니다.
         **/
        let errorLog: String = String(format: "WKNavigationDelegate didFailProvisionalNavigation reason: %@", error.localizedDescription)
        self.webview.printLog(message: errorLog,
                              level: .debug)
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        /**
         * @Brief: Called when the web view needs to respond to an authentication challenge.
         * @Detail: 웹뷰가 인증 요청에 응답해야 할 때 호출됩니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate challenge : %@",
                                              challenge.protectionSpace.host),
                              level: .debug)

        if self.webview.data.isAuth() {
            guard let host = webView.url?.host, host == self.webview.data.authHost else {
                return
            }
            
            let userID: String = self.webview.data.getAuthentication().authId
            let userPw: String = self.webview.data.getAuthentication().authPw
            let authenticationMethod = challenge.protectionSpace.authenticationMethod
            if authenticationMethod == NSURLAuthenticationMethodDefault
                || authenticationMethod == NSURLAuthenticationMethodHTTPBasic
                || authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
                let credential = URLCredential(user: userID, password: userPw, persistence: .none)
                completionHandler(.useCredential, credential)
            } else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
                completionHandler(.performDefaultHandling, nil)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!
            let exceptions = SecTrustCopyExceptions(serverTrust)
            SecTrustSetExceptions(serverTrust, exceptions)
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        /**
         * @Brief: Called when the web view’s web content process is terminated.
         * @Detail: 웹뷰의 웹 콘텐츠 프로세스가 종료되면 호출됩니다.
         **/
        self.webview.printLog(message: String(format: "WKNavigationDelegate webViewWebContentProcessDidTerminate : %@",
                                              webView.url!.absoluteString),
                              level: .debug)
    }
}
