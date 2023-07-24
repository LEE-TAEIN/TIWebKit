//
//  ContentView.swift
//  DemoApp
//
//  Created by TaeNyMacBook on 2023/07/24.
//

import SwiftUI
import TIWebKit


struct ContentView: View {
    let urls: [String] = [
        "https://m.naver.com",
        "https://lee-taein.github.io/testOnWeb/script/mobile/confirm.html"
    ]
    let cookies: [String] = [
        "",
        ""
    ]
    let agents: [String] = [
        "",
        ""
    ]
    @StateObject var model: TIWebModel = TIWebModel()
    
    
    func initWebData(testIndex: Int) -> TIWebData {
        let webData: TIWebData = TIWebData(index: testIndex, string: urls[testIndex], type: .load_url)
        webData.timeoutInterval = 3.0
        webData.isRefreshConterol = true
        webData.filePath = "messageHandlers"
        webData.fileExtension = "txt"
        webData.cookieString = cookies[testIndex]
        webData.agentString = agents[testIndex]
        return webData
    }
    
    var body: some View {
        let webData: TIWebData = self.initWebData(testIndex: 1)
        let webview: TIWebView = TIWebView(webData: webData, model: model)
        webview
            .environmentObject(model)
            .onReceive(model.webNavigationSubject, perform: { value in
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
