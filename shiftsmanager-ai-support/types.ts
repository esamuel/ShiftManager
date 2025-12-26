
export interface LanguageConfig {
  code: string;
  name: string;
  flag: string;
  nativeName: string;
}

export interface TranscriptionItem {
  type: 'user' | 'model';
  text: string;
  timestamp: number;
}
