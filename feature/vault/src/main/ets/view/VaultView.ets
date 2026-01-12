import { VaultState } from '../state/VaultState'
import { VaultViewModel } from '../viewmodel/VaultViewModel'
import { common } from '@kit.AbilityKit';


@Component
export struct VaultView {
  private viewModel: VaultViewModel = new VaultViewModel()
  @State state: VaultState = VaultState.initial()

  aboutToAppear(): void {
    const uiContext = globalThis.getUIContext?.() as common.UIAbilityContext;

    this.viewModel.addListener((newState: VaultState) => {
      this.state = newState
    })
    this.viewModel.init(uiContext)
  }

  build() {
    NavDestination() {
      Column({ space: 30 }) {
        Image($r('sys.media.app_lock_picture'))
          .width(120)
          .height(120)
          .fillColor(Color.Red)
          .onClick(() => this.viewModel.onClickVault())
        if (this.state.message !== null && this.state.message!.trim().length > 0) {
          Text(this.state.message)
            .fontWeight(14)
            .fontColor(Color.Red)
        }
      }
      .padding(20)
      .align(Alignment.Center)
    }
    .backgroundColor(Color.White)
    .hideBackButton(true)
  }
}