//
//  ScriptMessageHandler.swift
//  CrmMe_ios
//
//  Created by William Kennedy on 26/04/2023.
//

import Foundation
import Contacts
import WebKit
import TurboNavigator

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: ScriptMessageDelegate?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage ) {
        guard
            let body = message.body as? [String: Any],
            let msg = body["name"] as? String
        else {
            print("No call")
            return
        }
        handleMessage(ScriptMessageHandler.MessageTypes(rawValue: msg) ?? ScriptMessageHandler.MessageTypes.none)
    }
    private func handleMessage(_ messageType: MessageTypes) -> String? {
        switch messageType {
        case .contacts:
            fetchContacts()
            return nil
        case .none:
            return nil
        }
    }
    enum MessageTypes: String {
        case contacts = "contacts"
        case none = "none"
    }

    private func fetchContacts() {
            let store = CNContactStore()
            var contacts = [CNContact]()
            let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
            let request = CNContactFetchRequest(keysToFetch: keys)

            do {
                try store.enumerateContacts(with: request) { (contact, stop) in
                    contacts.append(contact)
                }
            } catch {
                print(error.localizedDescription)
            }
            for contact in contacts {
                delegate?.importContacts(contact.givenName)
            }
        }
}

protocol ScriptMessageDelegate: AnyObject {
    func importContacts(_ name: String)
}
