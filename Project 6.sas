/* ============================================================
   IDC4252C — M06 Project
   Name: Johnny Sewell
   Assignment: Univariate Model
   ============================================================ */

/* ------------------------------------------------------------
   SECTION 1: MODEL DATASET PREPARATION — HOLD-OUT SAMPLE
   ------------------------------------------------------------ */

TITLE "Section 1: Model Dataset — Hold-Out Sample";
FOOTNOTE "Training: Jan 2012 – Sep 2017 | Forecast: Oct 2017 – Mar 2018";

Data Model;
    Set Inflation;
    If Month gt "30Sep2017"d then do;
        CPI=.;
    End;
Run;

TITLE "Section 1 (Verification): Last 10 Rows of Model Dataset";
FOOTNOTE "CPI should show missing (.) for all rows after 30SEP2017";

PROC PRINT Data=Model (FIRSTOBS=60 OBS=70);
    Var Month CPI;
Run;

/* ------------------------------------------------------------
   SECTION 2: UCM MODEL — SPECIFICATION AND ESTIMATION
   Components: Irregular | Level | Slope (Fixed) | Seasonal (Trig)
   ------------------------------------------------------------ */

TITLE "Section 2: Unobserved Components Model (UCM)";
FOOTNOTE "Components: Irregular, Level, Slope (fixed), Seasonal (Trig, Length=12)";

ODS GRAPHICS ON;

Proc UCM Data=Model;
    Id Month Interval=Month;
    Model CPI;

    /* Component 1: Irregular — captures random noise */
    Irregular;

    /* Component 2 & 3: Trend — Level + fixed Slope */
    Level;
    Slope Var = 0 Noest;

    /* Component 4: Seasonal — trigonometric with 12-month cycle */
    Season Length = 12 Type = Trig;

    /* Estimation: evaluate last 6 periods with diagnostic plots */
    Estimate Back = 6 Plot = (loess panel cusum wn);

    /* Forecast: 24 months ahead with decomposition */
    Forecast Back = 0 Lead = 24 Print = Forecasts Plot=(forecasts decomp);

Run;

/* ------------------------------------------------------------
   SECTION 3: FORECAST COMPARISON — UCM vs REGRESSION MODELS
   Validation Period: October 2017 – March 2018
   ------------------------------------------------------------ */

TITLE "Section 3: Forecast Comparison — UCM vs Regression Models";
FOOTNOTE "UCM forecasts are directionally closer to observed CPI values";

Data Forecast_Comparison;
    Input Month $ Forward_Selection Backward_Selection MaxR UCM Observed;
    Datalines;
Oct-2017 106.4077 106.4077 106.3580 106.46 106.4
Nov-2017 106.4077 106.4077 106.3592 106.48 106.5
Dec-2017 106.3413 106.3413 106.2917 106.48 106.6
Jan-2018 106.2715 106.2715 106.2025 106.46 106.6
Feb-2018 106.2051 106.2051 106.1272 106.46 106.6
Mar-2018 106.2051 106.2051 106.1198 106.4767 106.7
;
Run;

PROC PRINT Data=Forecast_Comparison NOOBS;
    Var Month Forward_Selection Backward_Selection MaxR UCM Observed;
    Label
        Month              = "Forecast Month"
        Forward_Selection  = "Forward Selection"
        Backward_Selection = "Backward Selection"
        MaxR               = "Maximize R"
        UCM                = "UCM Forecast"
        Observed           = "Observed CPI";
Run;

/* ============================================================
   END OF M06 PROJECT
   ============================================================ */

TITLE;
FOOTNOTE;