from __future__ import division
import numpy as np

def create_kpath(Nk):
    # Gamma -> K -> M -> Gamma

    # Gamma = 0   , 0
    # K     = 2/3 , 1/3
    # M     = 1/2 , 1/2

    G2K = ( (2./3)**2 + (1./3)**2 ) **.5
    K2M = ( (2./3 - 1./2)**2 + (1./3-1./2)**2 ) **.5
    M2G = ( (1./2)**2 + (1./2)**2 ) **.5

    Kdist = G2K + K2M + M2G

    NG2K = int(Nk / Kdist * G2K)
    NK2M = int(Nk / Kdist * K2M)
    NM2G = int(Nk / Kdist * M2G)

    def from_to(N, f, t):
        full = np.empty([N, 3])
        ls = np.linspace(0, 1, N, endpoint=False)
        for i in range(3):
            full[:, i] = f[i] + (t[i]-f[i]) * ls
        return full

    kG2K = from_to(NG2K, [0., 0., 0.], [2./3, 1./3, 0])
    kK2M = from_to(NK2M, [2./3, 1./3, 0], [1./2, 1./2, 0.])
    kM2G = from_to(NM2G, [1./2, 1./2, 0.], [0., 0., 0.])

    xtick = [0, NG2K-1, NG2K + NK2M-1, NG2K + NK2M + NM2G-1]
    label = ['G','K',         'M',                'G']

    return [xtick, label], np.vstack((kG2K, kK2M, kM2G))

def bandstructure(Nk, H):

    ticks, k = create_kpath(Nk)
    
    eigs = np.empty([len(k),2],np.float64)
    for ik, k in enumerate(k):
        eigs[ik,:] = H.eigh(k=k)

    import matplotlib.pyplot as plt

    plt.plot(eigs[:,0])
    plt.plot(eigs[:,1])
    plt.gca().xaxis.set_ticks(ticks[0])
    plt.gca().set_xticklabels(ticks[1])
    ymin, ymax = plt.gca().get_ylim()
    # Also plot x-major lines at the ticks
    for tick in ticks[0]:
        plt.plot([tick,tick], [ymin,ymax], 'k')
    plt.show()
        

    
if __name__ == "__main__":
    print('This file is intended for use in Hancock_*.py files')
    print('It is not intended to be runned separately.')
