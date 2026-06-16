import Foundation

/// External URLs for support and legal pages.
enum AppLinks {
  /// GitHub Pages site (Settings → Pages → /docs on `main`).
  private static let siteBase = URL(string: "https://jacobrozell.github.io/Avasia-iOS")!

  static let buyMeACoffee = URL(string: "https://buymeacoffee.com/jacobrozelq")!
  static let privacyPolicy = siteBase.appendingPathComponent("privacy.html")
  static let support = siteBase.appendingPathComponent("support.html")
}
