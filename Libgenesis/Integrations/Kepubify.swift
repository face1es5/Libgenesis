//
//  Kepubify.swift
//  Libgenesis
//
//  Created by Fish on 11/9/2024.
//

import Foundation

#if os(macOS)
class KepubConverter {
    static let shared = KepubConverter()
    private var exec: URL?
    
    private func arch() -> String? {
        var sysInfo = utsname()
        let ret = uname(&sysInfo)
        var res: String?
        
        if ret == EXIT_SUCCESS {
            let bytes = Data(bytes: &sysInfo.machine, count: Int(_SYS_NAMELEN))
            res = String(data: bytes, encoding: .utf8)
        }
        return res?.trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
    }
    
    private init() {
        guard let arch = arch()
        else {
            exec = Bundle.main.url(forAuxiliaryExecutable: "kepubify-intel")
            return
        }
        if arch.contains("x86") {
            exec = Bundle.main.url(forAuxiliaryExecutable: "kepubify-intel")
        } else if arch.contains("arm64") {
            exec = Bundle.main.url(forAuxiliaryExecutable: "kepubify-arm")
        }

    }
    
    // convert and overite, suppose that src points to a valid and wellformed epub file.
    func convert(src: URL?, completion: @escaping (Result<String, Error>) -> Void) {
        guard
            let url = exec
        else {
            print("Libgensis.Kepubify.convert: can't locate executable path for epubify, check integrality, convertion halted.")
            return
        }
        guard let base = src?.baseURL?.path(percentEncoded: false),
              let file = src?.absoluteURL.path(percentEncoded: false)
        else {
            return
        }
        let proc = Process()
        let outpipe = Pipe()
        let errpipe = Pipe()
        proc.executableURL = url

        proc.arguments = ["-i", file, "-o", base]
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
#endif
