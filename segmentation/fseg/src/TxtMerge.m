function [res_cc]=TxtMerge(res0, EdgeMap, thr)

sz=size(res0);

res_cc0=RmSmRg(int32(res0),100);
[BndWtMx, BndLgMx]=AdjMxCrt(int32(res_cc0),single(EdgeMap),max(res_cc0(:)));
K=max(res_cc0(:));

while 1
    idx=find(BndLgMx>0);
    [MinWt mnidx]=min(BndWtMx(idx));
    if MinWt>thr
        break
    end
    [ii jj]=ind2sub([K,K],idx(mnidx));
    if BndLgMx(ii,jj)/min(sum(BndLgMx(ii,:)),sum(BndLgMx(jj,:)))<.2
        BndWtMx(ii,jj)=BndWtMx(ii,jj)*2;
        continue
    end    
    res_cc0(res_cc0==ii)=jj;
%     figure(101),imshow(res_cc0,[])
%     pause(.5)
    
    BndWtMx(ii,jj)=0;
    BndWtMx(jj,ii)=0;
    BndLgMx(ii,jj)=0;
    BndLgMx(jj,ii)=0;
    
    BndWtMx(:,jj)=(BndWtMx(:,jj).*BndLgMx(:,jj)+BndWtMx(:,ii).*BndLgMx(:,ii)) ...
        ./(BndLgMx(:,jj)+BndLgMx(:,ii)+eps);
    BndWtMx(:,ii)=0;
    BndWtMx(jj,:)=(BndWtMx(jj,:).*BndLgMx(jj,:)+BndWtMx(ii,:).*BndLgMx(ii,:)) ...
        ./(BndLgMx(jj,:)+BndLgMx(ii,:)+eps);
    BndWtMx(ii,:)=0;
    BndLgMx(:,jj)=BndLgMx(:,jj)+BndLgMx(:,ii);
    BndLgMx(:,ii)=0;
    BndLgMx(jj,:)=BndLgMx(jj,:)+BndLgMx(ii,:);
    BndLgMx(ii,:)=0;
end
res_cc=res_cc0;

res0_rs=zeros(sz(1),sz(2));
for i=1:max(res_cc(:))
    tmp=res0(res_cc==i);

    tmpL=unique(tmp);
    mxN=0;
    for k=1:length(tmpL)
        idx=find(tmp==tmpL(k));
        if length(idx)>mxN
            mxN=length(idx);
            Lb=tmpL(k);
        end
    end
    res0_rs(res_cc==i)=Lb;
end
res_cc=res0_rs;
