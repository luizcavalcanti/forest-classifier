# include "math.h"
# include "mex.h"

# define BinN 11 /* bin number */

void mexFunction(    
    int nargout,
    mxArray *out[],
    int nargin,
    const mxArray *in[]
)
{
    int N1, N2, bn, ws, sz, bb = BinN;
    int i, j, b, k, mdid;
    int ndim, dims[3];
    int wtl[2], wbr[2];
    float U, md, tmp, Imax, Imin, tmpm[BinN], binc[BinN];    
    float *Ig, *sh_mx, *HImap, *IgRg;
 
  
    /* check argument */
    if (nargin < 6) {
        mexErrMsgTxt("Six input arguments required");
    }
    if (nargout> 1) {
        mexErrMsgTxt("Too many output arguments.");
    }

    N1 = mxGetScalar(in[0]);
    N2 = mxGetScalar(in[1]);
    bn = mxGetScalar(in[2]);
    ws = mxGetScalar(in[3]);
    Ig = mxGetData(in[4]);
    IgRg = mxGetData(in[5]);
   
    ndim = 3;
    dims[0]=bn*bb;
    dims[1] = N1;
    dims[2]=  N2;

    out[0] = mxCreateNumericArray(ndim, dims, mxSINGLE_CLASS, mxREAL);

    if (out[0]==NULL) {
	    mexErrMsgTxt("Not enough memory for the output matrix 1");
	}
    sh_mx = mxGetData(out[0]);
     
    /* compute integral histograms*/
     

    HImap = mxCalloc(bb*bn*N1*N2, sizeof(double));

    
    for (b=0; b<bn; b++) {
       Imax=IgRg[b];
       Imin=IgRg[b+bn];
       U=(Imax-Imin)/bb;

       for (k=0; k<bb; k++) {
          binc[k]=Imin+k*U+U/2; } 

       md=Imax;
       for (k=0; k<bb; k++) {
          tmp = fabs(Ig[b*N1*N2]-binc[k]);
          if (tmp < md) {
             md = tmp; 
             mdid = k;
          }
       }
       HImap[bb*b+mdid]=1; 
  
       for (j=1; j<N2; j++) {
          md=Imax;
        for (k=0; k<bb; k++) {
          tmp = fabs(Ig[j*N1+b*N1*N2]-binc[k]);
          if (tmp < md) {
             md = tmp; 
             mdid = k; 
           }
        }
        HImap[bb*b+mdid+j*bb*bn*N1]=1;
        for (k=0; k<bb; k++) {
           HImap[bb*b+k+j*dims[0]*dims[1]] = HImap[bb*b+k+j*dims[0]*dims[1]]
                        +HImap[bb*b+k+(j-1)*dims[0]*dims[1]];
        }
	   }  

       for (i=1; i<N1; i++) {
          md=Imax;
          for (k=0; k<bb; k++) {
             tmp = fabs(Ig[i+b*N1*N2]-binc[k]);
             tmpm[k] = 0;
             if (tmp < md) {
                md = tmp; 
                mdid = k; 
              }             
          }
          HImap[bb*b+mdid+i*dims[0]] = 1;
          tmpm[mdid] = 1;
          for (k=0; k<bb; k++) {
              HImap[bb*b+k+i*dims[0]] = HImap[bb*b+k+i*dims[0]] 
                              + HImap[bb*b+k+(i-1)*dims[0]];
          } 
          for (j=1; j<N2; j++){
             md=Imax;
             for (k=0; k<bb; k++) {
                tmp = fabs(Ig[i+j*N1+b*N1*N2]-binc[k]);
                if (tmp < md) {
                   md = tmp;
                   mdid = k;
                }
              }
             tmpm[mdid] = tmpm[mdid]+1;             
             for (k=0; k<bb; k++) {
                 HImap[bb*b+k+i*dims[0]+j*dims[0]*dims[1]]  
                     = HImap[bb*b+k+(i-1)*dims[0]+j*dims[0]*dims[1]] + tmpm[k];
             }
           }
        }
	}

    /* compute local spectral histograms */

 
    for (i=0; i<N1; i++)
       for (j=0; j<N2; j++) {
          if (i-ws>0) {
             wtl[0] = i-ws;}
          else {wtl[0] = 0;}
          if (j-ws>0) {
             wtl[1] = j-ws;}
          else {wtl[1] = 0;} 
          if (i+ws<N1-1) {
             wbr[0] = i+ws;}
          else {wbr[0] = N1-1;}
          if (j+ws<N2-1) {
             wbr[1] = j+ws;}
          else {wbr[1] = N2-1;}  /* upleft and bottom right corners*/
          sz = (wbr[1]-wtl[1]+1)*(wbr[0]-wtl[0]+1);

          if (wtl[0]==0 && wtl[1]==0) {
             for (k=0; k<bn*bb; k++) {
                sh_mx[k+i*dims[0]+j*dims[0]*dims[1]] = HImap[k+wbr[0]*dims[0]+wbr[1]*dims[0]*dims[1]]; }}             
          else if (wtl[0]==0 && wtl[1]!=0) {
             for (k=0; k<bn*bb; k++) {
                sh_mx[k+i*dims[0]+j*dims[0]*dims[1]] = HImap[k+wbr[0]*dims[0]+wbr[1]*dims[0]*dims[1]] 
                                 - HImap[k+wbr[0]*dims[0]+(wtl[1]-1)*dims[0]*dims[1]];} }                        
          else if (wtl[0]!=0 && wtl[1]==0) {
             for (k=0; k<bn*bb; k++) {
                sh_mx[k+i*dims[0]+j*dims[0]*dims[1]] = HImap[k+wbr[0]*dims[0]+wbr[1]*dims[0]*dims[1]] 
                                 - HImap[k+(wtl[0]-1)*dims[0]+wbr[1]*dims[0]*dims[1]];} }
          else   
             for (k=0; k<bn*bb; k++) {
                sh_mx[k+i*dims[0]+j*dims[0]*dims[1]] = HImap[k+wbr[0]*dims[0]+wbr[1]*dims[0]*dims[1]] 
                                   + HImap[k+(wtl[0]-1)*dims[0]+(wtl[1]-1)*dims[0]*dims[1]] 
                                   - HImap[k+wbr[0]*dims[0]+(wtl[1]-1)*dims[0]*dims[1]] 
								   - HImap[k+(wtl[0]-1)*dims[0]+wbr[1]*dims[0]*dims[1]];}
          for (k=0; k<bn*bb; k++) {
             sh_mx[k+i*dims[0]+j*dims[0]*dims[1]] = sh_mx[k+i*dims[0]+j*dims[0]*dims[1]]/sz;}          
    }
}







