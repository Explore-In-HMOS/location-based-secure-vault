import { BaseModel } from 'core/src/main/ets/base/BaseModel';
import { DataModel, DataModelJson } from './DataModel';

export interface DataListModelJson {
  dataList: DataModelJson[];
}

export class DataListModel implements BaseModel {
  dataList: DataModel[];

  constructor(dataList: DataModel[]) {
    this.dataList = dataList;
  }

  toJson(): DataListModelJson {
    return {
      dataList: this.dataList.map(dataList => dataList.toJson())
    };
  }

  static fromJson(json: DataListModelJson): DataListModel {
    const dataList = json.dataList.map(dataList => DataModel.fromJson(dataList));
    return new DataListModel(dataList);
  }
}