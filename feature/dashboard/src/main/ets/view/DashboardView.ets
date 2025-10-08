import { DataModel } from '../model/DataModel'
import { DashboardState } from '../state/DashboardState'
import { DashboardViewModel } from '../viewmodel/DashboardViewModel'

@Component
export struct DashboardView {

  private viewModel : DashboardViewModel = new DashboardViewModel()
  @State state : DashboardState = DashboardState.initial()

  aboutToAppear(): void {
    this.viewModel.addListener((newState : DashboardState) => {
      this.state = newState
    })
    this.viewModel.init()
  }

  build() {
    NavDestination(){
      Scroll() {
        Column({ space: 12 }) {

          // Üstteki buton
          Button(){
            Image($r('sys.media.ohos_ic_public_edit'))
              .fillColor(Color.White)
              .width(24)
              .height(24)
          }
          .onClick(() => {
            this.viewModel.onClickEditorButton()
          })
          .backgroundColor(Color.Transparent)
          .hoverEffect(HoverEffect.Scale)

          // Başlık
          Text('📋 Notes')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: 4 })

          // Boş veri durumu
          if(this.state.dataList!.length === 0){
            Text('No notes found.')
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .margin({ top: 20 })
          }

          // Liste
          Column({ space: 12 }) {
            ForEach(this.state.dataList, (note: DataModel, index: number) => {
              Row({ space: 8 }) {
                Column() {
                  Text(note.title)
                    .fontColor(Color.Black)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)

                  Text(note.content)
                    .fontColor(Color.Black)
                    .fontSize(14)
                    .opacity(0.7)
                }
                .width('80%')

                Button(){
                  Image($r('sys.media.ohos_ic_public_remove'))
                    .width(24)
                    .height(24)
                    .fillColor(Color.Red)
                }
                .onClick(() => {
                  this.viewModel.deleteNoteByIndex(index)
                })
                .backgroundColor(Color.Transparent)
                .hoverEffect(HoverEffect.Scale)
              }
              .padding(12)
              .border({ width: 1, color: '#cccccc', radius: 12 })
              .width('100%')
              .backgroundColor('#ffffff')
            }, (item: DataModel) => item.id)
          }

        }
        .padding(16)
        .align(Alignment.Top)
      }
    }
    .hideBackButton(true)
  }
}
