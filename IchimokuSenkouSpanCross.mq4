//+------------------------------------------------------------------+
//|                                              IchimokuSpanCross  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- buffers
double CrossUp[];
double CrossDown[];

//---- Ichimoku settings
input int Tenkan = 9;
input int Kijun = 26;
input int SenkouSpanB_Period = 52;
input double offset_point = 10.0;

int g_offset;

//+------------------------------------------------------------------+
int OnInit()
   {
    SetIndexBuffer(0, CrossUp);
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexArrow(0, 233);
    SetIndexLabel(0, "SpanA Cross Above SpanB");

    SetIndexBuffer(1, CrossDown);
    SetIndexStyle(1, DRAW_ARROW);
    SetIndexArrow(1, 234);
    SetIndexLabel(1, "SpanA Cross Below SpanB");

    g_offset = offset_point * Point();

    return(INIT_SUCCEEDED);
   }
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
    for(int i = 0; i < rates_total - 1; i++)
       {
        int shift = i + Kijun;

        double senkouA     = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANA, i);
        double senkouB     = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANB, i);
        double prevA       = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANA, i + 1);
        double prevB       = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANB, i + 1);

        if(prevA < prevB && senkouA > senkouB)
            CrossUp[shift] = low[shift] - g_offset;
        else
            if(prevA > prevB && senkouA < senkouB)
                CrossDown[shift] = high[shift] + g_offset;
       }

    return(rates_total);
   }
//+------------------------------------------------------------------+
