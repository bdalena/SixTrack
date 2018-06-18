!---------CrabAmp input in MV
!---------ejfv(j) should be in MeV/c --> CrabAmp/c/ejfv(j) is in rad
!---------ejfv(j) should be in MeV ?? --> CrabAmp/ejfv(j) is in rad
!---------CrabFreq input in MHz (ek)
!---------sigmv should be in mm --> sigmv*1e-3/clight*ek*1e6 in rad
  pi=four*atan_mb(one)
  crabfreq=ek(ix)*c1e3

  do j=1,napx ! loop over particles
    crabamp=ed(ix)*nzz(j)
    kcrab=(((sigmv(j)/(clight*(e0f/e0)))*crabfreq)*two)*pi+crabph(ix)
    yv(xory,j)=yv(xory,j) - (crabamp*c1e3)*sin_mb(kcrab)*(moidpsv(j)/e0f)
    ejv(j)=ejv(j)-(((((crabamp*crabfreq)*two)*pi)/clight)*xv(xory,j))*cos_mb(kcrab)
    ejf0v(j)=ejfv(j)

    ejfv(j)=sqrt(ejv(j)**2-nucm(j)**2)
    rvv(j)=(ejv(j)*e0f)/(e0*ejfv(j))
    dpsv(j)=(ejfv(j)*(nucm0/nucm(j))-e0f)/e0f
    oidpsv(j)=one/(one+dpsv(j))
    moidpsv(j)=mtc(j)/(one+dpsv(j))
    dpsv1(j)=(dpsv(j)*c1e3)*moidpsv(j)
    yv(1,j)=(ejf0v(j)/ejfv(j))*yv(1,j)
    yv(2,j)=(ejf0v(j)/ejfv(j))*yv(2,j)
    if(ithick.eq.1) call envarsv(dpsv,moidpsv,rvv,ekv)
  end do