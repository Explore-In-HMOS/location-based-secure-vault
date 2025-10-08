import { BaseModel } from 'core/src/main/ets/base/BaseModel';

export interface DataModelJson {
  id: string,
  title: string,
  content: string,
}

export class DataModel implements BaseModel {
  id: string
  title: string
  content: string

  constructor(
    id: string,
    title: string,
    content: string,
  ) {
    this.id = id;
    this.title = title;
    this.content = content;
  }

  toJson(): DataModelJson {
    return {
      id: this.id,
      title: this.title,
      content: this.content,
    };
  }

  static fromJson(json: DataModelJson): DataModel {
    return new DataModel(
      json.id,
      json.title,
      json.content,
    );
  }
}