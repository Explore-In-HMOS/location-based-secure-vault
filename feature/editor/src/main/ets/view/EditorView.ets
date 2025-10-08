import { EditorState } from '../state/EditorState'
import { EditorViewModel } from '../viewmodel/EditorViewModel'

@Component
export struct EditorView {

  private viewModel : EditorViewModel = new EditorViewModel()
  @State state : EditorState = EditorState.initial()

  aboutToAppear(): void {
    this.viewModel.addListener((newState : EditorState) => {
      this.state = newState
    })
    this.viewModel.init()
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          Text('✏️ Add Note')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: 10 })

          TextArea({
            placeholder: 'Type your title here...',
            text: this.state.title,
          })
            .fontColor(Color.Black)
            .onChange((value) => {
              this.viewModel.setTitle(value)
            })
            .backgroundColor(Color.White)
            .placeholderColor(Color.Black)
            .height(64)
            .fontSize(16)
            .border({ width: 1, color: '#ccc', radius: 12 })
            .width('100%')

          TextArea({
            placeholder: 'Type your note here...',
            text: this.state.text,
          })
            .onChange((value) => {
              this.viewModel.setText(value)
            })
            .height(64)
            .placeholderColor(Color.Black)
            .backgroundColor(Color.White)
            .fontColor(Color.Black)
            .fontSize(16)
            .border({ width: 1, color: '#ccc', radius: 12 })
            .width('100%')

          Button() {
            Text('💾 Save')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
          }
          .onClick(() => {
            this.viewModel.saveNote()
          })
          .backgroundColor('#007bff')
          .width('100%')
          .height(48)
          .borderRadius(12)
        }
        .padding({
          left: 32,right: 32, top: 16,bottom: 16
        })
        .align(Alignment.Top)
      }
    }
    .hideBackButton(true)
  }
}
