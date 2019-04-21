//+------------------------------------------------------------------+
//|                                                    ExpertInd.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"

#include <Expert\Expert.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CExpertInd : public CExpert
  {
  public:
  virtual bool      RefreshInd(void);
  };  
//+------------------------------------------------------------------+
//| Refreshing data for processing                                   |
//+------------------------------------------------------------------+
bool CExpertInd::RefreshInd(void)
  {
   MqlDateTime time;
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- check need processing
   TimeToStruct(m_symbol.Time(),time);
   if(m_period_flags!=WRONG_VALUE && m_period_flags!=0)
      if((m_period_flags&TimeframesFlags(time))==0)
         return(false);
   m_last_tick_time=time;
//--- refresh indicators
   m_indicators.Refresh();
//--- ok
   return(true);
  }
