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
  @State private var editingConnection: Bool = false
  
  public var canStart: Bool = false
  public var canStop: Bool = false
  
  public var onStart: (() -> Void)?
  public var onStop: (() -> Void)?

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
      ToolbarItem(placement: connectionPickerPlacement) {
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
          Button(action: {
            editingConnection = true
          }, label: {
            Image(systemName: "externaldrive.connected.to.line.below")
          })
        }
      }
      
      ToolbarItem(placement: .principal) {
        Button(action: {
          onStart?()
        }, label: {
          Image(systemName: "arrow.clockwise.circle")
        })
        .disabled(!canStart)
      }
      
      ToolbarItem(placement: .principal) {
        Button(action: {
          onStop?()
        }, label: {
          Image(systemName: "pause.circle")
        })
        .disabled(!canStop)
      }
      
      ToolbarItem(placement: .principal) {
        HStack {
          Divider()
        }
      }
      
      ToolbarItem(placement: .principal) {
        Button(action: {
      
        }, label: {
          Image(systemName: "plus")
        })
      }
      
      ToolbarItem() {
        Spacer()
      }
      
      ToolbarItem(placement: .primaryAction) {
        Button(action: {
      
        }, label: {
          Image(systemName: "gearshape")
        })
      }
      
      ToolbarItem(placement: .primaryAction) {
        Button(action: {
      
        }, label: {
          Image(systemName: "info.circle")
        })
      }
    }
  }
}
