import { DashboardState } from '../state/DashboardState';
import { common } from '@kit.AbilityKit';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';
import { NavigationConstants } from '../utils/constants/NavigationConstants';
import { AssetStoreManager } from 'core/src/main/ets/storage/AssetStoreManager'
import { CacheConstants } from '../utils/constants/CacheConstants';
import { DataListModel } from '../model/DataListModel';
import { Duration } from 'core/src/main/ets/base/DurationModel';

export class DashboardViewModel {
  private _state: DashboardState = DashboardState.initial();
  private listeners: Array<(state: DashboardState) => void> = [];
  private readonly TAG = 'DashboardViewModel';
  context = getContext(this) as common.UIAbilityContext;

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
    const store = await AssetStoreManager.getInstance()
    let data = await store.getModelWithExpiry(CacheConstants.dataList,DataListModel.fromJson)
    let list = data?.dataList
    this.state = this.state.with({isLoading: false,dataList: list})

  }

  onClickEditorButton(){
    NavigationManager.getInstance().pageInfos.pushPath({name: NavigationConstants.editor})
  }

 async  deleteNoteByIndex(index: number) : Promise<void> {
    const store = await AssetStoreManager.getInstance()
    let newList = this.state.dataList ?? [];
    let newDataList = new DataListModel(newList)
    newList.splice(index, 1);
    await store.saveModelWithExpiry(CacheConstants.dataList,newDataList,Duration.days(365))
    this.state = this.state.with({dataList: newList})
  }

}
