/**
 * @Title: TIWebData.swift
 * @Brief: Data for WKWebView setting.
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 **/

import Foundation


public class TIWebData {
    // MARK: Initialize ---------- ---------- ---------- ---------- ----------
    /**
     * @Brief: Require variable
     **/
    public var index: Int
    public var urlString: String?
    public var htmlString: String?

    public enum LOAD_TYPE {
        case load_url
        case load_html
    }
    public var loadType: LOAD_TYPE = .load_url

    public init(index: Int, string: String, type: LOAD_TYPE) {
        switch type {
        case .load_url:
            self.urlString = string
        case .load_html:
            self.htmlString = string
        }
        
        self.index = index
        self.loadType = type
    }

    func getIndex() -> Int {
        return self.index
    }
    func getUrlString() -> String? {
        return self.urlString
    }
    func getHtmlString() -> String? {
        return self.htmlString
    }

    // MARK: Authentication ---------- ---------- ---------- ---------- ----------
    /**
     * @Brief: Optional variable
     **/
    var authId: String = ""
    var authPw: String = ""
    var authHost: String = ""
    func isAuth() -> Bool {
        return !authId.isEmpty && !authPw.isEmpty && !authHost.isEmpty
    }
    func getAuthentication() -> (authId: String, authPw: String, authHost: String) {
        let authId = self.authId
        let authPw = self.authPw
        let authHost = self.authHost
        return(authId, authPw, authHost)
    }

    // MARK: JavaScript Interface ---------- ---------- ---------- ---------- ----------
    /**
     * @Brief: Optional variable, Load to javascript interface
     * @Detail: Read and store of JavaScript Interface items
     **/
    public var filePath: String?
    public var fileExtension: String = ""
    public var handlerStrings: [String]? {
        if let filepath = Bundle.main.path(forResource: filePath, ofType: fileExtension) {
            do {
                let contents = try String(contentsOfFile: filepath)
                let components = contents.components(separatedBy: .newlines)
                return components
            } catch {
                // 파일 읽기 에러 처리
                print("TIWebData, Error reading text file: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    // MARK: Etc Info ---------- ---------- ---------- ---------- ----------
    /**
     * @Brief: Optional variable
     * @Detail: If necessary
     **/
    public var timeoutInterval: TimeInterval = 5.0
    public var cookieString: String?
    public var agentString: String?
    public var isIndicatorToVertival: Bool = false
    public var isIndicatorToHorizontal: Bool = false
    public var isBounce: Bool = true
    public var isRefreshConterol: Bool = false
}
