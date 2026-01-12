import { PermissionManager, PermissionResult, PermissionType } from 'core/src/main/ets/permission/PermissionManager';
import { SplashState } from '../state/SplashState';
import { common } from '@kit.AbilityKit';
import { LogManager } from 'core/src/main/ets/logger/LogManager';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';
import { NavigationConstants } from '../constants/NavigationConstants';

export class SplashViewModel {
  private _state: SplashState = SplashState.initial();
  private listeners: Array<(state: SplashState) => void> = [];
  private readonly TAG = 'SplashViewModel';
  context?: common.UIAbilityContext;

  get state(): SplashState {
    return this._state;
  }

  set state(newState: SplashState) {
    this._state = newState;
    this.notifyListeners();
  }

  addListener(listener: (state: SplashState) => void): void {
    this.listeners.push(listener);
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this._state));
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context
    this.state = this.state.with({ isLoading: true });

    try {
      const locationGranted = await this.requestLocationPermission();
      const approximatelyLocationGranted = await this.requestapproximatelyLocationPermission();

      LogManager.info(this.TAG, `location granted: ${locationGranted}`)
      LogManager.info(this.TAG, `approximately location granted: ${approximatelyLocationGranted}`)

      NavigationManager.getInstance().pageInfos.replacePath({ name: NavigationConstants.vault });

    } catch (e) {
      LogManager.error(this.TAG, `init() error: ${JSON.stringify(e)}`);
      this.state = this.state.with({ error: 'İzinler alınırken hata oluştu.' });
    } finally {
      this.state = this.state.with({ isLoading: false });
    }

  }


  private async requestLocationPermission(): Promise<PermissionResult> {
    return await PermissionManager.getInstance().requestPermission(PermissionType.LOCATION, this.context!);
  }

  private async requestapproximatelyLocationPermission(): Promise<PermissionResult> {
    return await PermissionManager.getInstance().requestPermission(PermissionType.APPROX_LOCATION, this.context!);
  }
}
