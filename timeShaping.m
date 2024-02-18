% function yy = timeShaping(xx, ss)
% The target of this function is to return a vector of equal size as the
% input but with a white content except at the middle portion where the
% original signal content is used.
% This input vector in time domain is passed through a low pass filter 
% then measured the signal level.  This value is used to scale the 
% generated white noise vector. It is assumed that the signal content is 
% not at the low frequency spectrum.  The input and the generated noise
% are merged after applying windowing with a 50% overlap.
%
% Input:  xx -- a vector of samples in time domain, this is expected to be a
%              narrowband noise with a higher gain at around fs/4.
%         ss -- a scaler value acting as a gain applied to the estimated
%              background level.
% Output: yy -- a vector of samples in time domain, it is expected to be
%               widenband noise throughout except accept around the middle 
%               where it is replaced with xx.
%
% Copyright © 2024 The MathWorks, Inc.  
% Francis Tiong (ftiong@mathworks.com)
%
function yy = timeShaping(xx, ss)

nn = length(xx);

% design a simple low pass filter
Fs = 48e3; 
filtertype = 'IIR';
Fpass = 8e3;
Fstop = 12e3;
Rp = 0.1;
Astop = 80;
LPF = dsp.LowpassFilter(SampleRate=Fs,...
                             FilterType=filtertype,...
                             PassbandFrequency=Fpass,...
                             StopbandFrequency=Fstop,...
                             PassbandRipple=Rp,...
                             StopbandAttenuation=Astop);

y = LPF(xx);

% measure the signal energy for this low pass segment and applied it to
% the generated random noise
rr = rms(y);
gg = randn(nn,1)*rr;
yy = gg*ss;    % apply proper scaling to this background noise

% overwrite the newly generated noise with the input content in the middle
frameSize = 512;
numFrame = nn/512;
hh = hanning(frameSize*2);

% windowing and 50% overlap to merge the two signals, only 3 frames have
% the original input content.
ii=numFrame/2-1;
   yy(ii*frameSize+1:ii*frameSize+frameSize) = gg(ii*frameSize+1:ii*frameSize+frameSize).*hh(frameSize+1:end) + xx(ii*frameSize+1:ii*frameSize+frameSize).*hh(1:frameSize);  
ii=numFrame/2;
   yy(ii*frameSize+1:ii*frameSize+frameSize) =  xx(ii*frameSize+1:ii*frameSize+frameSize) ;
ii=numFrame/2+1;
   yy(ii*frameSize+1:ii*frameSize+frameSize) = gg(ii*frameSize+1:ii*frameSize+frameSize).*hh(1:frameSize) + xx(ii*frameSize+1:ii*frameSize+frameSize).*hh(1+frameSize:end);

