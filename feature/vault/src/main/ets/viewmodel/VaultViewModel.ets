import { VaultState } from '../state/VaultState';
import { common } from '@kit.AbilityKit';
import { LogManager } from 'core/src/main/ets/logger/LogManager';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';
import { NavigationConstants } from '../constants/NavigationConstants';
import { geoLocationManager } from '@kit.LocationKit';
import { ProductConstants } from '../constants/ProductConstants';


export class VaultViewModel {
  private _state: VaultState = VaultState.initial();
  private listeners: Array<(state: VaultState) => void> = [];
  private readonly TAG = 'VaultViewModel';
  context?: common.UIAbilityContext;

  get state(): VaultState {
    return this._state;
  }

  set state(newState: VaultState) {
    this._state = newState;
    this.notifyListeners();
  }

  addListener(listener: (state: VaultState) => void): void {
    this.listeners.push(listener);
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this._state));
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context
  }


  async getUserLocation(): Promise<geoLocationManager.Location> {
    const locationRequest: geoLocationManager.LocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.ACCURACY,
      timeInterval: 0,
      distanceInterval: 0,
      maxAccuracy: 0
    };
    const startLocation = await geoLocationManager.getCurrentLocation(locationRequest);
    return startLocation;
  }

  calculateDistanceMeters(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number
  ): number {
    const R = 6371000;
    const toRad = (value: number) => (value * Math.PI) / 180;

    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;

    return distance;
  }

  async onClickVault(): Promise<void> {
    const currentLocation = await this.getUserLocation();
    const distance = this.calculateDistanceMeters(ProductConstants.targetLatitude, ProductConstants.targetLongitude,
      currentLocation.latitude, currentLocation.longitude)
    LogManager.info(this.TAG, `distance: ${distance}`)
    if (distance < 1) {
      NavigationManager.getInstance().pageInfos.pushPath({ name: NavigationConstants.dashboard })
    } else {
      this.state = this.state.with({ message: 'You are not in range!' })
    }
  }
}
