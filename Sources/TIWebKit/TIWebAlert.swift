/**
 * @Title: TIWebAlert.swift
 * @Brief: Enum of Alert
 * @Auth: TIStudio
 * @Copyright: TAE-IN LEE
 **/

import Foundation


struct TIWebAlert: Identifiable {
    
    enum ALERT_TYPE: CustomStringConvertible {
        case ALERT_SIMPLE, ALERT_CONFIRM, ALERT_INPUT
        
        var description: String {
            switch self {
            case .ALERT_SIMPLE: return "단순 노출 타입"
            case .ALERT_CONFIRM: return "사용자 선택 타입"
            case .ALERT_INPUT: return "데이터 입력 타입"
            }
        }
    }
    
    let id: UUID = UUID()
    var message: String = ""
    var type: ALERT_TYPE
    
    init(_ message: String? = nil, _ type: ALERT_TYPE) {
        self.message = message ?? "메세지 없음"
        self.type = type
    }
}
