//
//  TorrentDetailsView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 16/03/2025.
//

import SwiftUI

struct TorrentDetailsView: View {
  @ObservedObject public var torrent: Torrent
  @State private var peerLimit: Int = 0
  @State private var downloadLimit: Int = 0
  @State private var downloadLimited: Bool = false
  @State private var uploadLimit: Int = 0
  @State private var uploadLimited: Bool = false
  @State private var honorsSessionLimits: Bool = false
  @State private var seedIdleLimit: Int = 0
  @State private var seedIdleMode: TorrentIdleLimitMode = .global
  @State private var seedRatioLimit: Float = 0
  @State private var seedRatioMode: TorrentRatioLimitMode = .global
  @State private var loading: Bool = false  
  
  public var onSave: ((_: (() -> Void)?) -> Void)? = nil
  public var onFetch: ((_: (() -> Void)?) -> Void)? = nil
  
  private var edited: Binding<Bool> {
    Binding(
      get: {
        return (
          peerLimit != torrent.peerLimit ||
          downloadLimit != torrent.downloadLimit ||
          downloadLimited != torrent.downloadLimited ||
          uploadLimit != torrent.uploadLimit ||
          uploadLimited != torrent.uploadLimited ||
          honorsSessionLimits != torrent.honorsSessionLimits ||
          seedIdleLimit != torrent.seedIdleLimit ||
          seedIdleMode != torrent.seedIdleMode ||
          seedRatioLimit != torrent.seedRatioLimit ||
          seedRatioMode != torrent.seedRatioMode
        )
      },
      set: { _ in }
    )
  }
  
  func reset() {
    peerLimit = torrent.peerLimit
    downloadLimit = torrent.downloadLimit
    downloadLimited = torrent.downloadLimited
    uploadLimit = torrent.uploadLimit
    uploadLimited = torrent.uploadLimited
    honorsSessionLimits = torrent.honorsSessionLimits
    seedIdleLimit = torrent.seedIdleLimit
    seedIdleMode = torrent.seedIdleMode
    seedRatioLimit = torrent.seedRatioLimit
    seedRatioMode = torrent.seedRatioMode
  }
  
  func save() {
    torrent.peerLimit = peerLimit
    torrent.downloadLimit = downloadLimit
    torrent.downloadLimited = downloadLimited
    torrent.uploadLimit = uploadLimit
    torrent.uploadLimited = uploadLimited
    torrent.honorsSessionLimits = honorsSessionLimits
    torrent.seedIdleLimit = seedIdleLimit
    torrent.seedIdleMode = seedIdleMode
    torrent.seedRatioLimit = seedRatioLimit
    torrent.seedRatioMode = seedRatioMode
    
    if onSave != nil {
      loading = true
      onSave! { loading = false }
    }
  }
  
  var body: some View {
    #if os(macOS)
      let textFieldStyle = RoundedBorderTextFieldStyle()
    #else
      let textFieldStyle = PlainTextFieldStyle()
    #endif
    
    let cancelButton = Button("Cancel", role: .cancel, action: {
      reset()
    })
    
    let saveButton = Button("Save", action: {
      save()
    })
    
    return Form {
      Section {
        Text("Coming soon...")
          .foregroundColor(.secondary)
      } header: {
        Text("Files")
      }
      
      Section {
        LabeledContent("Apply global limits") {
          Toggle(isOn: $honorsSessionLimits, label: { })
            .toggleStyle(.switch)
            .labelsHidden()
        }
        
        LabeledContent("Number of peers") {
          HStack(alignment: .center) {
            TextField(value: $peerLimit, formatter: NumberFormatter.integer(minimum: 0), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
            Spacer(minLength: 12)
            Stepper(value: $peerLimit, step: 1, label: { })
              .labelsHidden()
          }
        }
        
        LabeledContent {
          HStack(alignment: .center) {
            TextField(value: $downloadLimit, formatter: NumberFormatter.integer(minimum: 0, unit: "ko/s"), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
              .opacity(downloadLimited ? 1 : 0.5)
            Spacer(minLength: 12)
            Stepper(value: $downloadLimit, step: 1, label: { })
              .labelsHidden()
              .opacity(downloadLimited ? 1 : 0.5)
            Spacer(minLength: 5)
            Toggle(isOn: $downloadLimited, label: { })
              .toggleStyle(.switch)
              .labelsHidden()
          }
        } label: {
          Text("Download speed")
            .opacity(downloadLimited ? 1 : 0.5)
        }
        
        LabeledContent {
          HStack(alignment: .center) {
            TextField(value: $uploadLimit, formatter: NumberFormatter.integer(minimum: 0, unit: "ko/s"), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
              .opacity(uploadLimited ? 1 : 0.5)
            Spacer(minLength: 12)
            Stepper(value: $uploadLimit, step: 1, label: { })
              .labelsHidden()
              .opacity(uploadLimited ? 1 : 0.5)
            Spacer(minLength: 5)
            Toggle(isOn: $uploadLimited, label: { })
              .toggleStyle(.switch)
              .labelsHidden()
          }
        } label: {
          Text("Upload speed")
            .opacity(uploadLimited ? 1 : 0.5)
        }
        
        LabeledContent {
          HStack(alignment: .center) {
            Picker(selection: $seedIdleMode, label: Text("Mode")) {
              Text("Global limit").tag(TorrentIdleLimitMode.global)
              Text("Unlimited").tag(TorrentIdleLimitMode.unlimited)
              Text("Stop after...").tag(TorrentIdleLimitMode.single)
            }
              .pickerStyle(.menu)
              .labelsHidden()
              .frame(minWidth: 100)
            
            if seedIdleMode == .single {
              Spacer(minLength: 5)
              TextField(value: $seedIdleLimit, formatter: NumberFormatter.integer(minimum: 0, unit: "min"), label: { })
                .textFieldStyle(textFieldStyle)
                .labelsHidden()
              Spacer(minLength: 12)
              Stepper(value: $seedIdleLimit, step: 1, label: { })
                .labelsHidden()
            }
          }
        } label: {
          Text("Seed idle")
        }

        LabeledContent {
          HStack(alignment: .center) {
            Picker(selection: $seedRatioMode, label: Text("Mode")) {
              Text("Global limit").tag(TorrentRatioLimitMode.global)
              Text("Unlimited").tag(TorrentRatioLimitMode.unlimited)
              Text("Stop at ratio...").tag(TorrentRatioLimitMode.single)
            }
              .pickerStyle(.menu)
              .labelsHidden()
              .frame(minWidth: seedRatioMode == .single ? 120 : 0)
            
            if seedRatioMode == .single {
              Spacer(minLength: 5)
              TextField(value: $seedRatioLimit, formatter: NumberFormatter.float(minimum: 0), label: { })
                .textFieldStyle(textFieldStyle)
                .labelsHidden()
              Spacer(minLength: 12)
              Stepper(value: $seedRatioLimit, step: 0.1, label: { })
                .labelsHidden()
            }
          }
        } label: {
          Text("Seed ratio")
        }

      } header: {
        Text("Limits")
      }
    }
    
    
    .navigationTitle(Text("Preferences"))
    .toolbar {
      if edited.wrappedValue {
        ToolbarItem(placement: .cancellationAction) {
          #if os(macOS)
            cancelButton
              .buttonStyle(BorderlessButtonStyle())
          #else
            cancelButton
          #endif
        }
        
        ToolbarItem(placement: .primaryAction) {
          Spacer()
        }
        
        ToolbarItem(placement: .confirmationAction) {
          #if os(macOS)
            saveButton
              .buttonStyle(BorderlessButtonStyle())
              .foregroundColor(.accentColor)
          #else
            saveButton
          #endif
        }
      }
    }
    .onAppear {
      reset()
      
      if onFetch != nil {
        loading = true
        onFetch! {
          reset()
          loading = false
        }
      }
    }
    
    
    
    
    
    
    
  }
}

#Preview {
  NavigationStack {
    
#if os(macOS)
    TorrentDetailsView(torrent: Torrent())
      .frame(width: 400, height: 222, alignment: .top)
#else
    TorrentDetailsView(torrent: Torrent())
#endif
  }
}
