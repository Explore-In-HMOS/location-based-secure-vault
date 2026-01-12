import { DataModel } from '../model/DataModel';

export interface IDashboardState {
  isLoading?: boolean;
  error?: string | null;
  message?: string;
  dataList?: DataModel[];
}
