//
//  PreferencesView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 15/03/2025.
//

import SwiftUI

struct PreferencesView: View {
  @State var downloadDir: String = ""
  @State var incompleteDir: String = ""
  @State var incompleteDirEnabled: Bool = false
  @State var renamePartialFiles: Bool = false
  @State var peerLimitGlobal: Int = 0
  @State var peerLimitPerTorrent: Int = 0
  @State var speedLimitDownEnabled: Bool = false
  @State var speedLimitDown: Int = 0
  @State var speedLimitUpEnabled: Bool = false
  @State var speedLimitUp: Int = 0
  @State var altSpeedDown: Int = 0
  @State var altSpeedUp: Int = 0
  @State var altSpeedEnabled: Bool = false
  @State var downloadQueueSize: Int = 0
  @State var downloadQueueEnabled: Bool = false
  @State var loading: Bool = false
  
  public var preferences: Preferences?
  
  public var onSave: ((_: (() -> Void)?) -> Void)?
  public var onFetch: ((_: (() -> Void)?) -> Void)?
  
  private var edited: Binding<Bool> {
    Binding(
      get: {
        if (preferences == nil) {
          return true
        }
        
        return (
          self.downloadDir != preferences!.downloadDir ||
          self.incompleteDir != preferences!.incompleteDir ||
          self.incompleteDirEnabled != preferences!.incompleteDirEnabled ||
          self.renamePartialFiles != preferences!.renamePartialFiles ||
          self.peerLimitGlobal != preferences!.peerLimitGlobal ||
          self.peerLimitPerTorrent != preferences!.peerLimitPerTorrent ||
          self.speedLimitDownEnabled != preferences!.speedLimitDownEnabled ||
          self.speedLimitDown != preferences!.speedLimitDown ||
          self.speedLimitUpEnabled != preferences!.speedLimitUpEnabled ||
          self.speedLimitUp != preferences!.speedLimitUp ||
          self.altSpeedDown != preferences!.altSpeedDown ||
          self.altSpeedUp != preferences!.altSpeedUp ||
          self.altSpeedEnabled != preferences!.altSpeedEnabled ||
          self.downloadQueueSize != preferences!.downloadQueueSize ||
          self.downloadQueueEnabled != preferences!.downloadQueueEnabled
        )
      },
      set: { _ in }
    )
  }
  
  func reset() {
    if let preferences = preferences {
      downloadDir = preferences.downloadDir
      incompleteDir = preferences.incompleteDir
      incompleteDirEnabled = preferences.incompleteDirEnabled
      renamePartialFiles = preferences.renamePartialFiles
      peerLimitGlobal = preferences.peerLimitGlobal
      peerLimitPerTorrent = preferences.peerLimitPerTorrent
      speedLimitDownEnabled = preferences.speedLimitDownEnabled
      speedLimitDown = preferences.speedLimitDown
      speedLimitUpEnabled = preferences.speedLimitUpEnabled
      speedLimitUp = preferences.speedLimitUp
      altSpeedDown = preferences.altSpeedDown
      altSpeedUp = preferences.altSpeedUp
      altSpeedEnabled = preferences.altSpeedEnabled
      downloadQueueSize = preferences.downloadQueueSize
      downloadQueueEnabled = preferences.downloadQueueEnabled
    } else {
      downloadDir = ""
      incompleteDir = ""
      incompleteDirEnabled = false
      renamePartialFiles = false
      peerLimitGlobal = 0
      peerLimitPerTorrent = 0
      speedLimitDownEnabled = false
      speedLimitDown = 0
      speedLimitUpEnabled = false
      speedLimitUp = 0
      altSpeedDown = 0
      altSpeedUp = 0
      altSpeedEnabled = false
      downloadQueueSize = 0
      downloadQueueEnabled = false
    }
  }
  
  func save() {
    if (preferences != nil) {
      preferences!.downloadDir = downloadDir
      preferences!.incompleteDir = incompleteDir
      preferences!.incompleteDirEnabled = incompleteDirEnabled
      preferences!.renamePartialFiles = renamePartialFiles
      preferences!.peerLimitGlobal = peerLimitGlobal
      preferences!.peerLimitPerTorrent = peerLimitPerTorrent
      preferences!.speedLimitDownEnabled = speedLimitDownEnabled
      preferences!.speedLimitDown = speedLimitDown
      preferences!.speedLimitUpEnabled = speedLimitUpEnabled
      preferences!.speedLimitUp = speedLimitUp
      preferences!.altSpeedDown = altSpeedDown
      preferences!.altSpeedUp = altSpeedUp
      preferences!.altSpeedEnabled = altSpeedEnabled
      preferences!.downloadQueueSize = downloadQueueSize
      preferences!.downloadQueueEnabled = downloadQueueEnabled
    }
    
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
    
    let downloadDirField = TextField("Download directory", text: $downloadDir)
      .textFieldStyle(textFieldStyle)
      .autocorrectionDisabled()
      .labelsHidden()
    
    let incompleteDirField = TextField("Incomplete directory", text: $incompleteDir)
      .textFieldStyle(textFieldStyle)
      .autocorrectionDisabled()
      .labelsHidden()
      .opacity(incompleteDirEnabled ? 1 : 0.5)
    
    let cancelButton = Button("Cancel", role: .cancel, action: {
      reset()
    })
    
    let saveButton = Button("Save", action: {
      save()
    })
    
    return Form {
      Section {
        LabeledContent("Download directory") {
#if os(iOS)
          downloadDirField
            .textInputAutocapitalization(.never)
#else
          downloadDirField
#endif
        }
        
        LabeledContent {
          HStack(alignment: .center) {
#if os(iOS)
            incompleteDirField
              .textInputAutocapitalization(.never)
#else
            incompleteDirField
#endif
            Spacer(minLength: 9)
            Toggle(isOn: $incompleteDirEnabled, label: { })
              .toggleStyle(.switch)
              .labelsHidden()
          }
        } label: {
          Text("Incomplete directory")
            .opacity(incompleteDirEnabled ? 1 : 0.5)
        }
        
        LabeledContent("Rename partial files") {
          Toggle(isOn: $renamePartialFiles, label: { })
            .toggleStyle(.switch)
        }
      }
      
      Section {
        LabeledContent("Number of peers") {
          HStack(alignment: .center) {
            TextField(value: $peerLimitGlobal, formatter: NumberFormatter.integer(minimum: 0), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
            Spacer(minLength: 12)
            Stepper(value: $peerLimitGlobal, step: 1, label: { })
              .labelsHidden()
          }
        }

        LabeledContent {
          HStack(alignment: .center) {
            TextField(value: $speedLimitDown, formatter: NumberFormatter.integer(minimum: 0, unit: "ko/s"), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
              .opacity(speedLimitDownEnabled ? 1 : 0.5)
            Spacer(minLength: 12)
            Stepper(value: $speedLimitDown, step: 1, label: { })
              .labelsHidden()
              .opacity(speedLimitDownEnabled ? 1 : 0.5)
            Spacer(minLength: 5)
            Toggle(isOn: $speedLimitDownEnabled, label: { })
              .toggleStyle(.switch)
              .labelsHidden()
          }
        } label: {
          Text("Download speed")
            .opacity(speedLimitDownEnabled ? 1 : 0.5)
        }
        
        LabeledContent {
          HStack(alignment: .center) {
            TextField(value: $speedLimitUp, formatter: NumberFormatter.integer(minimum: 0, unit: "ko/s"), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
              .opacity(speedLimitUpEnabled ? 1 : 0.5)
            Spacer(minLength: 12)
            Stepper(value: $speedLimitUp, step: 1, label: { })
              .labelsHidden()
              .opacity(speedLimitUpEnabled ? 1 : 0.5)
            Spacer(minLength: 5)
            Toggle(isOn: $speedLimitUpEnabled, label: { })
              .toggleStyle(.switch)
              .labelsHidden()
          }
        } label: {
          Text("Upload speed")
            .opacity(speedLimitUpEnabled ? 1 : 0.5)
        }
        
        LabeledContent {
          HStack(alignment: .center) {
            TextField(value: $downloadQueueSize, formatter: NumberFormatter.integer(minimum: 1), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
              .opacity(downloadQueueEnabled ? 1 : 0.5)
            Spacer(minLength: 12)
            Stepper(value: $downloadQueueSize, step: 1, label: { })
              .labelsHidden()
              .opacity(downloadQueueEnabled ? 1 : 0.5)
            Spacer(minLength: 5)
            Toggle(isOn: $downloadQueueEnabled, label: { })
              .toggleStyle(.switch)
              .labelsHidden()
          }
        } label: {
          Text("Concurrent downloads")
            .opacity(downloadQueueEnabled ? 1 : 0.5)
        }
      } header: {
        Text("Global limits")
      }
      
      Section {
        LabeledContent("Number of peers") {
          HStack(alignment: .center) {
            TextField(value: $peerLimitPerTorrent, formatter: NumberFormatter.integer(minimum: 0), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
            Spacer(minLength: 12)
            Stepper(value: $peerLimitPerTorrent, step: 1, label: { })
              .labelsHidden()
          }
        }
      } header: {
        Text("Per torrent limits")
      }
      
      Section {
        LabeledContent("Download speed") {
          HStack(alignment: .center) {
            TextField(value: $altSpeedDown, formatter: NumberFormatter.integer(minimum: 0, unit: "ko/s"), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
            Spacer(minLength: 12)
            Stepper(value: $altSpeedDown, step: 1, label: { })
              .labelsHidden()
          }
        }
        .opacity(altSpeedEnabled ? 1 : 0.5)
        
        LabeledContent("Upload speed") {
          HStack(alignment: .center) {
            TextField(value: $altSpeedUp, formatter: NumberFormatter.integer(minimum: 0, unit: "ko/s"), label: { })
              .textFieldStyle(textFieldStyle)
              .labelsHidden()
            Spacer(minLength: 12)
            Stepper(value: $altSpeedUp, step: 1, label: { })
              .labelsHidden()
          }
        }
        .opacity(altSpeedEnabled ? 1 : 0.5)
      } header: {
        HStack {
          Text("Alternative limits")
          Spacer()
          Toggle(isOn: $altSpeedEnabled, label: { })
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.mini)
        }
      }
    }
    .disabled(loading)
    .allowsHitTesting(!loading)
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
  }
}

#Preview {
  NavigationStack {
#if os(macOS)
    PreferencesView(preferences: nil)
      .frame(width: 400, height: 222, alignment: .top)
#else
    PreferencesView(preferences: nil)
#endif
  }
}
