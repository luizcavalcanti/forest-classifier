# include "math.h"
# include "mex.h"

int N1, N2, cnt, labelN, tb, bb, lb, rb , tgt;
int *res_cc, *mark, *SegRes, *stk;
void expand(int i, int j);
void expand2(int i, int j);

void mexFunction(    
    int nargout,
    mxArray *out[],
    int nargin,
    const mxArray *in[]
)
{
    int i, j, ii, jj, i1, j1, k, MinSz;
    int nbN, flag, nonstop, maxN, maxnbN, nb[500], nbCt[500];
  
    /* check argument */
    if (nargin < 2) {
        mexErrMsgTxt("Four input arguments required");
    }
    if (nargout> 1) {
        mexErrMsgTxt("Too many output arguments.");
    }

	res_cc = mxGetData(in[0]);
    N1 = mxGetM(in[0]);
    N2 = mxGetN(in[0]);    
	MinSz = mxGetScalar(in[1]);
	   
    out[0] = mxCreateNumericMatrix(N1, N2, mxINT32_CLASS, mxREAL);
    /*out[1] = mxCreateNumericArray(ndim, dims, mxSINGLE_CLASS, mxREAL);*/
	/*out[1] = mxCreateNumericMatrix(BinN,1, mxSINGLE_CLASS,mxREAL);*/

    if (out[0]==NULL) {
	    mexErrMsgTxt("Not enough memory for the output matrix 1");
	}
    SegRes = mxGetData(out[0]);
    /*HImap = mxGetPr(out[1]);*/
	/*binc = mxGetPr(out[1]);*/
   
  
	mark = mxCalloc(N1*N2, sizeof(int));
	stk = mxCalloc(N1*N2*2, sizeof(int));
	labelN=0;
    
    for (ii=0; ii<N1; ii++){
        for (jj=0; jj<N2; jj++){
            if (SegRes[ii+jj*N1]==0) {
                tgt=res_cc[ii+jj*N1];
                labelN++;
                tb=ii;
                bb=ii;
                lb=jj;
                rb=jj;
                
                cnt=0;
                expand(ii,jj);

			   if (cnt<MinSz){
			   for(i=tb;i<=bb;i++)  
				   for(j=lb;j<=rb;j++) {
                   if (SegRes[i+j*N1]==labelN){
                       SegRes[i+j*N1]=99999;
                   }					 
				   }
               labelN = labelN-1;
			   }

            }
        }
    }
	/* eliminate small noisy region */
	nonstop=1;
	while (nonstop) {
		nonstop=0;
	for (i1=0; i1<N1; i1++){
		for (j1=0; j1<N2; j1++){
			if (SegRes[i1+j1*N1]==99999){
                tgt=res_cc[i1+j1*N1];
                tb=i1;
                bb=i1;
                lb=j1;
                rb=j1;
                expand2(i1,j1);
                
                if (tb-1>=0)
                    tb=tb-1;
                if (bb+1<N1)
                    bb=bb+1;
                if (lb-1>=0)
                    lb=lb-1;
                if (rb+1<N2)
                    rb=rb+1;               
                
				for (i = 0; i < 500; i++){
					nb[i]=0;
					nbCt[i]=0;
				}
				nbN=0;
				for (i = tb; i <= bb; i++){
					for (j = lb; j <= rb; j++){
						if (mark[i+j*N1]==0 && SegRes[i+j*N1]!=99999){
							if (i>0 && mark[i-1+j*N1]==1 || i<N1-1 && mark[i+1+j*N1]==1 ||
								j>0 && mark[i+(j-1)*N1]==1 || j<N2-1 && mark[i+(j+1)*N1]==1){
									flag=0;
									for (k = 0; k <= nbN; k++){
										if (SegRes[i+j*N1]==nb[k]){											
											nbCt[k]=nbCt[k]+1;
											flag=1;
										}
									}
									if (flag==0){
										nbN++;
										nb[nbN]=SegRes[i+j*N1];
										nbCt[nbN]=1;										
									}
							}
						}
					}
				}
				if (nbN==0) {
				for (i = tb; i <= bb; i++)
					for (j = lb; j <= rb; j++){
						mark[i+j*N1]=0;
					}				
					nonstop=1;
					continue;
				}
				maxN=0;
				for (k = 1; k <= nbN; k++){
					if (nbCt[k]>maxN){
						maxN=nbCt[k];
						maxnbN=k;
					}
				}
				for (i = tb; i <= bb; i++){
					for (j = lb; j <= rb; j++){
						if (SegRes[i+j*N1]==99999 && mark[i+j*N1]==1)
							SegRes[i+j*N1]=nb[maxnbN];
					}
				}
				for (i = tb; i <= bb; i++)
					for (j = lb; j <= rb; j++){
						mark[i+j*N1]=0;
					}				
			}
		}
	}
	}
    
}


void expand(int i, int j) // non-recursive growing
{
	int ii, jj, stkcnt;

	stkcnt=1;
	stk[stkcnt-1]=i;
	stk[stkcnt-1+N1*N2]=j;

	while (stkcnt>0) {
		ii=stk[stkcnt-1];
		jj=stk[stkcnt-1+N1*N2];
		stkcnt=stkcnt-1;
		if (SegRes[ii+jj*N1]==labelN){
			continue;
		} 
		SegRes[ii+jj*N1]=labelN;
		cnt++;
		if (ii<tb) tb=ii;
		if (ii>bb) bb=ii;
		if (jj<lb) lb=jj;
		if (jj>rb) rb=jj;

		if ((ii+1<N1) && res_cc[ii+1+jj*N1]==tgt && SegRes[ii+1+jj*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii+1;
			stk[stkcnt-1+N1*N2]=jj;
		}
		if ((jj+1<N2) && res_cc[ii+(jj+1)*N1]==tgt && SegRes[ii+(jj+1)*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii;
			stk[stkcnt-1+N1*N2]=jj+1;
		}
		if ((ii-1>=0) && res_cc[ii-1+jj*N1]==tgt && SegRes[ii-1+jj*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii-1;
			stk[stkcnt-1+N1*N2]=jj;
		}
		if ((jj-1>=0) && res_cc[ii+(jj-1)*N1]==tgt && SegRes[ii+(jj-1)*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii;
			stk[stkcnt-1+N1*N2]=jj-1;
		}
	}
} 

void expand2(int i, int j) // non-recursive growing in part 2
{
	int ii, jj, stkcnt;

	stkcnt=1;
	stk[stkcnt-1]=i;
	stk[stkcnt-1+N1*N2]=j;

	while (stkcnt>0) {
		ii=stk[stkcnt-1];
		jj=stk[stkcnt-1+N1*N2];
		stkcnt=stkcnt-1;
		if (mark[ii+jj*N1]==1){
			continue;
		}
		mark[ii+jj*N1]=1;
		cnt++;
		if (ii<tb) tb=ii;
		if (ii>bb) bb=ii;
		if (jj<lb) lb=jj;
		if (jj>rb) rb=jj;

		if ((ii+1<N1) && res_cc[ii+1+jj*N1]==tgt && mark[ii+1+jj*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii+1;
			stk[stkcnt-1+N1*N2]=jj;
		}
		if ((jj+1<N2) && res_cc[ii+(jj+1)*N1]==tgt && mark[ii+(jj+1)*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii;
			stk[stkcnt-1+N1*N2]=jj+1;
		}
		if ((ii-1>=0) && res_cc[ii-1+jj*N1]==tgt && mark[ii-1+jj*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii-1;
			stk[stkcnt-1+N1*N2]=jj;
		}
		if ((jj-1>=0) && res_cc[ii+(jj-1)*N1]==tgt && mark[ii+(jj-1)*N1]==0){
			stkcnt=stkcnt+1;
			stk[stkcnt-1]=ii;
			stk[stkcnt-1+N1*N2]=jj-1;
		}
	}
} 


   