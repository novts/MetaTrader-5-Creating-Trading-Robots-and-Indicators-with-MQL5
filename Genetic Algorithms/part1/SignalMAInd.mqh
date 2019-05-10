//+------------------------------------------------------------------+
//|                                                 SignalMAInd .mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"

#include <Expert\Signal\SignalMA.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalMAInd : public CSignalMA
  {
  public:
  virtual int       BarsCalculatedInd();               
  virtual int       LongConditionInd(int ind);
  virtual int       ShortConditionInd(int ind);                  
  };
//+------------------------------------------------------------------+  
int CSignalMAInd:: BarsCalculatedInd(){
return m_ma.BarsCalculated();
}

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMAInd::LongConditionInd(int idx)
  {
  
   int result=0;
   
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA(idx)<0.0)
     {
      //--- the close price is below the indicator
      if(IS_PATTERN_USAGE(1) && DiffOpenMA(idx)>0.0 && DiffMA(idx)>0.0)
        {
         //--- the open price is above the indicator (i.e. there was an intersection), but the indicator is directed upwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
        }
     }
   else
     {
      //--- the close price is above the indicator (the indicator has no objections to buying)
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;
      //--- if the indicator is directed upwards
      if(DiffMA(idx)>0.0)
        {
         if(DiffOpenMA(idx)<0.0)
           {
            //--- if the model 2 is used
            if(IS_PATTERN_USAGE(2))
              {
               //--- the open price is below the indicator (i.e. there was an intersection)
               result=m_pattern_2;
               //--- suggest to enter the market at the "roll back"
               m_base_price=m_symbol.NormalizePrice(MA(idx));
              }
           }
         else
           {
            //--- if the model 3 is used and the open price is above the indicator
            if(IS_PATTERN_USAGE(3) && DiffLowMA(idx)<0.0)
              {
               //--- the low price is below the indicator
               result=m_pattern_3;
               //--- consider that this is a formed "piercing" and suggest to enter the market at the current price
               m_base_price=0.0;
              }
           }
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalMAInd::ShortConditionInd(int idx)
  {
   int result=0;
   
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA(idx)>0.0)
     {
      //--- the close price is above the indicator
      if(IS_PATTERN_USAGE(1) && DiffOpenMA(idx)<0.0 && DiffMA(idx)<0.0)
        {
         //--- the open price is below the indicator (i.e. there was an intersection), but the indicator is directed downwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
        }
     }
   else
     {
      //--- the close price is below the indicator (the indicator has no objections to buying)
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;
      //--- the indicator is directed downwards
      if(DiffMA(idx)<0.0)
        {
         if(DiffOpenMA(idx)>0.0)
           {
            //--- if the model 2 is used
            if(IS_PATTERN_USAGE(2))
              {
               //--- the open price is above the indicator (i.e. there was an intersection)
               result=m_pattern_2;
               //--- suggest to enter the market at the "roll back"
               m_base_price=m_symbol.NormalizePrice(MA(idx));
              }
           }
         else
           {
            //--- if the model 3 is used and the open price is below the indicator
            if(IS_PATTERN_USAGE(3) && DiffHighMA(idx)>0.0)
              {
               //--- the high price is above the indicator
               result=m_pattern_3;
               //--- consider that this is a formed "piercing" and suggest to enter the market at the current price
               m_base_price=0.0;
              }
           }
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
