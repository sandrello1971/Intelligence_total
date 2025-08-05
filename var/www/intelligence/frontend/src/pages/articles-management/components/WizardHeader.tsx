import React from 'react';

interface WizardHeaderProps {
 currentStep: string;
 steps: string[];
 selectedType: 'semplice' | 'kit_commerciale' | null;
}

const WizardHeader: React.FC<WizardHeaderProps> = ({ 
 currentStep, 
 steps, 
 selectedType 
}) => {
 const stepLabels = {
   type: 'Tipo',
   config: 'Configurazione',
   'kit-composition': 'Composizione Kit',
   review: 'Riepilogo'
 };
 
 const stepIcons = {
   type: '🎯',
   config: '⚙️',
   'kit-composition': '🧩',
   review: '👀'
 };
 
 const getCurrentStepIndex = () => {
   return steps.indexOf(currentStep);
 };
 
 const getStepStatus = (step: string, index: number) => {
   const currentIndex = getCurrentStepIndex();
   if (index < currentIndex) return 'completed';
   if (index === currentIndex) return 'current';
   return 'pending';
 };
 
 return (
   <div className="wizard-header">
     <div className="wizard-title">
       <h1>
         {selectedType === 'semplice' ? '📄 Nuovo Articolo' : 
          selectedType === 'kit_commerciale' ? '📦 Nuovo Kit Commerciale' : 
          '✨ Creazione Guidata'}
       </h1>
       {selectedType && (
         <p>
           {selectedType === 'semplice' 
             ? 'Crea un nuovo articolo singolo'
             : 'Crea un nuovo kit commerciale con articoli multipli'}
         </p>
       )}
     </div>
     
     <div className="wizard-progress">
       <div className="steps-container">
         {steps.map((step, index) => {
           const status = getStepStatus(step, index);
           return (
             <div key={step} className={`step ${status}`}>
               <div className="step-indicator">
                 <div className="step-icon">
                   {status === 'completed' ? '✅' : stepIcons[step as keyof typeof stepIcons]}
                 </div>
                 <div className="step-number">{index + 1}</div>
               </div>
               <div className="step-label">
                 {stepLabels[step as keyof typeof stepLabels]}
               </div>
               {index < steps.length - 1 && (
                 <div className={`step-connector ${status === 'completed' ? 'completed' : ''}`} />
               )}
             </div>
           );
         })}
       </div>
       
       <div className="progress-bar">
         <div 
           className="progress-fill"
           style={{ 
             width: `${((getCurrentStepIndex() + 1) / steps.length) * 100}%` 
           }}
         />
       </div>
     </div>
   </div>
 );
};

export default WizardHeader;
