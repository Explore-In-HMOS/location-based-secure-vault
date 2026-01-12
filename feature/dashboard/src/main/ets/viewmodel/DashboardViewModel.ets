import { DashboardState } from '../state/DashboardState';
import { common } from '@kit.AbilityKit';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';
import { NavigationConstants } from '../utils/constants/NavigationConstants';
import { AssetStoreManager } from 'core/src/main/ets/storage/AssetStoreManager'
import { CacheConstants } from '../utils/constants/CacheConstants';
import { DataListModel } from '../model/DataListModel';
import { Duration } from 'core/src/main/ets/base/DurationModel';
import { DataModel } from '../model/DataModel';

export class DashboardViewModel {
  private _state: DashboardState = DashboardState.initial();
  private listeners: Array<(state: DashboardState) => void> = [];
  private readonly TAG = 'DashboardViewModel';

  get state(): DashboardState {
    return this._state;
  }

  set state(newState: DashboardState) {
    this._state = newState;
    this.notifyListeners();
  }

  addListener(listener: (state: DashboardState) => void): void {
    this.listeners.push(listener);
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this._state));
  }

  async init(): Promise<void> {
    this.state = this.state.with({isLoading: true})
    const store = AssetStoreManager.getInstance()
    const data = await store.getModelWithExpiry(CacheConstants.dataList, DataListModel.fromJson)
    const list = data?.dataList
    this.state = this.state.with({isLoading: false,dataList: list})

  }

  onClickEditorButton() {
    NavigationManager.getInstance().pageInfos.pushPath({name: NavigationConstants.editor})
  }

  async deleteNoteById(id: string): Promise<void> {
    const store = AssetStoreManager.getInstance();

    const currentList: DataModel[] = this.state.dataList ?? [];

    const newList: DataModel[] =
      currentList.filter(item => item.id !== id);

    const newDataList = new DataListModel(newList);

    await store.saveModelWithExpiry(
      CacheConstants.dataList,
      newDataList,
      Duration.days(365)
    );

    this.state = this.state.with({ dataList: newList });
  }


}
