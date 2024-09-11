//
//  Kepubify.swift
//  Libgenesis
//
//  Created by Fish on 11/9/2024.
//

import Foundation

class KepubConverter {
    static let shared = KepubConverter()
    private var exec: URL? {
        Bundle.main.url(forAuxiliaryExecutable: "kepubify")
    }
    
    private init() {
    }
    
    // convert and overite, suppose that src points to a valid and wellformed epub file.
    func convert(src: URL, completion: @escaping (Result<String, Error>) -> Void) {
        guard
            let url = exec
        else {
            print("Can't find executable path for epubify, check integrality, convertion halted.")
            return
        }
        let proc = Process()
        let outpipe = Pipe()
        let errpipe = Pipe()
        proc.executableURL = url
        proc.arguments = [src.path(percentEncoded: false), "-o", "-i", src.deletingLastPathComponent().path(percentEncoded: false)]
        proc.standardOutput = outpipe
        proc.standardError = errpipe
        DispatchQueue.global(qos: .background).async {
            do {
                try proc.run()
                proc.waitUntilExit()
                DispatchQueue.main.async {
                    if proc.terminationStatus == 0 {    // success
                        let res = String(data: outpipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "No ouput."
                        completion(.success(res))
                    } else {    //fail
                        let res = String(data: errpipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "No error output."
                        completion(.failure(NSError(domain: "KepubConversionError", code: Int(proc.terminationStatus), userInfo: [NSLocalizedDescriptionKey: res])))
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
