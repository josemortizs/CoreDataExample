//
//  ContentView.swift
//  DatabaseExample
//
//  Created by Jose Manuel Ortiz Sanchez on 18/02/2020.
//  Copyright © 2020 Ortiz Sánchez DEV. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        customView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct customView : View {
    
    @ObservedObject var observedData = obsevable()
    @State var user = ""
    
    var body : some View {
        NavigationView{
            VStack {
                List{
                    ForEach(observedData.data) { i in
                        Text(i.user)
                    }.onDelete { (indexset) in
                        self.observedData.deleteData(indexset: indexset,
                                                     id: self.observedData.data[indexset.first!].id)
                    }
                }.navigationBarTitle("CoreDataExample")
                
                HStack{
                    TextField("Username", text: $user)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        print(self.user)
                        self.observedData.addData(user: self.user)
                        self.user = ""
                    }) {
                        Text("Add")
                    }
                }.padding()
            }
        }
    }
}

class obsevable : ObservableObject {
    
    @Published var data = [datatype]()
    
    init() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        do {
            let res = try context.fetch(req)
            
            for i in res as! [NSManagedObject] {
                self.data.append(datatype(id: i.objectID, user: i.value(forKey: "user") as! String))
            }
        } catch {
            print("error")
        }
    }
    
    func addData(user : String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
        
        entity.setValue(user, forKey: "user")
        
        do {
            try context.save()
            print("Success!!")
            data.append(datatype(id: entity.objectID, user: user))
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteData(indexset : IndexSet, id : NSManagedObjectID) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        do {
            let res = try context.fetch(req)
            
            for i in res as! [NSManagedObject] {
                if i.objectID == id{
                    try context.execute(NSBatchDeleteRequest(objectIDs: [id]))
                    self.data.remove(atOffsets: indexset)
                }
            }
        } catch {
            print("error")
        }
    }
    
}

struct datatype : Identifiable {
    var id : NSManagedObjectID
    var user : String
}
