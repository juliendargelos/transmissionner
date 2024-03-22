//
//  ConnectionView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import SwiftUI

struct ConnectionView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var name: String = ""
  @State private var hostname: String = ""
  @State private var port: Int = Connection.defaultPort
  @State private var path: String = Connection.defaultPath
  @State private var ssl: Bool = false
  @State private var username: String = ""
  @State private var password: String = ""
  @State private var authentication: Bool = false
  
  @Binding public var connection: Connection?
  public var onSave: (() -> Void)?
  public var onCancel: (() -> Void)?
  
  private var namePlaceholder: Binding<String> {
    Binding(
      get: {
        if (hostname == "") {
          return "My transmission server"
        } else {
          return hostname
        }
      },
      set: { _ in }
    )
  }
  
  private var valid: Binding<Bool> {
    Binding(
      get: {
        if (hostname == "") {
          return false
        }
        
        if (authentication && username == "") {
          return false
        }
        
        return true
      },
      set: { _ in }
    )
  }
  
  private static let portFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = false
    return formatter
  }()
  
  func reset() {
    if let connection = connection {
      name = connection.name
      hostname = connection.hostname
      port = connection.port
      path = connection.path
      ssl = connection.ssl
      username = connection.username ?? ""
      password = connection.password ?? ""
      authentication = connection.username != nil
    } else {
      name = ""
      hostname = ""
      port = Connection.defaultPort
      path = Connection.defaultPath
      ssl = false
      username = ""
      password = ""
      authentication = false
    }
  }
  
  var body: some View {
    #if os(macOS)
      let textFieldStyle = RoundedBorderTextFieldStyle()
    #else
      let textFieldStyle = PlainTextFieldStyle()
    #endif
    
    let portField = TextField("Port", value: $port, formatter: Self.portFormatter, prompt: Text(String(Connection.defaultPort)))
      .textFieldStyle(textFieldStyle)
      .labelsHidden()
    
    let hostnameField = TextField("Hostname", text: $hostname, prompt: Text("192.168.1.2"))
      .textFieldStyle(textFieldStyle)
      .autocorrectionDisabled()
      .labelsHidden()
    
    let pathField = TextField("Path", text: $path, prompt: Text(Connection.defaultPath))
      .textFieldStyle(textFieldStyle)
      .autocorrectionDisabled()
      .labelsHidden()
    
    let usernameField = TextField("Username", text: $username, prompt: Text(""))
      .textFieldStyle(textFieldStyle)
      .autocorrectionDisabled()
      .labelsHidden()
    
    return Form {
      Section {
        LabeledContent("Name") {
          TextField("Name", text: $name, prompt: Text(namePlaceholder.wrappedValue))
            .textFieldStyle(textFieldStyle)
            .labelsHidden()
        }
        
        LabeledContent("Hostname") {
#if os(iOS)
          hostnameField
            .textInputAutocapitalization(.never)
#else
          hostnameField
#endif
        }
        
        LabeledContent("Port") {
#if os(iOS)
          portField
            .keyboardType(.numberPad)
#else
          portField
#endif
        }
        
        LabeledContent("Path") {
#if os(iOS)
          pathField
            .textInputAutocapitalization(.never)
#else
          pathField
#endif
        }
        
        LabeledContent("Use SSL") {
          Toggle(isOn: $ssl, label: { })
        }
      }
      
      Section {
        LabeledContent("Authentication") {
          Toggle(isOn: $authentication, label: { })
        }
        
        if authentication {
          Group {
            LabeledContent("Username") {
#if os(iOS)
              usernameField
                .textInputAutocapitalization(.never)
#else
              usernameField
#endif
            }
            
            LabeledContent("Password") {
              SecureField("Password", text: $password, prompt: Text(""))
                .textFieldStyle(textFieldStyle)
                .labelsHidden()
            }
          }
        }
      }
    }
    .navigationTitle(connection == nil ? "New connection" : "Edit connection")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          onCancel!()
        }
        .disabled(onCancel == nil)
      }
        
      if connection != nil {
        ToolbarItem(placement: .destructiveAction) {
          Button("Delete") {
            if connection != nil {
              modelContext.delete(connection!)
              try? modelContext.save()
              connection = nil
            }
            
            reset()
            onCancel!()
          }
        }
      }
      
      ToolbarItem(placement: .primaryAction) {
        Button("Save") {
          if connection == nil {
            connection = Connection(
              name: name,
              hostname: hostname,
              port: port,
              path: path,
              ssl: ssl,
              username: authentication ? username : nil,
              password: authentication ? password : nil
            )
            
            modelContext.insert(connection!)
          } else {
            connection!.name = name
            connection!.hostname = hostname
            connection!.port = port
            connection!.path = path
            connection!.ssl = ssl
            connection!.username = authentication ? username : nil
            connection!.password = authentication ? password : nil
          }
          
          try? modelContext.save()
          onSave?()
        }
        .disabled(!valid.wrappedValue)
      }
    }
    .onAppear {
      reset()
    }
  }
}

#Preview {
  NavigationStack {
#if os(macOS)
    ConnectionView(connection: Binding.constant(nil as Connection?))
      .modelContainer(for: Connection.self, inMemory: true)
      .frame(width: 400, height: 222, alignment: .top)
#else
    ConnectionView(connection: Binding.constant(nil as Connection?))
      .modelContainer(for: Connection.self, inMemory: true)
#endif
  }
}
