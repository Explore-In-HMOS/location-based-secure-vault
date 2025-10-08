import { asset } from '@kit.AssetStoreKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseModel } from '../base/BaseModel';
import { Duration } from '../base/DurationModel';
import { LogManager } from '../logger/LogManager';

function stringToArray(str: string): Uint8Array {
  const encoder = new util.TextEncoder();
  return encoder.encodeInto(str);
}

function arrayToString(arr: Uint8Array): string {
  const decoder = new util.TextDecoder('utf-8', { ignoreBOM: true });
  return decoder.decode(arr);
}

interface AssetDataExpiryModel<TJson> {
  data: TJson;
  expireAt: number;
}

interface AssetStoreInterface {
  persistent?: boolean;
  accessibility?: number;
}

export class AssetStoreManager {
  private static instance: AssetStoreManager;
  private isPersistent: boolean = true;
  private accessibility: number = asset.Accessibility.DEVICE_FIRST_UNLOCKED;
  private initialized = false;
  private static TAG = 'AssetStoreManager'

  private constructor() {}

  static getInstance(): AssetStoreManager {
    if (!AssetStoreManager.instance) {
      AssetStoreManager.instance = new AssetStoreManager();
    }
    return AssetStoreManager.instance;
  }

  public init(options?: AssetStoreInterface): void {
    if (this.initialized){
     return
    }

    if (options?.persistent) {
      this.isPersistent = options.persistent ?? true;
    }
    if (typeof options?.accessibility === 'number') {
      this.accessibility = options.accessibility;
    }

    this.initialized = true;
    LogManager.info(AssetStoreManager.TAG,`AssetStoreManager initialized. persistent=${!!options?.persistent}, accessibility=${this.accessibility}`)
  }

  async set(key: string, value: string): Promise<void> {
    const attr: asset.AssetMap = new Map();
    attr.set(asset.Tag.ALIAS, stringToArray(key));
    attr.set(asset.Tag.SECRET, stringToArray(value));
    attr.set(asset.Tag.ACCESSIBILITY, this.accessibility);
    attr.set(asset.Tag.IS_PERSISTENT, this.isPersistent);
    attr.set(asset.Tag.DATA_LABEL_NORMAL_1, stringToArray('label-' + key));

    try {
      await asset.add(attr);
      LogManager.info(AssetStoreManager.TAG,`Asset added for key: ${key}`)
    } catch (err) {
      const e = err as BusinessError;
      LogManager.error(AssetStoreManager.TAG,`Asset add failed. Code: ${e.code}, message: ${e.message}`)
    }
  }

  async get(key: string): Promise<string | null> {
    const queryMap: asset.AssetMap = new Map();
    queryMap.set(asset.Tag.ALIAS, stringToArray(key));
    queryMap.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);

    try {
      const results = await asset.query(queryMap);
      if (!results || results.length === 0){
        return null
      }
      const secret = results[0].get(asset.Tag.SECRET) as Uint8Array | undefined;
      return secret ? arrayToString(secret) : null;
    } catch (err) {
      const e = err as BusinessError;
      LogManager.error(AssetStoreManager.TAG,`Asset get failed. Code: ${e.code}, message: ${e.message}`)
      return null;
    }
  }

  async setWithPassword(key: string, value: string): Promise<void> {
    const attr: asset.AssetMap = new Map();
    attr.set(asset.Tag.ALIAS, stringToArray(key));
    attr.set(asset.Tag.SECRET, stringToArray(value));
    attr.set(asset.Tag.REQUIRE_PASSWORD_SET, true);
    attr.set(asset.Tag.ACCESSIBILITY, this.accessibility);
    attr.set(asset.Tag.IS_PERSISTENT, this.isPersistent);
    attr.set(asset.Tag.DATA_LABEL_NORMAL_1, stringToArray('label-' + key));

    try {
      await asset.add(attr);
    } catch (err) {
      LogManager.error(AssetStoreManager.TAG,`Asset add with password failed for key: ${key}`)
    }
  }

  async getWithPassword(key: string): Promise<string | null> {
    const queryMap: asset.AssetMap = new Map();
    queryMap.set(asset.Tag.ALIAS, stringToArray(key));
    queryMap.set(asset.Tag.REQUIRE_PASSWORD_SET, true);
    queryMap.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);

    try {
      const results = await asset.query(queryMap);
      if (!results || results.length === 0){
        return null
      }
      const secret = results[0].get(asset.Tag.SECRET) as Uint8Array | undefined;
      return secret ? arrayToString(secret) : null;
    } catch (err) {
      LogManager.error(AssetStoreManager.TAG,`Asset get with password failed for key: ${key}`)
      return null;
    }
  }

  async remove(key: string): Promise<void> {
    const removeMap: asset.AssetMap = new Map();
    removeMap.set(asset.Tag.ALIAS, stringToArray(key));

    try {
      await asset.remove(removeMap);
    } catch (err) {
      LogManager.error(AssetStoreManager.TAG,`Asset remove failed for key: ${key}`)
    }
  }

  async clear(keys: string[]): Promise<void> {
    await Promise.all(keys.map(key => this.remove(key)));
  }

  async update(key: string, newValue: string): Promise<void> {
    const queryMap: asset.AssetMap = new Map();
    queryMap.set(asset.Tag.ALIAS, stringToArray(key));
    queryMap.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);

    try {
      const results = await asset.query(queryMap);
      if (!results || results.length === 0){
        return
      }

      const existing = results[0];
      await asset.remove(queryMap);

      const attr: asset.AssetMap = new Map();
      attr.set(asset.Tag.ALIAS, stringToArray(key));
      attr.set(asset.Tag.SECRET, stringToArray(newValue));
      attr.set(asset.Tag.ACCESSIBILITY, this.accessibility);
      attr.set(asset.Tag.IS_PERSISTENT, this.isPersistent);
      attr.set(asset.Tag.DATA_LABEL_NORMAL_1, stringToArray('label-' + key));

      const pwd = existing.get(asset.Tag.REQUIRE_PASSWORD_SET);
      if (pwd){
        attr.set(asset.Tag.REQUIRE_PASSWORD_SET, pwd);
      }

      await asset.add(attr);
    } catch (err) {
      LogManager.error(AssetStoreManager.TAG,`Asset update failed for key: ${key}`)
    }
  }

  async checkExists(key: string): Promise<boolean> {
    const queryMap: asset.AssetMap = new Map();
    queryMap.set(asset.Tag.ALIAS, stringToArray(key));
    queryMap.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ATTRIBUTES);

    try {
      const result = await asset.query(queryMap);
      return result.length > 0 && result[0].has(asset.Tag.SECRET);
    } catch (err) {
      LogManager.error(AssetStoreManager.TAG, `Asset existence check failed for key: ${key}`)
      return false;
    }
  }

  async saveModel<T extends BaseModel>(key: string, model: T): Promise<void> {
    await this.set(key, JSON.stringify(model.toJson()));
  }

  async saveModelWithExpiry<T extends BaseModel>(key: string, model: T, duration: Duration): Promise<void> {

    const ms = duration.inMilliseconds();
    if (ms <= 0){
      throw new Error('Invalid duration for expiry');
    }

    const wrapper: AssetDataExpiryModel<object> = {
      data: model.toJson(),
      expireAt: Date.now() + ms
    };

    try {
      hilog.error(0,'asset','try catch')
      await this.remove(key)
      await this.set(key, JSON.stringify(wrapper));
    } catch (e) {
      LogManager.error(AssetStoreManager.TAG, `save model with expiry error: ${e}`)
    }
  }

  async updateModelWithExpiry<T extends BaseModel>(key: string, model: T, duration: Duration): Promise<void> {
    const ms = duration.inMilliseconds();
    if (ms <= 0){
      throw new Error('Invalid duration for expiry');
    }

    const wrapper: AssetDataExpiryModel<object> = {
      data: model.toJson(),
      expireAt: Date.now() + ms
    };
    await this.update(key, JSON.stringify(wrapper));
  }

  async getModelWithExpiry<TModel, TJson>(key: string, fromJson: (json: TJson) => TModel): Promise<TModel | null> {
    const value = await this.get(key);
    if (!value){
      return null
    }

    try {
      const parsed: AssetDataExpiryModel<TJson> = JSON.parse(value);
      if (Date.now() > parsed.expireAt) {
        await this.remove(key);
        return null;
      }

      return fromJson(parsed.data);
    } catch (e) {
      LogManager.error(AssetStoreManager.TAG, `getModelWithExpiry parse error for key: ${key} ${e}`)
      return null;
    }
  }

  async getJson<TModel, TJson>(key: string, fromJson: (json: TJson) => TModel): Promise<TModel | null> {
    const value = await this.get(key);
    if (!value){
      return null
    }

    try {
      const parsed: TJson = JSON.parse(value);
      return fromJson(parsed);
    } catch (e) {
      LogManager.error(AssetStoreManager.TAG, `getJson parse error for key: ${key}`)
      return null;
    }
  }

  async getModel<TModel, TJson>(key: string, fromJson: (json: TJson) => TModel): Promise<TModel | null> {
    return this.getJson<TModel, TJson>(key, fromJson);
  }
}

export default AssetStoreManager;


