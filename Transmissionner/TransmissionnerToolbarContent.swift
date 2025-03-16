//
//  ToolbarView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import SwiftUI
import SwiftData

struct TransmissionnerToolbarContent: ToolbarContent {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Connection.lastUsed, order: .reverse) private var connections: [Connection]
  @Binding public var connection: Connection?
  @ObservedObject public var preferences: Preferences
  @Binding public var inspectorSelection: String?
  @State private var editingConnection: Bool = false {
    didSet {
      editingConnection ? onEditStart?() : onEditEnd?()
    }
  }
  
  
  public var canStart: Bool = false
  public var canStop: Bool = false
  
  public var onStart: (() -> Void)?
  public var onStop: (() -> Void)?
  public var onAdd: (() -> Void)?
  public var onEditStart: (() -> Void)?
  public var onEditEnd: (() -> Void)?
  public var onToggleAlternativeLimits: (() -> Void)?

  private var connectionID: Binding<Int> {
    Binding(
      get: { connection == nil ? -1 : connection!.id.hashValue },
      set: {
        let id = $0
        if id == -1 {
          connection = nil
        } else {
          connection = connections.first(where: { $0.id.hashValue == id })
        }
      }
    )
  }

  var body: some ToolbarContent {
    #if os(iOS)
      let connectionPickerPlacement = ToolbarItemPlacement.bottomBar
    #else
      let connectionPickerPlacement = ToolbarItemPlacement.navigation
    #endif
    
    let connectionView = ConnectionView(
      connection: $connection,
      onSave: { editingConnection = false },
      onCancel: connections.count == 0 ? nil : {
        editingConnection = false
        connection = connections.first
      }
    )
      .interactiveDismissDisabled(connections.count == 0)

    return Group {
      ToolbarItemGroup(placement: connectionPickerPlacement) {
        Picker(selection: connectionID, content: {
          ForEach(connections) { connection in
            Text(connection.name == "" ? connection.hostname : connection.name).tag(connection.id.hashValue)
          }
          Divider()
          Text("New connection...").tag(-1)
        }, label: {
          Image(systemName: "externaldrive.connected.to.line.below.fill")
          Text("Connection")
        })
        .pickerStyle(.menu)
        .onAppear {
          if connection == nil {
            connection = connections.first
          }
          
          if connection == nil {
            editingConnection = true
          }
        }
        .onChange(of: connection, {
          if connection == nil {
            editingConnection = true
          } else {
            connection!.use()
          }
        })
        .sheet(isPresented: $editingConnection, onDismiss: {
          editingConnection = false
        }, content: {
          NavigationStack {
#if os(macOS)
            connectionView
              .padding(.all)
              .frame(minWidth: 400)
#else
            connectionView
#endif
          }
        })
      }
      
      if connection != nil {
        ToolbarItem(placement: connectionPickerPlacement) {
          Button("", systemImage: "externaldrive.connected.to.line.below", action: {
            editingConnection = true
          })
        }
      }
      
      ToolbarItemGroup(placement: .principal) {
        Button("Resume all", systemImage: "arrow.clockwise.circle.fill", action: {
          onStart?()
        })
        .disabled(!canStart)
        
        Button("Pause all", systemImage: "pause.circle.fill", action: {
          onStop?()
        })
        .disabled(!canStop)
      }
      
      ToolbarItemGroup(placement: .principal) {
        Button {
          onToggleAlternativeLimits?()
        } label: {
          Image(systemName: "tortoise.circle.fill")
            .foregroundColor(preferences.altSpeedEnabled ? .accentColor : .secondary)
        }
      } label: {
        Text("Alternative limits")
      }
      
      ToolbarItem(placement: .principal) {
        Button("Add torrents", systemImage: "plus", action: {
          onAdd?()
        })
      }
      
      ToolbarItem() {
        Spacer()
      }
      
      ToolbarItemGroup(placement: .primaryAction) {
        Picker(selection: $inspectorSelection, label: Text("Inspector")) {
          Button("Preferences", systemImage: "gearshape", action: {}).tag("preferences")
            .buttonStyle(.plain)
          Button("Torrent details", systemImage: "info.circle", action: {}).tag("torrent")
            .buttonStyle(.plain)
        }
        .labelsHidden()
        .pickerStyle(.segmented)
      } label: {
        Text("Inspector")
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Connection.self, inMemory: true)
    .frame(width:800)
}
