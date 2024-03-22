//
//  TorrentView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 18/03/2024.
//

import SwiftUI

struct TorrentView: View {
  @ObservedObject public var torrent: Torrent
  public var selected: Bool = false
  
  var body: some View {
    var progressColor: Color = .blue
    
    if torrent.isStopped {
      progressColor = .secondary
    } else if torrent.isComplete {
      progressColor = .green
    } else if torrent.hasError {
      progressColor = .red
    }
    
    var percentageFrameMinWidth: CGFloat = 45
    
#if os(iOS)
    percentageFrameMinWidth = 55
    #endif
    
    return VStack(alignment: .leading, spacing: 6) {
      Text(torrent.name)
        .font(.body.weight(.bold))
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 3) {
          HStack {
            Text("\(formatBytes(torrent.sizeComplete)) of \(formatBytes(torrent.totalSize))")
              .font(.body.monospacedDigit())
              .foregroundStyle(.secondary)
            if torrent.eta >= 0 {
              Text("-")
                .foregroundStyle(.secondary)
              Text("\(formatDuration(torrent.eta)) remaining")
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
            }
          }
          HStack {
            ProgressView(value: torrent.isPreparing ? nil : torrent.percentComplete, total: 1)
              .tint(progressColor)
              .progressViewStyle(.linear)
              .frame(minWidth: 0)
            Text(formatPercentage(torrent.percentComplete))
              .font(.subheadline.monospacedDigit())
              .foregroundStyle(.secondary)
              .frame(width: percentageFrameMinWidth, alignment: .trailing)
            Button {
              torrent.isStopped ? torrent.start() : torrent.stop()
            } label: {
              Image(systemName: torrent.isStopped ? "arrow.clockwise.circle.fill" : "pause.circle.fill")
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
          }
          TransferStatsView(
            downloadRate: torrent.rateDownload,
            downloadPeers: torrent.peersSendingToUs,
            uploadRate: torrent.rateUpload,
            uploadPeers: torrent.peersGettingFromUs,
            monochrome: selected || torrent.isStopped
          )
        }
      }
    }
  }
}

#Preview {
  TorrentView(
    torrent: Torrent(
      id: 1,
      name: "Lorem ipsum",
      percentComplete: 0.9999
    )
  )
}
