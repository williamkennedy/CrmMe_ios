//
//  SceneDelegate.swift
//  CrmMe_ios
//
//  Created by William Kennedy on 17/04/2023.
//https://github.com/williamkennedy/TurboNavigator
import Turbo
import TurboNavigator
import UIKit
import WebKit
import SafariServices
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?



    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene
        else { fatalError("Expected a UIWindowScene.") }

        createWindow(in: windowScene)
    }

    private let baseURL = URL(string: "http://localhost:3003")!
    private lazy var turboNavigator = TurboNavigator(delegate: self, pathConfiguration: pathConfiguration)
    private lazy var pathConfiguration = PathConfiguration(sources: [
        .server(baseURL.appending(path: "/turbo/ios/path_configuration"))
    ])
    

    private func createWindow(in windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .white
        self.window = window

        TurboConfig.shared.makeCustomWebView = {
            let sharedProcessPool = WKProcessPool()
            let scriptMessageHandler = ScriptMessageHandler()
            scriptMessageHandler.delegate = self
            let configuration = WKWebViewConfiguration()
            configuration.applicationNameForUserAgent = TurboConfig.shared.userAgent
            configuration.processPool = sharedProcessPool
            configuration.userContentController.add(scriptMessageHandler, name: "nativeApp")
            return WKWebView(frame: .zero, configuration: configuration)
        }


        window.makeKeyAndVisible()
        window.rootViewController = turboNavigator.rootViewController

        turboNavigator.route(baseURL)
    }
}

extension SceneDelegate: TurboNavigationDelegate, ScriptMessageDelegate {
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                session.reload()
            }
        }
    }

    func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController? {
        if proposal.url.absoluteString == "\(baseURL)/hello_world" {
            return HelloWorldController()
        } else {
            return controller
        }
    }


    func importContacts(_ name: String) {
        self.turboNavigator.session.webView.evaluateJavaScript("Bridge.importingContacts('\(name)')")
        self.turboNavigator.modalSession.webView.evaluateJavaScript("Bridge.importingContacts('\(name)')")
    }
}

class HelloWorldController: UIHostingController<HelloWorldView> {
    init() {
       super.init(rootView: HelloWorldView())
     }

     @MainActor required dynamic init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
     }
}

