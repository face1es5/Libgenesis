//
//  GoodReader.swift
//  Libgenesis
//
//  Created by Fish on 17/9/2024.
//

import Foundation
import SwiftSoup

class GoodreadsAPI {
    static let baseURL = "https://www.goodreads.com/search?utf8=✓&query="
    
    static func fetchingDesc(for isbn: String) async -> String? {
        do {
            let doc = try await SwiftSoup.parse(APIService(to: "\(baseURL)\(isbn)".urlEncode()).getHtml())
            if let element = try doc.select("span.Formatted").first() {
                let description = try element.text()
                return description
            }
        } catch {
            print("Fetching decription for isbn: \(isbn) failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    
    static func fetchDescription(for isbn: String, completion: @escaping (String?) -> Void) {
        let urlString = "\(baseURL)\(isbn)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }

            if let html = String(data: data, encoding: .utf8) {
                let description = parseHTML(html: html)
                completion(description)
            } else {
                completion(nil)
            }
        }

        task.resume()
    }

    private static func parseHTML(html: String) -> String? {
        do {
            let document = try SwiftSoup.parse(html)
            // Select the span with class "Formatted" within the desired div structure
            if let element = try document.select("span.Formatted").first() {
                let description = try element.text()
                return description
            }
        } catch {
            print("Error parsing HTML:", error.localizedDescription)
        }
        return nil
    }
}
