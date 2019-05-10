//+------------------------------------------------------------------+
//|                                                SignalMACDInd.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"

#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalMACDInd : public CSignalMACD
  {
  public: 
  virtual int       BarsCalculatedInd();                  
  virtual int       LongConditionInd(int ind);
  virtual int       ShortConditionInd(int ind);
  
  };                                          
//+------------------------------------------------------------------+  
int CSignalMACDInd:: BarsCalculatedInd(){
return m_MACD.BarsCalculated();
}

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMACDInd::LongConditionInd(int idx)
  {
   int result=0;
   
//--- check direction of the main line
   if(DiffMain(idx)>0.0)
     {
      //--- the main line is directed upwards, and it confirms the possibility of price growth
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)<0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State(idx)>0.0 && State(idx+1)<0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && Main(idx)>0.0 && Main(idx+1)<0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned upwards below the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && Main(idx)<0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx);
         //--- if the model 4 is used, look for the "divergence" signal
         if(IS_PATTERN_USAGE(4) && CompareMaps(1,1)) // 0000 0001b
            result=m_pattern_4;   // signal number 4
         //--- if the model 5 is used, look for the "double divergence" signal
         if(IS_PATTERN_USAGE(5) && CompareMaps(0x11,2)) // 0001 0001b
            return(m_pattern_5);  // signal number 5
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalMACDInd::ShortConditionInd(int idx)
  {
   int result=0;
   
//--- check direction of the main line
   if(DiffMain(idx)<0.0)
     {
      //--- main line is directed downwards, confirming a possibility of falling of price
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)>0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State(idx)<0.0 && State(idx+1)>0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && Main(idx)<0.0 && Main(idx+1)>0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned downwards above the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && Main(idx)>0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx);
         //--- if the model 4 is used, look for the "divergence" signal
         if(IS_PATTERN_USAGE(4) && CompareMaps(1,1)) // 0000 0001b
            result=m_pattern_4;   // signal number 4
         //--- if the model 5 is used, look for the "double divergence" signal
         if(IS_PATTERN_USAGE(5) && CompareMaps(0x11,2)) // 0001 0001b
            return(m_pattern_5);  // signal number 5
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+  
