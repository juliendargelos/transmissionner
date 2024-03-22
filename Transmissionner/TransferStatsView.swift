//
//  TransferStatsView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 18/03/2024.
//

import SwiftUI

struct TransferStatsView: View {
  public var downloadRate: Double?
  public var downloadPeers: Int?
  public var uploadRate: Double?
  public var uploadPeers: Int?
  public var monochrome: Bool = false
  
  var body: some View {
    HStack(spacing: 10) {
      if downloadRate != nil || downloadPeers != nil {
        HStack(spacing: 8) {
          if downloadRate != nil {
            HStack(spacing: 2) {
              Image(systemName: "arrow.down")
                .font(.caption.weight(.bold))
                .foregroundColor(monochrome ? .primary : .blue.opacity(0.7))
              Text("\(formatBytes(downloadRate!))/s")
                .font(.subheadline.monospacedDigit())
            }
          }
          
          if downloadPeers != nil {
            HStack(spacing: 2) {
              if downloadRate == nil {
                Image(systemName: "arrow.down")
                  .foregroundColor(monochrome ? .primary : .blue.opacity(0.7))
                  .font(.caption.weight(.bold))
              }
              Image(systemName: "person.2.fill")
                .font(.caption.weight(.bold))
              Text("\(downloadPeers!)")
                .font(.subheadline.monospacedDigit())
            }
          }
        }
        .foregroundStyle(.secondary)
        .frame(alignment: .leading)
      }
      
      if (downloadRate != nil || downloadPeers != nil) && (uploadRate != nil || uploadPeers != nil) {
        Text("-")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      
      if uploadRate != nil || uploadPeers != nil {
        HStack(spacing: 8) {
          if uploadRate != nil {
            HStack(spacing: 2) {
              Image(systemName: "arrow.up")
                .font(.caption.weight(.bold))
                .foregroundColor(monochrome ? .primary : .green.opacity(0.7))
              Text("\(formatBytes(uploadRate!))/s")
                .font(.subheadline.monospacedDigit())
            }
          }
          
          if uploadPeers != nil {
            HStack(spacing: 2) {
              if uploadRate == nil {
                Image(systemName: "arrow.up")
                  .font(.caption.weight(.bold))
                  .foregroundColor(monochrome ? .primary : .green.opacity(0.7))
              }
              Image(systemName: "person.2.fill")
                .font(.caption.weight(.bold))
              Text("\(uploadPeers!)")
                .font(.subheadline.monospacedDigit())
            }
          }
        }
        .foregroundStyle(.secondary)
        .frame(alignment: .leading)
      }
    }
    .frame(alignment: .leading)
  }
}

#Preview {
  TransferStatsView(
    downloadRate: 1024,
    downloadPeers: 26,
    uploadRate: 1024,
    uploadPeers: 26
  )
  .frame(minWidth: 260, minHeight: 40)
}
