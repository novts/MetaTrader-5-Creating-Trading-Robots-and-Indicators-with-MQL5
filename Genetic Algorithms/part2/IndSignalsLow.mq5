//+------------------------------------------------------------------+
//|                                                IndSignalsLow.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window
 
#include <Expert\ExpertInd.mqh>
#include <Expert\Signal\SignalMACDIndLow.mqh>
#include <Expert\Signal\SignalMAIndLow.mqh>
 
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1  clrBlack,clrRed,clrLawnGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
 
double         InBuffer[];
double         ColorBuffer[];
int    bars_calculated=0;
 
input int                Signal_ThresholdOpen          =20;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =20;          // Signal threshold value to close [0...100]
 
input int                Signal_MACD_PeriodFast        =12;          // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow        =24;          // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal      =9;           // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied           =PRICE_CLOSE; // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight            =1.0;         // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]
input int                Signal_MA_PeriodMA            =12;          // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift               =0;           // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method              =MODE_SMA;    // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied             =PRICE_CLOSE; // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight              =1.0;         // Moving Average(12,0,...) Weight [0...1.0]
 
CExpertInd ExtExpert;
CSignalMAIndLow *filter0 = new CSignalMAIndLow;
CSignalMACDIndLow *filter1 = new CSignalMACDIndLow;
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//--- Initializing expert
if(!ExtExpert.Init(Symbol(),Period(),true,100))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);  
 
filter0.PeriodMA(Signal_MA_PeriodMA);
filter0.Shift(Signal_MA_Shift);
filter0.Method(Signal_MA_Method);
filter0.Applied(Signal_MA_Applied);
 
filter1.PeriodFast(Signal_MACD_PeriodFast);
filter1.PeriodSlow(Signal_MACD_PeriodSlow);
filter1.PeriodSignal(Signal_MACD_PeriodSignal);
filter1.Applied(Signal_MACD_Applied);
 
signal.AddFilter(filter0);
signal.AddFilter(filter1);
if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   //--- indicator buffers mapping
   SetIndexBuffer(0,InBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
   
ArraySetAsSeries(InBuffer,true);   
ArraySetAsSeries(ColorBuffer,true);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int values_to_copy;
int calculated=MathMin(filter0.BarsCalculatedInd(), filter1.BarsCalculatedInd());
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returns %d, error code %d",calculated,GetLastError());
      return(0);
     }
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      
      values_to_copy=(rates_total-prev_calculated)+1;
     }
 
 bars_calculated=calculated;
 
 ArraySetAsSeries(open,true);
 ArraySetAsSeries(close,true);
 ArraySetAsSeries(low,true);
 ArraySetAsSeries(high,true);
 
 double _low[];
 ArrayCopy(_low,low);
 double _high[];
 ArrayCopy(_high,high);
 
 ArraySetAsSeries(_low,true);
 ArraySetAsSeries(_high,true);
 
 if(values_to_copy>1)
{
 
ExtExpert.RefreshInd();
 
bool flagBuy=false;
bool flagSell=false;
double priceBuy=0;
double priceStopBuy=0;
double profitBuy=0;
double profitTotalBuy=0;
int countProfitBuyPlus=0;
int countProfitBuyMinus=0;
double priceSell=0;
double priceStopSell=0;
double profitSell=0;
double profitTotalSell=0;
int countProfitSellPlus=0;
int countProfitSellMinus=0;
double sp=0.0002;
  
for (int i=0; i<(values_to_copy-2); i++){
 
ColorBuffer[i]=0;
InBuffer[i]=open[i];
 
double result0=Signal_MA_Weight*(filter0.LongConditionInd(i, values_to_copy, close[i], open[i], low[i])-filter0.ShortConditionInd(i, values_to_copy, close[i], open[i], high[i]));
double result1=Signal_MACD_Weight*(filter1.LongConditionInd(i, values_to_copy, _low, _high)-filter1.ShortConditionInd(i, values_to_copy, _low, _high));
double result=(result0+result1)/2;
 
if(result>=Signal_ThresholdOpen)
     {
 ColorBuffer[i]=2; 
 if(flagSell==true){
flagSell=false;
priceStopSell=InBuffer[i];
profitSell=(priceStopSell-priceSell-sp)*10000;
if(profitSell>0){countProfitSellPlus++;}else{countProfitSellMinus++;}
profitTotalSell=profitTotalSell+profitSell;
 }
 if(flagBuy==false){
 flagBuy=true;
 priceBuy=InBuffer[i];
 }  
     } 
     
 if(-result>=Signal_ThresholdOpen){
 ColorBuffer[i]=1;
 if(flagBuy==true){
flagBuy=false;
priceStopBuy=InBuffer[i];
profitBuy=(priceStopBuy-priceBuy-sp)*10000;
if(profitBuy>0){countProfitBuyPlus++;}else{countProfitBuyMinus++;}
profitTotalBuy=profitTotalBuy+profitBuy;
 }
 if(flagSell==false){
priceSell=InBuffer[i];
flagSell=true; 
}
 } 
 
}
 
//Print(" ProfitBuy ", profitTotalBuy," countProfitBuyPlus ",countProfitBuyPlus," countProfitBuyMinus ",countProfitBuyMinus);
//Print(" ProfitSell ", profitTotalSell," countProfitSellPlus ",countProfitSellPlus," countProfitSellMinus ",countProfitSellMinus);
 
}
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
#include <Expert\Signal\SignalMA.mqh>
class CSignalMAInd : public CSignalMA
  {
  public:
  virtual int       BarsCalculatedInd();
  virtual int       LongConditionInd(int ind, int amount, double close, double open, double low);
  virtual int       ShortConditionInd(int ind, int amount, double close, double open, double high);                  
  };
  
//+------------------------------------------------------------------+
//| Refresh indicators.                                               |
//+------------------------------------------------------------------+  
int CSignalMAInd:: BarsCalculatedInd(){
m_ma.Refresh();
int bars = m_ma.BarsCalculated();
return bars;
}
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMAInd::LongConditionInd(int idx, int amount, double close, double open, double low)
  {
  int handle=m_ma.Handle();
  double         iMABuffer[]; 
   if(CopyBuffer(handle,0,0,amount,iMABuffer)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
      return(-1); 
     } 
   ArraySetAsSeries(iMABuffer,true); 
  
   int result=0;
   
   double DiffCloseMA = close - iMABuffer[idx];
   double DiffOpenMA = open - iMABuffer[idx];
   double DiffMA = iMABuffer[idx] - iMABuffer[idx+1];
   double DiffLowMA = low - iMABuffer[idx];
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA<0.0)
     {
      //--- the close price is below the indicator
      if(IS_PATTERN_USAGE(1) && DiffOpenMA>0.0 && DiffMA>0.0)
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
      if(DiffMA>0.0)
        {
         if(DiffOpenMA<0.0)
           {
            //--- if the model 2 is used
            if(IS_PATTERN_USAGE(2))
              {
               //--- the open price is below the indicator (i.e. there was an intersection)
               result=m_pattern_2;
               //--- suggest to enter the market at the "roll back"
               m_base_price=m_symbol.NormalizePrice(iMABuffer[idx]);
              }
           }
         else
           {
            //--- if the model 3 is used and the open price is above the indicator
            if(IS_PATTERN_USAGE(3) && DiffLowMA<0.0)
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
int CSignalMAInd::ShortConditionInd(int idx, int amount, double close, double open, double high)
  {
  int handle=m_ma.Handle();
  double         iMABuffer[]; 
   if(CopyBuffer(handle,0,0,amount,iMABuffer)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
            return(-1); 
     } 
   ArraySetAsSeries(iMABuffer,true);  
 
   int result=0;
   
   double DiffCloseMA = close - iMABuffer[idx];
   double DiffOpenMA = open - iMABuffer[idx];
   double DiffMA = iMABuffer[idx] - iMABuffer[idx+1];
   double DiffHighMA = high - iMABuffer[idx];
   
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA>0.0)
     {
      //--- the close price is above the indicator
      if(IS_PATTERN_USAGE(1) && DiffOpenMA<0.0 && DiffMA<0.0)
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
      if(DiffMA<0.0)
        {
         if(DiffOpenMA>0.0)
           {
            //--- if the model 2 is used
            if(IS_PATTERN_USAGE(2))
              {
               //--- the open price is above the indicator (i.e. there was an intersection)
               result=m_pattern_2;
               //--- suggest to enter the market at the "roll back"
               m_base_price=m_symbol.NormalizePrice(iMABuffer[idx]);
              }
           }
         else
           {
            //--- if the model 3 is used and the open price is below the indicator
            if(IS_PATTERN_USAGE(3) && DiffHighMA>0.0)
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
#include <Expert\Signal\SignalMACD.mqh>
 
class CSignalMACDInd : public CSignalMACD
  {
  public: 
  virtual int       BarsCalculatedInd();                  
  virtual int       LongConditionInd(int ind, int amount, double &low[], double &high[]);
  virtual int       ShortConditionInd(int ind, int amount, double &low[], double &high[]);
  protected:
  int               StateMain(int ind,double &Main[]);
  bool              ExtState(int ind, double &Main[], double &low[], double &high[]);
  };
 //+------------------------------------------------------------------+
//| Refresh indicators.                                               |
//+------------------------------------------------------------------+  
int CSignalMACDInd:: BarsCalculatedInd(){
m_MACD.Refresh();
int bars = m_MACD.BarsCalculated();
return bars;
}
 
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMACDInd::LongConditionInd(int idx, int amount, double &low[], double &high[])
  {
  
int handle=m_MACD.Handle();
double         MACDBuffer[]; 
double         SignalBuffer[];  
   if(CopyBuffer(handle,0,0,amount,MACDBuffer)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
            return(-1); 
     }
     if(CopyBuffer(handle,1,0,amount,SignalBuffer)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
            return(-1); 
     }  
   ArraySetAsSeries(MACDBuffer,true);
   ArraySetAsSeries(SignalBuffer,true); 
   int result=0;
   
   double DiffMain = MACDBuffer[idx]-MACDBuffer[idx+1];
   double DiffMain_1 = MACDBuffer[idx+1]-MACDBuffer[idx+2];
   double State = MACDBuffer[idx]- SignalBuffer[idx];
   double State_1 = MACDBuffer[idx+1]- SignalBuffer[idx+1];
   
//--- check direction of the main line
   if(DiffMain>0.0)
     {
      //--- the main line is directed upwards, and it confirms the possibility of price growth
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain_1<0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State>0.0 && State_1<0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && MACDBuffer[idx]>0.0 && MACDBuffer[idx+1]<0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned upwards below the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && MACDBuffer[idx]<0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx, MACDBuffer, low, high);
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
int CSignalMACDInd::ShortConditionInd(int idx, int amount, double &low[], double &high[])
  {
   int handle=m_MACD.Handle();
double         MACDBuffer[]; 
double         SignalBuffer[];  
   if(CopyBuffer(handle,0,0,amount,MACDBuffer)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
      return(-1); 
     }
     if(CopyBuffer(handle,1,0,amount,SignalBuffer)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
      return(-1); 
     }  
   ArraySetAsSeries(MACDBuffer,true);
   ArraySetAsSeries(SignalBuffer,true); 
   int result=0;
   
   double DiffMain = MACDBuffer[idx]-MACDBuffer[idx+1];
   double DiffMain_1 = MACDBuffer[idx+1]-MACDBuffer[idx+2];
   double State = MACDBuffer[idx]- SignalBuffer[idx];
   double State_1 = MACDBuffer[idx+1]- SignalBuffer[idx+1];
   
//--- check direction of the main line
   if(DiffMain<0.0)
     {
      //--- main line is directed downwards, confirming a possibility of falling of price
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain_1>0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State<0.0 && State_1>0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && MACDBuffer[idx]<0.0 && MACDBuffer[idx+1]>0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned downwards above the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && MACDBuffer[idx]>0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx, MACDBuffer, low, high);
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
//+------------------------------------------------------------------+
//| Check of the oscillator state.                                   |
//+------------------------------------------------------------------+
int CSignalMACDInd::StateMain(int ind, double &Main[])
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(Main[i+1]==EMPTY_VALUE)
         break;
      var=(Main[i]-Main[i+1]);
      if(res>0)
        {
         if(var<0)
            break;
         res++;
         continue;
        }
      if(res<0)
        {
         if(var>0)
            break;
         res--;
         continue;
        }
      if(var>0)
         res++;
      if(var<0)
         res--;
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Extended check of the oscillator state consists                  |
//| in forming a bit-map according to certain rules,                 |
//| which shows ratios of extremums of the oscillator and price.     |
//+------------------------------------------------------------------+
bool CSignalMACDInd::ExtState(int ind, double &Main[], double &low[], double &high[])
  {
//--- operation of this method results in a bit-map of extremums
//--- practically, the bit-map of extremums is an "array" of 4-bit fields
//--- each "element of the array" definitely describes the ratio
//--- of current extremums of the oscillator and the price with previous ones
//--- purpose of bits of an element of the analyzed bit-map
//--- bit 3 - not used (always 0)
//--- bit 2 - is equal to 1 if the current extremum of the oscillator is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- bit 1 - not used (always 0)
//--- bit 0 - is equal to 1 if the current extremum of price is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- in addition to them, the following is formed:
//--- array of values of extremums of the oscillator,
//--- array of values of price extremums and
//--- array of "distances" between extremums of the oscillator (in bars)
//--- it should be noted that when using the results of the extended check of state,
//--- you should consider, which extremum of the oscillator (peak or valley)
//--- is the "reference point" (i.e. was detected first during the analysis)
//--- if a peak is detected first then even elements of all arrays
//--- will contain information about peaks, and odd elements will contain information about valleys
//--- if a valley is detected first, then respectively in reverse
   int    pos=ind,off,index;
   uint   map;                 // intermediate bit-map for one extremum
//---
   m_extr_map=0;
   for(int i=0;i<10;i++)
     {
      off=StateMain(pos, Main);
      if(off>0)
        {
         //--- minimum of the oscillator is detected
         pos+=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=Main[pos];
         if(i>1)
           {
           index = ArrayMinimum (low,pos-2,5);
            m_extr_pr[i]=low[index];
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]<m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]<m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
         index = ArrayMinimum (low,pos-1,4);
            m_extr_pr[i]=low[index];
        }
      else
        {
         //--- maximum of the oscillator is detected
         pos-=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=Main[pos];
         if(i>1)
           {
           index = ArrayMaximum (high,pos-2,5);
            m_extr_pr[i]=high[index];
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]>m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]>m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
         index = ArrayMaximum (high,pos-1,4);
            m_extr_pr[i]=high[index];
        }
     }
//---
   return(true);
  }