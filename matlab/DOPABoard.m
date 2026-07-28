% DOPA Board
% Use CTRL+ENTER to first run the 'Setup' section. Then CTRL+ENTER any of
% the cases. Case 6, specifically, cycles through everything

%% Setup:
% Connect cable to Arduino
% - Make sure Teensy 3.6, Port 3 is selected (under Tools)
% Upload sketch
% Find and close existing serial links
clear
clc
q = instrfind;
fclose(q);
% Open serial link to Arduino
s = Init_serialLink('COM3');

%% Turn off all quads
fwrite(s,uint8(0));
%% Turn on all quads at min TIA gain
fwrite(s,uint8(1)); % SEL 00
%% Select channels (min gain)
fwrite(s,uint8(2)); % SEL 00
%%
fwrite(s,uint8(3)); % SEL 01
%%
fwrite(s,uint8(4)); % SEL 10
%%
fwrite(s,uint8(5)); % SEL 11

%% LO tap current (uA)
% 3.2V, 1.185A for board
ch_group = 1:4:125; % recording
% 53 and 54 had oscillations, 77-78 might have
% ch_group = [1 5     8     13    18    21    25    29    33    37    41    45    49    53    57    61    65    69    73    77    81    85    89    93    97    101   105   109   113   117   121   125      
mean   = [3.444 3.402 3.388 3.420 3.417 3.450 3.470 3.462 3.508 3.528 3.400 3.363 3.433 4.373 3.558 3.487 3.465 4.137 3.445 3.397 3.389 3.384 3.442 3.450 4.259 4.298 4.784 4.810 4.790 4.835 4.370 4.513];
stddev = [0.020 0.011 0.013 0.010 0.012 0.014 0.024 0.010 0.010 0.012 0.014 0.017 0.033 0.038 0.022 0.013 0.011 0.027 0.017 0.014 0.013 0.009 0.018 0.008 0.009 0.025 0.025 0.020 0.019 0.044 0.026 0.008];
nsamp  = [260   130   120   120   150   115   120   115   165   125   120   230   165   170   240   180   220   145   200   285   430   215   377   130   215   215   130   150   105   135   150   140  ];

%% Select channels (min gain)
fwrite(s,uint8(2)); % SEL 00
pause(0.5)
fwrite(s,uint8(3)); % SEL 01
pause(0.5)
fwrite(s,uint8(4)); % SEL 10
pause(0.5)
fwrite(s,uint8(5)); % SEL 11
display('Done');

%% Test sequences
fwrite(s,uint8(6)); % Turn on one quad at a time (both PWR and OMUX)
% fwrite(s,uint8(7)); % Turn on every possible combination of quads
print_pin_settings(s);

%% Cycle through gains
% Keep channel selection the same
fwrite(s,uint8(8)); % Turn on one quad at a time
print_pin_settings(s);

%% Turn on only one quad 

%% Channel select
fwrite(s,uint8(10)); % CH 01
%%
fwrite(s,uint8(11)); % CH 10

%% Adj select
fwrite(s,uint8(12)); % ADJ 01
%%
fwrite(s,uint8(13)); % ADJ 10

%% Notes:
% The current consumption is normally 0.86 or 0.78 A, depending on the gain
% setting, but half the channels don't match it. The off current is
% normally 0.44 A, but it went down to 0.37 A after running case 6->0.

% Desolder SEL from cables? there's floating traces nearby
% Remove Arduino?
% Bypass caps?

% Bypass caps were causing the oscillations
% Currently, there's ~6 mV, 60 Hz leakage from the supplies

% SEL0 is always high (2.36V at CH00, 2.44 at CH01/10/11)
% SEL0 is shorted to the analog VDD pin opposite the TIA in each quad

% OMUX consumes most of the power because of the 50 ohm output
% Just toggling the PWR pins has much smaller of a change

% 81-116 have lower output voltages than the others
% Min TIA gain has half the DC output voltage as max TIA gain

% Oscillations at max TIA gain, none on min TIA gain
% Add bypass caps back to suppress oscillations

% Positive pins are giving a lower DC offset than the negative pins

% Positive pins are in the center of the SMA board. Outside pins are
% negative.

% Column G is just positive pins

% Add cap of >0.01 uF to HI, CM to avoid oscillations as per the datasheet

% Input to TIA is 0.8V when on, 0.7V when off. Set PD rails to 0V and 1.6V

% 49-52, 53-56, 73-76, 77-80, 109-112, 89-92 no sig (some more could be bad
% because we didn't multiplex)

% 85, 115, 119 is very low

%% Functions

% print current pin settings
function print_pin_settings(varargin)
s = varargin{1};
while true
    if s.BytesAvailable > 0
        data = fgetl(s); % Reads until newline
        clc;
        disp(data);
    end
    pause(0.1); % Reduce CPU usage
end
end