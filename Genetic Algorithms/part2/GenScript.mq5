//+------------------------------------------------------------------+
//|                                                    GenScript.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#include <Fitness\MAMACDFitness.mqh>
#include <Fitness\UGAlib.mqh>
 
double ReplicationPortion_E  = 100.0; 
double NMutationPortion_E    = 10.0;  
double ArtificialMutation_E  = 10.0;  
double GenoMergingPortion_E  = 20.0;  
double CrossingOverPortion_E = 20.0;  
//---
double ReplicationOffset_E   = 0.5;   
double NMutationProbability_E= 5.0;   
 
//--- inputs for main signal
input int                Signal_ThresholdOpen    =20;           // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose   =20;           // Signal threshold value to close [0...100]
input double             Signal_PriceLevel       =0.0;          // Price level to execute a deal
input double             Signal_StopLevel        =50.0;         // Stop Loss level (in points)
input double             Signal_TakeLevel        =50.0;         // Take Profit level (in points)
input int                Signal_Expiration       =4;            // Expiration of pending orders (in bars)
input int                Signal_MA_PeriodMA      =12;           // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift         =0;            // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method        =MODE_SMA;     // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied       =PRICE_CLOSE;  // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight        =1.0;          // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast  =12;           // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow  =24;           // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal=9;            // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied     =PRICE_CLOSE;  // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight      =1.0;          // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]
 
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
ChromosomeCount     = 10;    
GeneCount           = 2;     
Epoch               = 50;    
//---
RangeMinimum        = 0.0;  
RangeMaximum        = 1.0;  
Precision           = 0.1;
OptimizeMethod      = 2;  
ArrayResize(Chromosome,GeneCount+1);
ArrayInitialize(Chromosome,0);   
 
   int time_start=(int)GetTickCount(),time_end=0;
  //---------------------------------------------------------------------
 
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
  //----------------------------------
  time_end=(int)GetTickCount();
  //----------------------------------
  Print(time_end-time_start);
  //----------------------------------
  
  }
//+------------------------------------------------------------------+