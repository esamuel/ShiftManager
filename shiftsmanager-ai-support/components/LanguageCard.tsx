
import React from 'react';
import { LanguageConfig } from '../types';

interface LanguageCardProps {
  lang: LanguageConfig;
  isActive: boolean;
  text: string;
}

const LanguageCard: React.FC<LanguageCardProps> = ({ lang, isActive, text }) => {
  const isRtl = lang.code === 'he';
  
  return (
    <div className={`relative p-5 rounded-2xl transition-all duration-300 border ${
      isActive 
        ? 'bg-blue-600/20 border-blue-400 shadow-[0_0_15px_rgba(96,165,250,0.3)]' 
        : 'bg-white/5 border-white/10 opacity-70'
    } ${text ? 'opacity-100 scale-[1.02]' : ''}`}>
      <div className="flex items-center justify-between mb-3" dir="ltr">
        <div className="flex items-center gap-3">
          <span className="text-3xl">{lang.flag}</span>
          <div>
            <h3 className="font-bold text-white leading-tight">{lang.name}</h3>
            <p className="text-xs text-blue-300 uppercase tracking-wider">{lang.nativeName}</p>
          </div>
        </div>
        {isActive && (
          <div className="flex gap-1">
            <div className="w-1 h-3 bg-blue-400 rounded-full animate-bounce" style={{ animationDelay: '0s' }}></div>
            <div className="w-1 h-3 bg-blue-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
            <div className="w-1 h-3 bg-blue-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
          </div>
        )}
      </div>
      <div 
        className="min-h-[60px] max-h-[120px] overflow-y-auto custom-scrollbar"
        dir={isRtl ? 'rtl' : 'ltr'}
      >
        {text ? (
          <p className={`text-sm text-slate-100 leading-relaxed font-medium ${isRtl ? 'text-right' : 'text-left'}`}>
            {text}
          </p>
        ) : (
          <p className="text-xs text-slate-500 italic">Waiting for query...</p>
        )}
      </div>
    </div>
  );
};

export default LanguageCard;
