import { DataModel } from '../model/DataModel';
import './IDashboardState'
import { IDashboardState } from './IDashboardState';

export class DashboardState {
  public isLoading: boolean;
  public readonly error?: string;
  public message?: string;
  public dataList?: DataModel[];

  constructor(init: IDashboardState) {
    this.isLoading = init.isLoading ?? true;
    this.error = init.error === null ? undefined : init.error;
    this.message = init.message === null ? undefined : init.message;
    this.dataList = init.dataList ?? []
  }

  with(updates: IDashboardState): DashboardState {
    return new DashboardState({
      isLoading: updates.isLoading ?? this.isLoading,
      error: updates.error === null ? undefined : (updates.error ?? this.error),
      message: updates.message === null ? undefined : (updates.message ?? this.message),
      dataList: updates.dataList ?? this.dataList
    });
  }

  static initial(): DashboardState {
    return new DashboardState({
      isLoading: false,
      error: null,
      message: '',
      dataList: []
    });
  }
}
