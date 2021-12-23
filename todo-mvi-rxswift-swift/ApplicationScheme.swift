//
//  ApplicationScheme.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 16/12/2021.
//

import UIKit

import MaterialComponents

class ApplicationScheme: NSObject {

  private static var singleton = ApplicationScheme()

  static var shared: ApplicationScheme {
    return singleton
  }

  override init() {
    self.containerScheme.colorScheme = self.colorScheme
    self.containerScheme.typographyScheme = self.typographyScheme
    super.init()
  }

  public let containerScheme = MDCContainerScheme()

  public let colorScheme: MDCSemanticColorScheme = {
    let scheme = MDCSemanticColorScheme(defaults: .material201804)
    //TODO: Customize our app Colors after this line
    scheme.primaryColor = #colorLiteral(red: 0.2705882353, green: 0.3529411765, blue: 0.3921568627, alpha: 1)
      //UIColor(red: 252.0/255.0, green: 184.0/255.0, blue: 171.0/255.0, alpha: 1.0)
    scheme.primaryColorVariant =
      UIColor(red: 68.0/255.0, green: 44.0/255.0, blue: 46.0/255.0, alpha: 1.0)
    scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      //UIColor(red: 68.0/255.0, green: 44.0/255.0, blue: 46.0/255.0, alpha: 1.0)
//    scheme.secondaryColor =
//      UIColor(red: 254.0/255.0, green: 234.0/255.0, blue: 230.0/255.0, alpha: 1.0)
//    scheme.onSecondaryColor =
//      UIColor(red: 68.0/255.0, green: 44.0/255.0, blue: 46.0/255.0, alpha: 1.0)
//    scheme.surfaceColor =
//      UIColor(red: 255.0/255.0, green: 251.0/255.0, blue: 250.0/255.0, alpha: 1.0)
//    scheme.onSurfaceColor =
//      UIColor(red: 68.0/255.0, green: 44.0/255.0, blue: 46.0/255.0, alpha: 1.0)
//    scheme.backgroundColor =
//      UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
//    scheme.onBackgroundColor =
//      UIColor(red: 68.0/255.0, green: 44.0/255.0, blue: 46.0/255.0, alpha: 1.0)
//    scheme.errorColor =
//      UIColor(red: 197.0/255.0, green: 3.0/255.0, blue: 43.0/255.0, alpha: 1.0)
    return scheme
  }()

  public let typographyScheme: MDCTypographyScheme = {
    let scheme = MDCTypographyScheme()
    //TODO: Add our custom fonts after this line
    let fontName = "Roboto-Regular"
    scheme.headline5 = UIFont(name: fontName, size: 24)!
    scheme.headline6 = UIFont(name: fontName, size: 20)!
    scheme.subtitle1 = UIFont(name: fontName, size: 16)!
    scheme.button = UIFont(name: fontName, size: 14)!
    return scheme
  }()
}
