import './IVaultState'
import { IVaultState } from './IVaultState';

export class VaultState {
  public isLoading: boolean;
  public readonly error?: string;
  public message?: string;

  constructor(init: IVaultState) {
    this.isLoading = init.isLoading ?? true;
    this.error = init.error === null ? undefined : init.error;
    this.message = init.message === null ? undefined : init.message;
  }

  with(updates: IVaultState): VaultState {
    return new VaultState({
      isLoading: updates.isLoading ?? this.isLoading,
      error: updates.error === null ? undefined : (updates.error ?? this.error),
      message: updates.message === null ? undefined : (updates.message ?? this.message)
    });
  }

  static initial(): VaultState {
    return new VaultState({
      isLoading: false,
      error: null,
      message: ''
    });
  }
}
