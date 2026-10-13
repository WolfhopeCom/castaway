import Foundation
import WebKit

/// Serves the files in the app's Game folder at castaway://localhost/...
/// A fixed origin (rather than file://) keeps WebGL, audio and the saved game (localStorage) working reliably.
final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {
    private let root: URL? = Bundle.main.url(forResource: "Game", withExtension: nil)?.standardizedFileURL

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url, let root = root else {
            urlSchemeTask.didFailWithError(URLError(.badURL)); return
        }
        var path = url.path
        if path.isEmpty || path == "/" { path = "/index.html" }
        let file = root.appendingPathComponent(String(path.dropFirst())).standardizedFileURL
        guard file.path.hasPrefix(root.path), let data = try? Data(contentsOf: file) else {
            urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist)); return
        }
        let headers = [
            "Content-Type": Self.mimeType(for: file.pathExtension),
            "Content-Length": String(data.count),
            "Cache-Control": "no-cache",
            "Access-Control-Allow-Origin": "*"
        ]
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers) else {
            urlSchemeTask.didFailWithError(URLError(.cannotParseResponse)); return
        }
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}

    private static func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "js": return "text/javascript; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "json": return "application/json"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "svg": return "image/svg+xml"
        case "ttf": return "font/ttf"
        case "woff2": return "font/woff2"
        case "woff": return "font/woff"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "txt": return "text/plain; charset=utf-8"
        default: return "application/octet-stream"
        }
    }
}
