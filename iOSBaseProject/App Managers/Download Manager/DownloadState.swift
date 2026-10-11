//
//  DownloadState.swift
//  iOSBaseProject
//
//  Created by Pradyumna on 06/10/26.
//

import Foundation


/// Represents the application-level state of a download.
///
/// We intentionally maintain our own state instead of exposing
/// URLSessionTask.State directly to the UI.
enum DownloadState: String, Codable, Sendable {
    
    /// Download is created but has not started yet.
    case waiting
    
    /// Download is currently running.
    case downloading
    
    /// User explicitly paused the download.
    case paused
    
    /// Download completed successfully.
    case completed
    
    /// Download failed.
    case failed
    
    /// User explicitly cancelled the download.
    case cancelled
}
