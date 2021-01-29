//
//  IAPManager.swift
//  censor
//
//  Created by Maxim Skryabin on 25.01.2021.
//

import Foundation
import StoreKit

// https://www.appcoda.com/in-app-purchases-guide/
class IAPManager: NSObject {
  
  private var getAvailableProductsCompletionHandler: ((Error?, [SKProduct]?) -> Void)?
  private var performRegularPurchaseCompletionHandler: ((Error?, Bool) -> Void)?
  private var performRegularRestorationCompletionHandler: ((Error?, Bool) -> Void)?
  
  private var restoredAnyTransactions: Bool = false {
    didSet {
      print("🔥 restoredAnyTransactions = \(restoredAnyTransactions)")
    }
  }
  
  private(set) var isRequestInProgress: Bool = false {
    didSet {
      print("🔥 isRequestInProgress = \(isRequestInProgress)")
    }
  }
  
  static let shared = IAPManager()
  
  func startObserving() {
    SKPaymentQueue.default().add(self)
  }
  
  func stopObserving() {
    SKPaymentQueue.default().remove(self)
  }
  
  func requestPurchase(_ iapType: IAPType, viewController: UIViewController?, completionHandler: @escaping (Error?, Bool) -> Void) {
    guard !isRequestInProgress else { return }
    guard SKPaymentQueue.canMakePayments() else {
      viewController?.showAlertError(error: nil,
                                     desc: LocalizeSystem.shared.error(.iapNotAllowed),
                                     critical: false)
      return
    }
    isRequestInProgress = true
    
    performRegularPurchase(iapType, viewController: viewController, completionHandler: completionHandler)
  }
  
  func requestRestore(viewController: UIViewController?, completionHandler: @escaping (Error?, Bool) -> Void) {
    guard !isRequestInProgress else { return }
    guard SKPaymentQueue.canMakePayments() else {
      viewController?.showAlertError(error: nil,
                                     desc: LocalizeSystem.shared.error(.iapNotAllowed),
                                     critical: false)
      return
    }
    isRequestInProgress = true
    
    performRegularRestoration(viewController: viewController, completionHandler: completionHandler)
  }
  
  func requestPurchasePrices(completionHandler: @escaping (Error?, [IAPType: String]?) -> Void) {
    getAvailableProducts { (error, products) in
      if let products = products, !products.isEmpty {
        var prices: [IAPType: String] = [:]
        for product in products {
          if let iapType = IAPType.allCases.first(where: { $0.purchaseId == product.productIdentifier }) {
            prices[iapType] = self.getPriceFormatted(for: product)
          }
        }
        completionHandler(nil, prices)
      } else {
        completionHandler(error, nil)
      }
    }
  }
  
  // MARK: Regular purchases
  
  private func performRegularPurchase(_ iapType: IAPType, viewController: UIViewController?, completionHandler: @escaping (Error?, Bool) -> Void) {
    getAvailableProducts { (error, products) in
      guard let products = products, let product = products.first(where: { $0.productIdentifier == iapType.purchaseId }) else {
        self.isRequestInProgress = false
        completionHandler(error, false)
        return
      }
      
      self.performRegularPurchaseCompletionHandler = completionHandler
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(payment)
    }
  }
  
  private func performRegularRestoration(viewController: UIViewController?, completionHandler: @escaping (Error?, Bool) -> Void) {
    performRegularRestorationCompletionHandler = completionHandler
    restoredAnyTransactions = false
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  // MARK: Helper methods
  
  private func getAvailableProducts(completionHandler: @escaping (Error?, [SKProduct]?) -> Void) {
    self.getAvailableProductsCompletionHandler = completionHandler
    let request = SKProductsRequest(productIdentifiers: Set(IAPType.allCases.compactMap({ $0.purchaseId })))
    request.delegate = self
    request.start()
  }
  
  private func getPriceFormatted(for product: SKProduct) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = product.priceLocale
    return formatter.string(from: product.price) ?? "wrong price"
  }
}

extension IAPManager: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    if products.isEmpty {
      getAvailableProductsCompletionHandler?(IAPError.noProductsFound, nil)
    } else {
      getAvailableProductsCompletionHandler?(nil, products)
    }
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    getAvailableProductsCompletionHandler?(error, nil)
  }
}

extension IAPManager: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    print("🔥 updatedTransactions.count = \(transactions.count) ")
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        isRequestInProgress = false
        performRegularPurchaseCompletionHandler?(nil, true)
        SKPaymentQueue.default().finishTransaction(transaction)
      case .failed:
        isRequestInProgress = false
        performRegularPurchaseCompletionHandler?(transaction.error, false)
        SKPaymentQueue.default().finishTransaction(transaction)
      case .restored:
        isRequestInProgress = false
        restoredAnyTransactions = true
        SKPaymentQueue.default().finishTransaction(transaction)
      case .deferred, .purchasing:
        break
      }
    }
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    isRequestInProgress = false
    if restoredAnyTransactions {
      performRegularRestorationCompletionHandler?(nil, true)
    } else {
      performRegularRestorationCompletionHandler?(nil, false)
    }
  }
}

extension IAPManager {
  enum IAPType: CaseIterable {
    case smallTip
    case mediumTip
    case largeTip
    
    var purchaseId: String {
      switch self {
      case .smallTip:
        return "censtory_consumable_small_tip"
      case .mediumTip:
        return "censtory_consumable_medium_tip"
      case .largeTip:
        return "censtory_consumable_large_tip"
      }
    }
    
    var title: String {
      switch self {
      case .smallTip:
        return LocalizeSystem.shared.settings(.tipSmallTitle)
      case .mediumTip:
        return LocalizeSystem.shared.settings(.tipMediumTitle)
      case .largeTip:
        return LocalizeSystem.shared.settings(.tipLargeTitle)
      }
    }
  }
  
  enum IAPError: Error, LocalizedError {
    case noProductsFound
    case paymentWasCancelled
    case productRequestFailed
    
    var localizedDescription: String {
      switch self {
      case .noProductsFound:
        return LocalizeSystem.shared.error(.cantConnectToAppStore)
      case .paymentWasCancelled:
        return LocalizeSystem.shared.error(.iapCancelled)
      case .productRequestFailed:
        return LocalizeSystem.shared.error(.cantVerifyPurchase)
      }
    }
  }
}
