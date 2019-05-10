//+------------------------------------------------------------------+
//|                                                   IndSignals.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window
	
#include <Expert\ExpertInd.mqh>
#include <Expert\Signal\SignalMACDInd.mqh>
#include <Expert\Signal\SignalMAInd.mqh>
 
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
CSignalMAInd *filter0 = new CSignalMAInd;
CSignalMACDInd *filter1 = new CSignalMACDInd;
 
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
    
for (int i=0; i<values_to_copy; i++){
 
ColorBuffer[i]=0;
InBuffer[i]=open[i];
 
double result0=Signal_MA_Weight*(filter0.LongConditionInd(i)-filter0.ShortConditionInd(i));
double result1=Signal_MACD_Weight*(filter1.LongConditionInd(i)-filter1.ShortConditionInd(i));
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