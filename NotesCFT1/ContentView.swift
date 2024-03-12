import SwiftUI

struct Note: Identifiable {
    let id = UUID()
    var text: String
}

class NoteManager: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    
    func saveNotes() {
        let notesStrings = notes.map { $0.text }
        UserDefaults.standard.set(notesStrings, forKey: "notes")
    }
    
    init() {
        if let notesStrings = UserDefaults.standard.stringArray(forKey: "notes"), !notesStrings.isEmpty {
            self.notes = notesStrings.map { Note(text: $0) }
        } else {
            self.notes = [Note(text: "Здравствуйте! Это приложение Заметки для ЦФТ. Хорошего Вам дня и надеюсь поучаствовать в данной стажировке! 😊")]
        }
    }
    
    
    func editNote(at index: Int, newText: String) {
        notes[index].text = newText
    }
    
    func deleteNote(at index: Int) {
        notes.remove(at: index)
    }
}

struct NoteListView: View {
    @ObservedObject var noteManager: NoteManager
    @State var isDarkMode = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(noteManager.notes.enumerated()), id: \.element.id) { index, note in
                    NavigationLink(destination: EditNoteView(noteManager: noteManager, index: index, editedText: note.text)) {
                        Text(note.text)
                    }
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        noteManager.deleteNote(at: index)
                    }
                })
            }
            .navigationTitle("Список заметок")
            .navigationBarItems(trailing: EditButton())
            .navigationBarItems(leading:
                                    Button(action: {
                isDarkMode.toggle()
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }) {
                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
            }
            )
            
        }
    }
}

struct EditNoteView: View {
    @ObservedObject var noteManager: NoteManager
    let index: Int
    @State var editedText: String
    
    var body: some View {
        VStack {
            TextEditor(text: $editedText)
                .onAppear {
                    editedText = noteManager.notes[index].text
                }
                .padding()
            
            Button("Сохранить изменения") {
                noteManager.editNote(at: index, newText: editedText)
            }
            .padding()
        }
    }
}

struct ContentView: View {
    @StateObject var noteManager = NoteManager()
    @State var newNoteText = ""
    @State var isLoading = false
    
    
    var body: some View {
        NavigationView {
            NoteListView(noteManager: noteManager)
                .navigationBarItems(trailing: Button("Добавить заметку") {
                    noteManager.notes.append(Note(text: newNoteText))
                    newNoteText = ""
                })
        }
    }
    
}
