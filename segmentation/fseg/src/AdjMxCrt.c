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
    int N1, N2, dn, ws, dism;
    int i, j, b, k, rn, tmp1, tmp2;
    int *res_cc;
 
	float *up, *bt, *lf, *rt;   
    float *EdgeMap, *BndWtMx, *BndLgMx;
 
  
    /* check argument */
    if (nargin < 3) {
        mexErrMsgTxt("Three input arguments required");
    }
    if (nargout> 2) {
        mexErrMsgTxt("Too many output arguments.");
    }

    res_cc = mxGetData(in[0]);
    N1 = mxGetM(in[0]);
    N2 = mxGetN(in[0]);    
    EdgeMap = mxGetData(in[1]);
    rn=mxGetScalar(in[2]);
   
    out[0] = mxCreateNumericMatrix(rn, rn, mxSINGLE_CLASS, mxREAL);
    out[1] = mxCreateNumericMatrix(rn, rn, mxSINGLE_CLASS, mxREAL);
	/*out[1] = mxCreateNumericMatrix(BinN,1, mxSINGLE_CLASS,mxREAL);*/

    if (out[0]==NULL) {
	    mexErrMsgTxt("Not enough memory for the output matrix 1");
	}
    if (out[1]==NULL) {
	    mexErrMsgTxt("Not enough memory for the output matrix 1");
	}    

    BndWtMx = mxGetData(out[0]);
    BndLgMx = mxGetData(out[1]);
    /*HImap = mxGetPr(out[1]);*/
	/*binc = mxGetPr(out[1]);*/
     
 
    /* Compute adjacency matrix */

	for (i=0; i<N1; i++){
		for (j=0; j<N2; j++) {
            if (i-1>0 && res_cc[i+j*N1]!=res_cc[i-1+j*N1]){
                tmp1=res_cc[i+j*N1]-1;
                tmp2=res_cc[i-1+j*N1]-1;
                BndLgMx[tmp1+tmp2*rn]=BndLgMx[tmp1+tmp2*rn]+1;
                BndWtMx[tmp1+tmp2*rn]=BndWtMx[tmp1+tmp2*rn]+(EdgeMap[i+j*N1]+EdgeMap[i-1+j*N1])/2;
                BndLgMx[tmp2+tmp1*rn]=BndLgMx[tmp1+tmp2*rn];
                BndWtMx[tmp2+tmp1*rn]=BndWtMx[tmp1+tmp2*rn];
            }
            if (i+1<N1-1 && res_cc[i+j*N1]!=res_cc[i+1+j*N1]){
                tmp1=res_cc[i+j*N1]-1;
                tmp2=res_cc[i+1+j*N1]-1;
                BndLgMx[tmp1+tmp2*rn]=BndLgMx[tmp1+tmp2*rn]+1;
                BndWtMx[tmp1+tmp2*rn]=BndWtMx[tmp1+tmp2*rn]+(EdgeMap[i+j*N1]+EdgeMap[i+1+j*N1])/2;
                BndLgMx[tmp2+tmp1*rn]=BndLgMx[tmp1+tmp2*rn];
                BndWtMx[tmp2+tmp1*rn]=BndWtMx[tmp1+tmp2*rn];                
            }
            if (j-1>0 && res_cc[i+j*N1]!=res_cc[i+(j-1)*N1]){
                tmp1=res_cc[i+j*N1]-1;
                tmp2=res_cc[i+(j-1)*N1]-1;
                BndLgMx[tmp1+tmp2*rn]=BndLgMx[tmp1+tmp2*rn]+1;
                BndWtMx[tmp1+tmp2*rn]=BndWtMx[tmp1+tmp2*rn]+(EdgeMap[i+j*N1]+EdgeMap[i+(j-1)*N1])/2;
                BndLgMx[tmp2+tmp1*rn]=BndLgMx[tmp1+tmp2*rn];
                BndWtMx[tmp2+tmp1*rn]=BndWtMx[tmp1+tmp2*rn];
            }
            if (j+1<N2-1 && res_cc[i+j*N1]!=res_cc[i+(j+1)*N1]){
                tmp1=res_cc[i+j*N1]-1;
                tmp2=res_cc[i+(j+1)*N1]-1;
                BndLgMx[tmp1+tmp2*rn]=BndLgMx[tmp1+tmp2*rn]+1;
                BndWtMx[tmp1+tmp2*rn]=BndWtMx[tmp1+tmp2*rn]+(EdgeMap[i+j*N1]+EdgeMap[i+(j+1)*N1])/2;
                BndLgMx[tmp2+tmp1*rn]=BndLgMx[tmp1+tmp2*rn];
                BndWtMx[tmp2+tmp1*rn]=BndWtMx[tmp1+tmp2*rn];
            } 
        }		
    }
    
    for (i=0; i<rn; i++){
		for (j=0; j<rn; j++) {
            if (BndLgMx[i+j*rn]>=5){
                BndWtMx[i+j*rn]=BndWtMx[i+j*rn]/BndLgMx[i+j*rn];
                BndLgMx[i+j*rn]=floorf(BndLgMx[i+j*rn]/2);
            }
            else {
                BndLgMx[i+j*rn]=0;
                BndWtMx[i+j*rn]=0;            
            }
        }
    }
}







