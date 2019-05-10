//+------------------------------------------------------------------+
//|                                                    ExpMAMACD.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
 
#include <Fitness\MAMACDFitness.mqh>
#include <Fitness\UGAlib.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title            ="MAMACDExpert"; // Document name
ulong                    Expert_MagicNumber      =4322;           // 
bool                     Expert_EveryTick        =false;          // 
//--- inputs for main signal
input int                Signal_ThresholdOpen    =20;             // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose   =20;             // Signal threshold value to close [0...100]
input double             Signal_PriceLevel       =0.0;            // Price level to execute a deal
input double             Signal_StopLevel        =50.0;           // Stop Loss level (in points)
input double             Signal_TakeLevel        =50.0;           // Take Profit level (in points)
input int                Signal_Expiration       =4;              // Expiration of pending orders (in bars)
input int                Signal_MA_PeriodMA      =12;             // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift         =0;              // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method        =MODE_SMA;       // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied       =PRICE_CLOSE;    // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight        =1.0;            // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast  =12;             // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow  =24;             // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal=9;              // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied     =PRICE_CLOSE;    // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight      =1.0;            // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent    =10.0;           // Percent
input double             Money_FixLot_Lots       =1.0;            // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
CSignalMA *filter0=new CSignalMA;
CSignalMACD *filter1=new CSignalMACD;
 
double ReplicationPortion_E  = 100.0; 
double NMutationPortion_E    = 10.0;  
double ArtificialMutation_E  = 10.0;  
double GenoMergingPortion_E  = 20.0;  
double CrossingOverPortion_E = 20.0;  
//---
double ReplicationOffset_E   = 0.5;   
double NMutationProbability_E= 5.0;   
 
double balance;
 
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
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
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalMA
 
if(filter0==NULL)
  {
   //--- failed
   printf(__FUNCTION__+": error creating filter0");
   ExtExpert.Deinit();
   return(INIT_FAILED);
  }
signal.AddFilter(filter0);
//--- Set filter parameters
filter0.PeriodMA(Signal_MA_PeriodMA);
filter0.Shift(Signal_MA_Shift);
filter0.Method(Signal_MA_Method);
filter0.Applied(Signal_MA_Applied);
filter0.Weight(Signal_MA_Weight);
//--- Creating filter CSignalMACD
 
if(filter1==NULL)
  {
   //--- failed
   printf(__FUNCTION__+": error creating filter1");
   ExtExpert.Deinit();
   return(INIT_FAILED);
  }
signal.AddFilter(filter1);
//--- Set filter parameters
filter1.PeriodFast(Signal_MACD_PeriodFast);
filter1.PeriodSlow(Signal_MACD_PeriodSlow);
filter1.PeriodSignal(Signal_MACD_PeriodSignal);
filter1.Applied(Signal_MACD_Applied);
filter1.Weight(Signal_MACD_Weight);
//--- Creation of trailing object
  CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
//--- Creation of money object
CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
money.Percent(Money_FixLot_Percent);
money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
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
 
ChromosomeCount     = 100;   
GeneCount           = 2;     
Epoch               = 50;    
//---
RangeMinimum        = 0.0;  
RangeMaximum        = 1.0;  
Precision           = 0.1;
OptimizeMethod      = 2;  
ArrayResize(Chromosome,GeneCount+1);
ArrayInitialize(Chromosome,0);  
 
balance=AccountInfoDouble(ACCOUNT_BALANCE);
  
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
  if(AccountInfoDouble(ACCOUNT_BALANCE)>balance) balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double bd = ((balance-AccountInfoDouble(ACCOUNT_BALANCE))/balance)*100;
   
   if(bd>10){
 
   UGA
  (
  ReplicationPortion_E, 
  NMutationPortion_E,   
  ArtificialMutation_E, 
  GenoMergingPortion_E, 
  CrossingOverPortion_E,
  //---
  ReplicationOffset_E,  
  NMutationProbability_E
  );
 
double _MACD_Weight=0.0;
double _MA_Weight=0.0;
int    cnt=1;
 
    while (cnt<=GeneCount)
    {
      _MACD_Weight=Chromosome[cnt];
      cnt++;
      _MA_Weight=Chromosome[cnt];
      cnt++;
    }
filter0.Weight(_MA_Weight);
filter1.Weight(_MACD_Weight);   
 
balance=AccountInfoDouble(ACCOUNT_BALANCE);
}
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+