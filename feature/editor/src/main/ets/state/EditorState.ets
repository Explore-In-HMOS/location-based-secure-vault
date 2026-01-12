import './IEditorState'
import { IEditorState } from './IEditorState';

export class EditorState {
  public isLoading: boolean;
  public readonly error?: string;
  public message?: string;
  public text?: string | null;
  public title?: string | null;

  constructor(init: IEditorState) {
    this.isLoading = init.isLoading ?? true;
    this.error = init.error === null ? undefined : init.error;
    this.message = init.message === null ? undefined : init.message;
    this.text = init.text;
    this.title = init.title;
  }

  with(updates: IEditorState): EditorState {
    return new EditorState({
      isLoading: updates.isLoading ?? this.isLoading,
      error: updates.error === null ? undefined : (updates.error ?? this.error),
      message: updates.message === null ? undefined : (updates.message ?? this.message),
      text: updates.text ?? this.text,
      title: updates.title ?? this.title
    });
  }

  static initial(): EditorState {
    return new EditorState({
      isLoading: false,
      error: null,
      message: '',
      text: null,
      title: null
    });
  }
}
