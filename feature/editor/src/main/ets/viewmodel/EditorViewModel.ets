import { EditorState } from '../state/EditorState';
import { common } from '@kit.AbilityKit';
import { AssetStoreManager } from 'core/src/main/ets/storage/AssetStoreManager';
import { CacheConstants } from '../constants/CacheConstants';
import { DataListModel } from '../model/DataListModel';
import { DataModel } from '../model/DataModel';
import { Duration } from 'core/src/main/ets/base/DurationModel';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';
import { NavigationConstants } from '../constants/NavigationConstants';

export class EditorViewModel {
  private _state: EditorState = EditorState.initial();
  private listeners: Array<(state: EditorState) => void> = [];
  private readonly TAG = 'EditorViewModel';
  context = getContext(this) as common.UIAbilityContext;

  get state(): EditorState {
    return this._state;
  }

  set state(newState: EditorState) {
    this._state = newState;
    this.notifyListeners();
  }

  addListener(listener: (state: EditorState) => void): void {
    this.listeners.push(listener);
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this._state));
  }

  async init(): Promise<void> {


  }

  setText(value: string){
    this.state = this.state.with({text: value})
  }

  setTitle(value: string){
    this.state = this.state.with({title: value})
  }

  async saveNote() : Promise<void> {
    this.state = this.state.with({isLoading: true})
    const assetStore = AssetStoreManager.getInstance()
    const data = await assetStore.getModelWithExpiry(CacheConstants.dataList,DataListModel.fromJson)
    let list = data?.dataList ?? []
    const note = this.state.text
    const title = this.state.title
    if (note != null && note.trim().length > 0 && title != null && title.trim().length > 0){
      let newData = new DataModel(Date.now().toString(),title,note)
      list.push(newData)
      let dataList = new DataListModel(list)
      await assetStore.saveModelWithExpiry(CacheConstants.dataList,dataList,Duration.days(365))
      this.state = this.state.with({isLoading: false})
      NavigationManager.getInstance().pageInfos.pushPath({name: NavigationConstants.dashboard})
    }else{
      this.state = this.state.with({isLoading: false})
    }
  }

}
