import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager'
import { DashboardView } from 'dashboard/src/main/ets/view/DashboardView'
import { EditorView } from 'editor/src/main/ets/view/EditorView'
import { SplashView } from 'splash/src/main/ets/view/SplashView'
import { VaultView } from 'vault/src/main/ets/view/VaultView'


@Entry
@Component
struct Index {
  @Builder
  routeMap(name: string) {
    if (name === 'splash') {
      SplashView()
    } else if (name === 'dashboard') {
      DashboardView()
    } else if (name === 'editor') {
      EditorView()
    } else if (name === 'vault'){
      VaultView()
    } else {
      SplashView()
    }
  }

  build() {
    Navigation(NavigationManager.getInstance().pageInfos) {
      SplashView()
    }
    .navDestination(this.routeMap)
    .ignoreLayoutSafeArea()
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}

