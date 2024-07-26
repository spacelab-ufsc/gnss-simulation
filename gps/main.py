import numpy as np
import matplotlib.pyplot as plt
from functions import *

Fs=50

###Signal Characterstics 

# rawdata = np.random.randint(0, 2, size=5000)
# rawdata = [1, 0, 1, 1, 0, 1]
rawdata = [1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1 ,0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1 ,1 ,1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1]

fc = 1575.42e6       # Carrier frequency
sv_id = 1           # Satellite Vehicle ID
n = 1                # BPSK(1) fc = n*1.023e6; %code rate BPSK(n) spreading code rate n*1.023 MHz
codeLength = 31      # round(1023/n)

#Signal modulation                              

data = modulation(rawdata, codeLength, sv_id, fc, n)

#Frequency Domain

dataFFT=np.fft.fft(rawdata)
dataFFT=np.fft.fftshift(dataFFT)

#FFT of modulated signal 
modulated=np.fft.fft(data[0:round(len(data))])
modulated=np.fft.fftshift(modulated)

w0 = np.arange(0, 2*np.pi, 2*np.pi/len(data))

fs=Fs

f=(w0*fs)/(np.pi*2)
f1 = np.linspace(0, f[-1], len(modulated))

dataFFT_abs = np.abs(dataFFT)
dataFFT=np.concatenate([dataFFT_abs, np.zeros(len(modulated) - len(dataFFT_abs))])

#Channel multipath configuration
#AWGN -20 -15 -10 -5 0 1 20
SNR = 5

channel_signal=awgn(data, SNR)

#Signal demodulation                            
nbit = len(rawdata)

[demodulated,Id,Qd] = demodulation(channel_signal, codeLength, sv_id, fc, fs, nbit)

print(demodulated)

###  Multiple SNR Simulation
#channel multipath configuration
#AWGN -20 -15 -10 -5 0 1 20
SNR =np.array([-20, -19.5, -19, -18.5, -18 ,-17.5, -17, -16.5, -16, -15.5, -15, -14.5, -14, -13.5, -13, -12.5, -12, 0, 5, 10, 15])

#MATLAB CURVA TEORICA BERTOOL;
# SNR = 20;

BER=[]

for i in range(len(SNR)):
    channel_signal=awgn(data, SNR[i])

    #Signal demodulation                            
    nbit = len(rawdata)
    [demodulated,Id,Qd] = demodulation(channel_signal, codeLength, sv_id, fc, fs, nbit)
    
    #BER Analysis                                  
    b_error= np.sum(np.logical_xor(demodulated, rawdata))
    BER.append(b_error/len(rawdata))

#Figure
plt.figure()
plt.semilogy(SNR, BER)
plt.legend(['Canal AWGN'])
plt.title('SNR x BER com modulação BPSK')
plt.xlabel('SNR (dB)')
plt.ylabel('BER')
plt.grid(True, which='both')
plt.show()