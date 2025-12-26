
import React, { useState, useEffect, useRef, useCallback } from 'react';
import { GoogleGenAI, Modality } from '@google/genai';
import { decode, decodeAudioData, createBlob } from './utils/audio-utils';
import { SUPPORTED_LANGUAGES, SYSTEM_INSTRUCTION_BASE } from './constants';
import { TranscriptionItem } from './types';
import LanguageCard from './components/LanguageCard';

const STORAGE_KEY_HISTORY = 'shifts_manager_history';
const STORAGE_KEY_KNOWLEDGE = 'shifts_manager_knowledge';

const App: React.FC = () => {
  const [isActive, setIsActive] = useState(false);
  const [isMicEnabled, setIsMicEnabled] = useState(true);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [transcriptions, setTranscriptions] = useState<TranscriptionItem[]>([]);
  const [designerKnowledge, setDesignerKnowledge] = useState<string>(
    "1. If asked about pricing, mention we have a Free, Pro, and Enterprise tier.\n2. Emphasize our 24/7 technical support.\n3. Note that shift swaps require manager approval by default."
  );
  const [showConsole, setShowConsole] = useState(false);
  const [activeTab, setActiveTab] = useState<'knowledge' | 'deploy'>('knowledge');
  const [isWidgetMode, setIsWidgetMode] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentAnswers, setCurrentAnswers] = useState<Record<string, string>>({});

  const sessionRef = useRef<any>(null);
  const audioContextInRef = useRef<AudioContext | null>(null);
  const audioContextOutRef = useRef<AudioContext | null>(null);
  const nextStartTimeRef = useRef<number>(0);
  const sourcesRef = useRef<Set<AudioBufferSourceNode>>(new Set());
  const transcriptionRef = useRef<{ user: string; model: string }>({ user: '', model: '' });
  const micStreamRef = useRef<MediaStream | null>(null);
  const outputNodeRef = useRef<GainNode | null>(null);

  // Load history and custom knowledge
  useEffect(() => {
    const savedHistory = localStorage.getItem(STORAGE_KEY_HISTORY);
    const savedKnowledge = localStorage.getItem(STORAGE_KEY_KNOWLEDGE);
    if (savedHistory) setTranscriptions(JSON.parse(savedHistory));
    if (savedKnowledge) setDesignerKnowledge(savedKnowledge);
  }, []);

  // Persist data
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY_HISTORY, JSON.stringify(transcriptions));
  }, [transcriptions]);

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY_KNOWLEDGE, designerKnowledge);
  }, [designerKnowledge]);

  const stopSession = useCallback(() => {
    if (sessionRef.current) {
      sessionRef.current.close();
      sessionRef.current = null;
    }
    if (audioContextInRef.current) {
      audioContextInRef.current.close();
      audioContextInRef.current = null;
    }
    if (audioContextOutRef.current) {
      audioContextOutRef.current.close();
      audioContextOutRef.current = null;
    }
    if (micStreamRef.current) {
      micStreamRef.current.getTracks().forEach(track => track.stop());
      micStreamRef.current = null;
    }
    setIsActive(false);
    setIsSpeaking(false);
    sourcesRef.current.forEach(source => { try { source.stop(); } catch(e) {} });
    sourcesRef.current.clear();
    nextStartTimeRef.current = 0;
  }, []);

  const buildFinalInstruction = () => {
    const historyContext = transcriptions.slice(-8).map(t => `${t.type === 'user' ? 'User' : 'Assistant'}: ${t.text}`).join('\n');
    return `
${SYSTEM_INSTRUCTION_BASE}

DESIGNER KNOWLEDGE BASE (Mandatory Rules):
${designerKnowledge}

PREVIOUS CONVERSATION CONTEXT:
${historyContext || "None."}
    `.trim();
  };

  const startSession = async () => {
    try {
      setError(null);
      setCurrentAnswers({});
      const ai = new GoogleGenAI({ apiKey: process.env.API_KEY || '' });
      
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      micStreamRef.current = stream;
      
      audioContextInRef.current = new (window.AudioContext || (window as any).webkitAudioContext)({ sampleRate: 16000 });
      audioContextOutRef.current = new (window.AudioContext || (window as any).webkitAudioContext)({ sampleRate: 24000 });
      outputNodeRef.current = audioContextOutRef.current.createGain();
      outputNodeRef.current.connect(audioContextOutRef.current.destination);

      const dynamicInstruction = buildFinalInstruction();

      const sessionPromise = ai.live.connect({
        model: 'gemini-2.5-flash-native-audio-preview-09-2025',
        callbacks: {
          onopen: () => {
            setIsActive(true);
            if (audioContextOutRef.current?.state === 'suspended') audioContextOutRef.current.resume();

            const source = audioContextInRef.current!.createMediaStreamSource(stream);
            const scriptProcessor = audioContextInRef.current!.createScriptProcessor(4096, 1, 1);
            
            scriptProcessor.onaudioprocess = (e) => {
              if (!isMicEnabled) return;
              const inputData = e.inputBuffer.getChannelData(0);
              const pcmBlob = createBlob(inputData);
              sessionPromise.then(session => {
                session.sendRealtimeInput({ media: pcmBlob });
              });
            };

            source.connect(scriptProcessor);
            scriptProcessor.connect(audioContextInRef.current!.destination);
          },
          onmessage: async (message) => {
            const parts = message.serverContent?.modelTurn?.parts;
            if (parts && audioContextOutRef.current && outputNodeRef.current) {
              const ctx = audioContextOutRef.current;
              for (const part of parts) {
                const base64Audio = part.inlineData?.data;
                if (base64Audio) {
                  setIsSpeaking(true);
                  if (ctx.state === 'suspended') await ctx.resume();
                  const audioBuffer = await decodeAudioData(decode(base64Audio), ctx, 24000, 1);
                  const source = ctx.createBufferSource();
                  source.buffer = audioBuffer;
                  source.connect(outputNodeRef.current);
                  source.addEventListener('ended', () => {
                    sourcesRef.current.delete(source);
                    if (sourcesRef.current.size === 0) setIsSpeaking(false);
                  });
                  const scheduleTime = Math.max(nextStartTimeRef.current, ctx.currentTime);
                  source.start(scheduleTime);
                  nextStartTimeRef.current = scheduleTime + audioBuffer.duration;
                  sourcesRef.current.add(source);
                }
              }
            }

            if (message.serverContent?.inputTranscription) {
              transcriptionRef.current.user += message.serverContent.inputTranscription.text;
            }
            if (message.serverContent?.outputTranscription) {
              const text = message.serverContent.outputTranscription.text;
              transcriptionRef.current.model += text;
              parseResponseToBuckets(transcriptionRef.current.model);
            }

            if (message.serverContent?.turnComplete) {
              const userText = transcriptionRef.current.user.trim();
              const modelText = transcriptionRef.current.model.trim();
              if (userText || modelText) {
                  const newItems: TranscriptionItem[] = [];
                  if (userText) newItems.push({ type: 'user', text: userText, timestamp: Date.now() });
                  if (modelText) newItems.push({ type: 'model', text: modelText, timestamp: Date.now() });
                  setTranscriptions(prev => [...prev, ...newItems]);
              }
              transcriptionRef.current = { user: '', model: '' };
            }

            if (message.serverContent?.interrupted) {
              sourcesRef.current.forEach(s => { try { s.stop(); } catch(e) {} });
              sourcesRef.current.clear();
              nextStartTimeRef.current = 0;
              setIsSpeaking(false);
            }
          },
          onerror: (e) => {
            console.error('Session error:', e);
            setError('Connection error. Assistant brain might be overloaded.');
            stopSession();
          },
          onclose: () => stopSession()
        },
        config: {
          responseModalities: [Modality.AUDIO],
          speechConfig: { voiceConfig: { prebuiltVoiceConfig: { voiceName: 'Kore' } } },
          systemInstruction: dynamicInstruction,
          inputAudioTranscription: {},
          outputAudioTranscription: {}
        }
      });
      sessionRef.current = await sessionPromise;
    } catch (err: any) {
      setError(err.message || 'Mic access failed.');
      stopSession();
    }
  };

  const parseResponseToBuckets = (fullText: string) => {
    const buckets: Record<string, string> = {};
    const languages = SUPPORTED_LANGUAGES.map(l => l.name);
    languages.forEach(lang => {
        const regex = new RegExp(`${lang}:\\s*([\\s\\S]*?)(?=\\n|${languages.join(':|')}:|$)`, 'i');
        const match = fullText.match(regex);
        if (match && match[1]) buckets[lang] = match[1].trim();
    });
    if (Object.keys(buckets).length > 0) setCurrentAnswers(prev => ({ ...prev, ...buckets }));
  };

  const toggleSession = () => isActive ? stopSession() : startSession();
  const toggleMic = () => setIsMicEnabled(!isMicEnabled);
  const clearHistory = () => {
    if (confirm("Clear chat history? (Knowledge Base rules will remain)")) {
      setTranscriptions([]);
      setCurrentAnswers({});
    }
  };

  const transcriptEndRef = useRef<HTMLDivElement>(null);
  useEffect(() => transcriptEndRef.current?.scrollIntoView({ behavior: 'smooth' }), [transcriptions]);

  const embedCode = `<iframe 
  src="${window.location.origin}" 
  width="400" 
  height="700" 
  style="border:none; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); position: fixed; bottom: 20px; right: 20px; z-index: 9999;" 
  allow="microphone"
></iframe>`;

  return (
    <div className={`min-h-screen flex flex-col items-center p-4 md:p-8 relative overflow-hidden transition-all duration-700 ${isWidgetMode ? 'scale-90 bg-slate-950 rounded-[50px] border-[10px] border-slate-900 shadow-2xl max-w-[450px] mx-auto' : ''}`}>
      {/* Background decoration */}
      <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 opacity-50"></div>
      
      <header className="w-full max-w-6xl mb-12 text-center relative z-10">
        <div className="flex justify-center gap-4 mb-6">
           <button 
             onClick={() => setShowConsole(!showConsole)}
             className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-indigo-500/20 border border-indigo-500/30 text-indigo-300 text-xs font-bold uppercase tracking-widest hover:bg-indigo-500/30 transition-all"
           >
             <i className="fa-solid fa-sliders"></i>
             <span>Designer Console</span>
           </button>
           {!isWidgetMode && (
             <button 
               onClick={() => setIsWidgetMode(true)}
               className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-bold uppercase tracking-widest hover:bg-blue-500/20 transition-all"
             >
               <i className="fa-solid fa-expand"></i>
               <span>Widget Preview</span>
             </button>
           )}
        </div>
        <h1 className={`${isWidgetMode ? 'text-3xl' : 'text-5xl md:text-7xl'} font-extrabold tracking-tighter mb-4 bg-gradient-to-b from-white to-blue-300 bg-clip-text text-transparent transition-all`}>
          Polyglot Assistant
        </h1>
        <p className="text-slate-400 text-sm md:text-base font-medium tracking-tight">
          Support for <span className="text-blue-400">ShiftsManager.com</span>
        </p>
      </header>

      {/* Designer Side Panel */}
      <div className={`fixed inset-y-0 right-0 w-full md:w-[450px] bg-slate-900 border-l border-white/10 z-50 transform transition-transform duration-500 ease-in-out shadow-2xl flex flex-col ${showConsole ? 'translate-x-0' : 'translate-x-full'}`}>
        <div className="p-6 border-b border-white/10 flex justify-between items-center bg-slate-950/50">
          <h2 className="text-sm font-black uppercase tracking-tighter text-blue-400 flex items-center gap-2">
            <i className="fa-solid fa-microchip"></i> Assistant Brain
          </h2>
          <button onClick={() => setShowConsole(false)} className="text-slate-500 hover:text-white transition-colors">
            <i className="fa-solid fa-xmark text-xl"></i>
          </button>
        </div>

        {/* Console Tabs */}
        <div className="flex bg-slate-950/30">
          <button 
            onClick={() => setActiveTab('knowledge')}
            className={`flex-1 py-3 text-[10px] font-black uppercase tracking-widest border-b-2 transition-all ${activeTab === 'knowledge' ? 'border-blue-500 text-blue-400 bg-blue-500/5' : 'border-transparent text-slate-500'}`}
          >
            Correction Rules
          </button>
          <button 
            onClick={() => setActiveTab('deploy')}
            className={`flex-1 py-3 text-[10px] font-black uppercase tracking-widest border-b-2 transition-all ${activeTab === 'deploy' ? 'border-green-500 text-green-400 bg-green-500/5' : 'border-transparent text-slate-500'}`}
          >
            Deploy to Website
          </button>
        </div>

        <div className="p-6 flex-1 overflow-y-auto custom-scrollbar space-y-6">
          {activeTab === 'knowledge' ? (
            <>
              <section>
                <label className="block text-[10px] font-bold text-slate-500 uppercase mb-2 tracking-widest">
                  Custom Knowledge & Correction
                </label>
                <p className="text-[11px] text-slate-400 mb-3 italic leading-relaxed">
                  The AI reads these rules every time you connect. Use this to correct its mistakes.
                </p>
                <textarea 
                  value={designerKnowledge}
                  onChange={(e) => setDesignerKnowledge(e.target.value)}
                  className="w-full h-[250px] bg-black/40 border border-white/10 rounded-xl p-4 text-sm text-blue-100 focus:border-blue-500 outline-none transition-all font-mono leading-relaxed"
                  placeholder="Enter specific rules or product knowledge here..."
                />
              </section>
              <button 
                onClick={clearHistory}
                className="w-full py-3 rounded-xl bg-red-500/10 text-red-400 border border-red-500/20 text-xs font-bold uppercase hover:bg-red-500/20 transition-all"
              >
                Reset Interaction History
              </button>
            </>
          ) : (
            <div className="space-y-6">
              <section className="bg-green-500/5 border border-green-500/20 p-5 rounded-2xl">
                 <h3 className="text-green-400 text-xs font-black uppercase mb-2 flex items-center gap-2">
                   <i className="fa-solid fa-code"></i> Iframe Embed Code
                 </h3>
                 <p className="text-[10px] text-slate-400 mb-4 leading-relaxed">
                   Copy this into your website's HTML to display the assistant. 
                   <strong> IMPORTANT:</strong> The <code>allow="microphone"</code> attribute is required.
                 </p>
                 <div className="relative group">
                    <pre className="bg-black/60 p-4 rounded-lg text-[11px] text-green-200 overflow-x-auto font-mono border border-white/5 whitespace-pre-wrap">
                      {embedCode}
                    </pre>
                    <button 
                      onClick={() => { navigator.clipboard.writeText(embedCode); alert('Code copied!'); }}
                      className="absolute top-2 right-2 bg-green-600 text-white px-2 py-1 rounded text-[9px] font-bold uppercase hover:bg-green-500"
                    >
                      Copy
                    </button>
                 </div>
              </section>

              <section className="bg-white/5 p-5 rounded-2xl border border-white/5 space-y-4">
                 <h4 className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Layout Settings</h4>
                 <div className="flex items-center justify-between">
                    <span className="text-xs text-slate-300">Widget Mode Preview</span>
                    <button 
                      onClick={() => setIsWidgetMode(!isWidgetMode)}
                      className={`w-12 h-6 rounded-full transition-all relative ${isWidgetMode ? 'bg-blue-600' : 'bg-slate-700'}`}
                    >
                      <div className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-all ${isWidgetMode ? 'right-1' : 'left-1'}`}></div>
                    </button>
                 </div>
              </section>
            </div>
          )}
        </div>
        <div className="p-4 bg-slate-950/50 border-t border-white/10 text-center">
          <p className="text-[9px] text-slate-500 uppercase font-black">Changes persist across reloads</p>
        </div>
      </div>

      <main className={`w-full max-w-6xl flex flex-col gap-8 relative z-10 transition-all ${isWidgetMode ? 'gap-4' : 'gap-8'}`}>
        {isWidgetMode && (
          <button 
            onClick={() => setIsWidgetMode(false)}
            className="self-end text-[10px] font-black uppercase text-slate-500 hover:text-white"
          >
            <i className="fa-solid fa-compress mr-1"></i> Exit Preview
          </button>
        )}

        {/* Main Interaction Hub */}
        <div className={`flex flex-col items-center justify-center bg-white/5 border border-white/10 rounded-3xl backdrop-blur-xl relative overflow-hidden transition-all ${isWidgetMode ? 'p-6' : 'p-12'}`}>
          <div className="flex flex-col md:flex-row items-center gap-8 md:gap-12">
             <div className="relative">
                {isActive && (
                  <>
                    <div className="absolute -inset-8 rounded-full bg-blue-500/10 pulse-ring"></div>
                    <div className="absolute -inset-16 rounded-full bg-blue-400/5 pulse-ring" style={{ animationDelay: '0.6s' }}></div>
                  </>
                )}
                <button
                  onClick={toggleSession}
                  className={`relative z-10 rounded-full flex flex-col items-center justify-center gap-2 transition-all duration-700 shadow-2xl ${
                    isWidgetMode ? 'w-24 h-24' : 'w-32 h-32 md:w-44 md:h-44'
                  } ${
                    isActive 
                    ? 'bg-red-500 hover:bg-red-600 shadow-red-500/40 rotate-180' 
                    : 'bg-blue-600 hover:bg-blue-700 shadow-blue-500/40'
                  }`}
                >
                  <span className={isWidgetMode ? 'text-2xl' : 'text-4xl md:text-5xl'}>
                    {isActive ? <i className="fa-solid fa-power-off"></i> : <i className="fa-solid fa-headset"></i>}
                  </span>
                  <span className="text-[9px] uppercase font-black tracking-[0.2em] mt-1">
                    {isActive ? 'Stop' : 'Ask'}
                  </span>
                </button>
              </div>

              <div className={`flex flex-col gap-6 transition-all duration-500 ${isActive ? 'opacity-100 scale-100' : 'opacity-20 scale-90 grayscale pointer-events-none'}`}>
                <div className="flex flex-col items-center gap-3">
                  <button 
                    onClick={toggleMic}
                    className={`${isWidgetMode ? 'w-12 h-12 text-lg' : 'w-16 h-16 text-2xl'} rounded-3xl flex items-center justify-center shadow-lg transition-all transform hover:scale-105 active:scale-95 ${
                      isMicEnabled 
                      ? 'bg-gradient-to-br from-green-400 to-green-600 text-white shadow-green-500/30' 
                      : 'bg-slate-800 text-slate-500'
                    }`}
                  >
                    <i className={`fa-solid ${isMicEnabled ? 'fa-microphone' : 'fa-microphone-slash'}`}></i>
                  </button>
                  <span className="text-[9px] uppercase font-black tracking-widest text-slate-400">
                     {isMicEnabled ? 'Live' : 'Mute'}
                  </span>
                </div>
              </div>
          </div>

          {!isWidgetMode && (
            <div className="text-center mt-12 space-y-2">
              <h2 className="text-3xl font-black tracking-tight">
                {isActive ? (isSpeaking ? 'Responding...' : (isMicEnabled ? 'Listening...' : 'Mic Muted')) : 'Ready to help'}
              </h2>
              <p className="text-slate-400 max-w-sm mx-auto text-sm font-medium">
                Multilingual AI Support with Knowledge Memory
              </p>
            </div>
          )}

          {error && (
            <div className="mt-8 px-6 py-3 bg-red-500/10 border border-red-500/20 rounded-full text-red-400 text-xs font-bold animate-pulse flex items-center gap-2">
              <i className="fa-solid fa-triangle-exclamation"></i> {error}
            </div>
          )}
        </div>

        {/* Multilingual Output Grid */}
        <div className={`grid gap-4 ${isWidgetMode ? 'grid-cols-2' : 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3'}`}>
          {SUPPORTED_LANGUAGES.map((lang) => (
            <LanguageCard 
              key={lang.code} 
              lang={lang} 
              isActive={isSpeaking && currentAnswers[lang.name] !== undefined}
              text={currentAnswers[lang.name] || ''} 
            />
          ))}
        </div>

        {/* History Scroll */}
        {transcriptions.length > 0 && !isWidgetMode && (
          <div className="mt-8 p-8 bg-black/30 border border-white/5 rounded-[40px] backdrop-blur-sm h-[450px] overflow-y-auto custom-scrollbar flex flex-col gap-6">
            <div className="flex items-center justify-between sticky top-0 bg-transparent z-20 mb-4 px-2">
               <h3 className="text-[10px] font-black uppercase tracking-[0.3em] text-blue-500 flex items-center gap-3">
                 <div className="w-1.5 h-1.5 bg-blue-500 rounded-full animate-ping"></div>
                 Session Stream
               </h3>
               <span className="text-[9px] text-slate-500 uppercase font-black">Designer Learning Active</span>
            </div>
            {transcriptions.map((t, idx) => (
              <div 
                key={idx} 
                className={`flex flex-col max-w-[80%] ${t.type === 'user' ? 'self-end items-end' : 'self-start items-start'}`}
              >
                <div className={`px-5 py-4 rounded-3xl text-sm leading-relaxed ${
                  t.type === 'user' 
                  ? 'bg-blue-600 text-white rounded-tr-none shadow-xl shadow-blue-900/20' 
                  : 'bg-white/5 text-slate-200 border border-white/10 rounded-tl-none'
                }`}>
                  {t.text}
                </div>
                <span className="text-[9px] text-slate-500 mt-2 uppercase font-black tracking-widest ml-1 mr-1">
                  {t.type === 'user' ? 'Question' : 'Answer'}
                </span>
              </div>
            ))}
            <div ref={transcriptEndRef} />
          </div>
        )}
      </main>

      {!isWidgetMode && (
        <footer className="mt-auto py-12 text-slate-600 text-[10px] font-black uppercase tracking-[0.5em] text-center w-full">
          Live AI Assistant • ShiftsManager.com
        </footer>
      )}

      <style>{`
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(59, 130, 246, 0.3); }
      `}</style>
    </div>
  );
};

export default App;
