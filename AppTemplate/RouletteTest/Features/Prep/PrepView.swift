import SwiftUI

struct PrepView: View {
    @Environment(AppState.self) private var appState
    @State private var pendingItemID: UUID?
    @State private var completionNote = ""
    @State private var showAddSheet = false
    @State private var newItemTitle = ""

    private var completedCount: Int {
        appState.checklistItems.filter(\.isCompleted).count
    }

    private var totalCount: Int {
        appState.checklistItems.count
    }

    private var progressPercent: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalCount)) * 100)
    }

    private var allComplete: Bool {
        totalCount > 0 && completedCount == totalCount
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                progressCard
                ForEach(appState.checklistItems) { item in
                    checklistRow(item)
                }
                addButton
                proceedButton
            }
            .padding(20)
        }
        .screenBackground()
        .sheet(isPresented: Binding(
            get: { pendingItemID != nil },
            set: { if !$0 { pendingItemID = nil } }
        )) {
            if let id = pendingItemID {
                confirmSheet(itemID: id)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            addItemSheet
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pre-Session Checklist")
                    .font(AppTypography.serifTitle(26))
                    .foregroundStyle(.white)
                Text("Complete before every session")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.muted)
            }
            Spacer()
            Button {
                appState.resetChecklist()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(AppColors.muted)
                    .padding(10)
                    .background(AppColors.card)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var progressCard: some View {
        DarkCard {
            VStack(spacing: 8) {
                HStack {
                    Text("\(completedCount) of \(totalCount) completed")
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(progressPercent)%")
                        .foregroundStyle(AppColors.gold)
                        .fontWeight(.semibold)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColors.cardElevated)
                        Capsule()
                            .fill(AppColors.teal)
                            .frame(width: geo.size.width * CGFloat(progressPercent) / 100)
                    }
                }
                .frame(height: 6)
            }
        }
    }

    private func checklistRow(_ item: ChecklistItem) -> some View {
        Button {
            if item.isCompleted {
                toggleOff(item)
            } else {
                pendingItemID = item.id
                completionNote = ""
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(item.isCompleted ? AppColors.teal : AppColors.muted, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if item.isCompleted {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.teal)
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.black)
                    }
                }

                Text(item.title)
                    .font(.subheadline)
                    .foregroundStyle(item.isCompleted ? AppColors.muted : .white)
                    .strikethrough(item.isCompleted)
                    .multilineTextAlignment(.leading)

                Spacer()

                if item.isCustom {
                    Button {
                        appState.removeChecklistItem(id: item.id)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(AppColors.muted)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var addButton: some View {
        Button {
            newItemTitle = ""
            showAddSheet = true
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Add Custom Item")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppColors.teal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.teal, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var proceedButton: some View {
        Button {
            if allComplete {
                appState.recordChecklistFullyCompleted()
                appState.selectedTab = .spin
            }
        } label: {
            Text(allComplete ? "Proceed to Session" : "Complete All Items to Proceed")
                .font(.headline)
                .foregroundStyle(allComplete ? .black : AppColors.teal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(allComplete ? AppColors.teal : AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(!allComplete)
    }

    private func confirmSheet(itemID: UUID) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Confirm Completion")
                    .font(AppTypography.serifHeadline(24))
                Text("Optionally add a short note describing what you completed.")
                    .font(.caption)
                    .foregroundStyle(AppColors.muted)

                Text("COMPLETION NOTE (optional)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColors.muted)

                TextEditor(text: $completionNote)
                    .frame(height: 120)
                    .padding(8)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .scrollContentBackground(.hidden)
                    .dismissKeyboardToolbar()

                HStack(spacing: 12) {
                    Button("Skip") {
                        completeItem(id: itemID, note: nil)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Save") {
                        let note = completionNote.trimmingCharacters(in: .whitespacesAndNewlines)
                        completeItem(id: itemID, note: note.isEmpty ? nil : note)
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
            .padding(20)
            .screenBackground()
            .presentationDetents([.medium])
        }
    }

    private var addItemSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add Custom Item")
                    .font(AppTypography.serifHeadline(24))
                Text("Create a personalized checklist item for your sessions.")
                    .font(.caption)
                    .foregroundStyle(AppColors.muted)

                Text("ITEM NAME")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColors.muted)

                TextField("New checklist item", text: $newItemTitle)
                    .padding(14)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .dismissKeyboardToolbar()

                HStack(spacing: 12) {
                    Button("Cancel") {
                        showAddSheet = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Add Item") {
                        appState.addChecklistItem(newItemTitle)
                        showAddSheet = false
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
            .padding(20)
            .screenBackground()
            .presentationDetents([.medium])
        }
    }

    private func completeItem(id: UUID, note: String?) {
        appState.completeChecklistItem(id: id, note: note)
        pendingItemID = nil
        completionNote = ""
    }

    private func toggleOff(_ item: ChecklistItem) {
        appState.uncompleteChecklistItem(id: item.id)
    }
}
