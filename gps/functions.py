import numpy as np
Fs=50

###Mapper
def mapper(data):
    n=len(data)
    mappedI=[]
    mappedQ=[]
    for s in range(n):
        if data[s]==0:
            mappedI+=[1]
            mappedQ+=[0]
        elif data[s]==1:
            mappedI+=[-1]
            mappedQ+=[0]
    return mappedI,mappedQ

###Upsampler
def upsampler(inn,k):
    n=len(inn)
    out=np.zeros(n*k)
    for j in range(n):
        out[k*j]=inn[j]
    return out

###LPF
def lpf(inn,h):
    out=np.convolve(h,inn)
    out=out[:len(inn)]
    return out

###satv
def satv(sv):
    sv_values=[[2, 6],[3, 7],[4, 8],[5, 9],[1, 9],[2, 10],[1, 8],[2, 9],[3, 10],[2, 3],[3, 4],[5, 6],[6, 7],[7, 8],[8, 9],[9, 10],[1, 4],[2, 5],[3, 6],[4, 7],[5, 8],[6, 9],[1, 3],[4, 6],[5, 7],[6, 8],[7, 9],[8, 10],[1, 6],[2, 7],[3, 8],[4, 9]]
    return sv_values[sv-1]

###Gold_code
def gold_code(codelength,shift_G1_reg,shift_G2_reg,SV):
    len=codelength
    g1=np.zeros(len)
    g2=np.zeros(len)
    l1_CA_code=np.zeros(len)

    #satellite
    sv = satv(SV)

    #Creating CA code
    for k1 in range(len):
        g1[k1]=shift_G1_reg[9]
        g2[k1]=(shift_G2_reg[sv[0]] + shift_G2_reg[sv[1]])%2
        l1_CA_code[k1]=(g1[k1]+g2[k1])%2
    
        feedback_G1 = (shift_G1_reg[2] + shift_G1_reg[9])%2
        feedback_G2 = (shift_G2_reg[1] + shift_G2_reg[2] + shift_G2_reg[5] + shift_G2_reg[7] + shift_G2_reg[8] + shift_G2_reg[9])%2

        #shifting vector
        for k2 in range(9,1,-1):
            shift_G1_reg[k2] = shift_G1_reg[k2-1]
            shift_G2_reg[k2] = shift_G2_reg[k2-1]
    
        shift_G1_reg[0] = feedback_G1
        shift_G2_reg[0] = feedback_G2
    
    #Tranform binary to bipolar data
    l1_CA_code = (l1_CA_code - 0.5)*2

    return l1_CA_code

###ROOT RAISED COSSINE FILTER
def RRC(NT, ks, RollOff, ro, delta):
    n=np.arange(NT)
    num=(16*RollOff/(np.pi*ks))*((np.cos((((n+delta)-(NT-1)/2)/ks)*ro*np.pi*(1+RollOff)) + ((np.pi*(1-RollOff))/(4*RollOff))*np.sinc(((n+delta-(NT-1)/2)/ks)*ro*(1-RollOff))) /(1-((((n+delta-(NT-1)/2)/ks)*4*RollOff)*ro)**2))
    return num

###BPSKmodulation
def modulation(rawdata,codeLength,sv_id,fc,n):
    f0=1023e6
    fChip=n*f0                  
    fs=50

    #rawdata to IQ symbols
    I,Q=mapper(rawdata)

    #symbols upsampler (Upsample data to multiply by the PRN code)
    I = upsampler(I, codeLength)
    fs = fs*codeLength

    #retangular window filter (Convert zero samples amplitude to a DC component)
    h=np.ones(codeLength)
    data = lpf(I,h)

    #generate PRN code (PRN code is done by a m-algorithm with 31 samples, that can be encreased to 1023, with a vector of 10 components instead of 31)
    shift_G1_reg = np.ones(10)
    shift_G2_reg = np.ones(10)
    SV = sv_id
    gc = gold_code(codeLength,shift_G1_reg,shift_G2_reg,SV)

    #generate PN spreading codes multiplying each 31 samples by the PRN code
    IQchip = np.zeros(len(data))
    for k in range(0,len(data),codeLength):
        """IQchip[k:k+codeLength]=data[k:k+codeLength]*gc"""
        if k + codeLength <= len(data):
            IQchip[k:k+codeLength] = data[k:k+codeLength] * gc
        else:
            IQchip[k:] = data[k:] * gc[:len(data[k:])]

    
    #1/sqrt(2)
    IQChip=IQchip/np.sqrt(2)

    #Chips upsampler (upsample to conv. with RRC filter)
    K=16
    IQChip=upsampler(IQChip, K)
    fs=fs*K

    #Root Raised Cosine Filter 
    RollOff=0.5
    ro=1
    delta=0
    ks=16
    NT=6*ks
    h=RRC(NT, ks, RollOff, ro, delta)

    ChipFilt=lpf(IQChip,h)

    #Local carrier: Heterodyned signal    (Each chip is represented by 2 cycles with 4 bits >> fc/fs=.5)
    b = round(len(ChipFilt)/2)
    t=np.arange(-b,b)
    Fs=fs
    fc = fs/4
    fs = fs*fc
    localCarrier = np.cos(2*np.pi*t*round(fc/fs))
    BPSignal = (ChipFilt)*localCarrier

    return BPSignal

###BPSKdemodulation
def demodulation(data,codeLength,sv_id,fc,fs,nbit):
    fs=Fs
    fc = fs/4
    n=np.arange(len(data))

    #Local carrier
    localCarrier = np.cos(2*np.pi*n*round(fc/fs))
    
    return




"""print(gold_code(5,[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],[13, 14, 15, 16, 17, 18 ,19 ,20, 21, 22, 23, 24],3))"""
"""print(RRC(96,16,0.5,1,0))"""
"""print(len(modulation([1, 0, 1, 1, 0, 1],31,1,1575.42e6,1)))"""
"""print(mapper([1, 0, 1, 1, 0, 1]))"""
"""print(lpf([1,2,3,4],[5,6]))"""
"""a=modulation([1, 0, 1, 1, 0, 1],31,1,1575.42e6,1)
print(a[0:14])"""