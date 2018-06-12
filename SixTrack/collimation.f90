!-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----
!-----                                                                   -----
!-----    NEW BLOCKS PROVIDED FOR THE COLLIMATION STUDIES VIA SIXTRACK   -----
!-----                                                                   -----
!-----        G. ROBERT-DEMOLAIZE, October 27th, 2004                    -----
!-----                                                                   -----
!-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----

module collimation

  use floatPrecision
  use mathlib_bouncer
  use numerical_constants
  use mod_hions
  use mod_alloc
  use file_units
!  use mod_ranecu
  use mod_ranlux

#ifdef HDF5
  use hdf5_output
  use hdf5_tracks2
#endif

  implicit none

!  private

!+cd collpara
  integer, parameter :: max_ncoll  = 100
  integer, parameter :: maxn       = 20000
  integer, parameter :: numeff     = 32
  integer, parameter :: numeffdpop = 29
  integer, parameter :: nc         = 32

!+cd collMatNum
! EQ 2016 added variables for collimator material numbers
  integer, parameter :: nmat  = 14
  integer, parameter :: nrmat = 12

!+cd database
!GRD THIS BLOC IS COMMON TO MAINCR, DATEN, TRAUTHIN AND THIN6D
  logical, save :: do_coll
  logical, save :: do_select
  logical, save :: do_nominal
  logical, save :: dowrite_dist
  logical, save :: do_oneside
  logical, save :: dowrite_impact
  logical, save :: dowrite_secondary
  logical, save :: dowrite_amplitude
  logical, save :: radial
  logical, save :: systilt_antisymm
  logical, save :: dowritetracks
  logical, save :: cern
  logical, save :: do_nsig
  logical, save :: do_mingap

!SEPT2005 for slicing process
  integer, save :: nloop
  integer, save :: rnd_seed
  integer, save :: c_offsettilt_seed
  integer, save :: ibeam
  integer, save :: jobnumber
  integer, save :: do_thisdis
  integer, save :: n_slices
  integer, save :: pencil_distr

  real(kind=fPrec), save :: myenom,mynex,mdex,myney,mdey,                    &
  &nsig_tcp3,nsig_tcsg3,nsig_tcsm3,nsig_tcla3,                       &
  &nsig_tcp7,nsig_tcsg7,nsig_tcsm7,nsig_tcla7,nsig_tclp,nsig_tcli,   &
  &nsig_tcth1,nsig_tcth2,nsig_tcth5,nsig_tcth8,                      &
  &nsig_tctv1,nsig_tctv2,nsig_tctv5,nsig_tctv8,                      &
  &nsig_tcdq,nsig_tcstcdq,nsig_tdi,nsig_tcxrp,nsig_tcryo,            &
!SEPT2005 add these lines for the slicing procedure
  &smin_slices,smax_slices,recenter1,recenter2,                      &
  &fit1_1,fit1_2,fit1_3,fit1_4,fit1_5,fit1_6,ssf1,                   &
  &fit2_1,fit2_2,fit2_3,fit2_4,fit2_5,fit2_6,ssf2,                   &
!SEPT2005,OCT2006 added offset
  &emitnx0_dist,emitny0_dist,emitnx0_collgap,emitny0_collgap,        &
  &xbeat,xbeatphase,ybeat,ybeatphase,                                &
  &c_rmstilt_prim,c_rmstilt_sec,c_systilt_prim,c_systilt_sec,        &
  &c_rmsoffset_prim,c_rmsoffset_sec,c_sysoffset_prim,                &
  &c_sysoffset_sec,c_rmserror_gap,ndr,                            &
  &driftsx,driftsy,pencil_offset,pencil_rmsx,pencil_rmsy,            &
  &sigsecut3,sigsecut2,enerror,bunchlength

  real(kind=fPrec), private, save :: nr

  character(len=max_name_len), save :: name_sel
  character(len=80), save :: coll_db
  character(len=16), save :: castordir
  character(len=80), save :: filename_dis

!  common /grd/ myenom,mynex,mdex,myney,mdey,                        &
!  &nsig_tcp3,nsig_tcsg3,nsig_tcsm3,nsig_tcla3,                       &
!  &nsig_tcp7,nsig_tcsg7,nsig_tcsm7,nsig_tcla7,nsig_tclp,nsig_tcli,   &
!  &nsig_tcth1,nsig_tcth2,nsig_tcth5,nsig_tcth8,                      &
!  &nsig_tctv1,nsig_tctv2,nsig_tctv5,nsig_tctv8,                      &
!  &nsig_tcdq,nsig_tcstcdq,nsig_tdi,nsig_tcxrp,nsig_tcryo,            &
!  &smin_slices,smax_slices,recenter1,recenter2,                      &
!  &fit1_1,fit1_2,fit1_3,fit1_4,fit1_5,fit1_6,ssf1,                   &
!  &fit2_1,fit2_2,fit2_3,fit2_4,fit2_5,fit2_6,ssf2,                   &
!  &emitnx0_dist,emitny0_dist,emitnx0_collgap,emitny0_collgap,        &
!  &xbeat,xbeatphase,ybeat,ybeatphase,                                &
!  &c_rmstilt_prim,c_rmstilt_sec,c_systilt_prim,c_systilt_sec,        &
!  &c_rmsoffset_prim,c_rmsoffset_sec,c_sysoffset_prim,                &
!  &c_sysoffset_sec,c_rmserror_gap,nr,                                &
!  &ndr,driftsx,driftsy,pencil_offset,pencil_rmsx,pencil_rmsy,        &
!  &sigsecut3,sigsecut2,enerror,                                      &
!  &bunchlength,coll_db,name_sel,                                     &
!  &castordir,filename_dis,nloop,rnd_seed,c_offsettilt_seed,          &
!  &ibeam,jobnumber,do_thisdis,n_slices,pencil_distr,                 &
!  &do_coll,                                                          &
!  &do_select,do_nominal,dowrite_dist,do_oneside,dowrite_impact,      &
!  &dowrite_secondary,dowrite_amplitude,radial,systilt_antisymm,      &
!  &dowritetracks,cern,do_nsig,do_mingap
!+cd info
  integer, save :: ie, iturn, nabs_total
!  common  /info/ ie,iturn,nabs_total

 !-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!+cd dbcommon
! THIS BLOCK IS COMMON TO BOTH THIN6D, BEAMGAS, AND TRAUTHIN SUBROUTINES

  integer ieff,ieffdpop

  real(kind=fPrec), save :: myemitx0_dist, myemity0_dist, myemitx0_collgap, myemity0_collgap, myemitx
  real(kind=fPrec), save :: myalphay, mybetay, myalphax, mybetax, rselect
! myemitx was not saved?
!  common /ralph/ myemitx0_dist,myemity0_dist,myemitx0_collgap,myemity0_collgap,myalphax,myalphay,mybetax,mybetay,rselect

! M. Fiascaris for the collimation team
! variables for global inefficiencies studies
! of normalized and off-momentum halo
! Last modified: July 2016

  real(kind=fPrec), allocatable, save :: neff(:) !(numeff)
  real(kind=fPrec), allocatable, save :: rsig(:) !(numeff)
!  common  /eff/ neff,rsig

  integer, allocatable, save :: counteddpop(:,:) !(npart,numeffdpop)
  integer, allocatable, save :: npartdpop(:) !(numeffdpop)
  integer, allocatable, save :: counted2d(:,:,:) !(npart,numeff,numeffdpop)
  real(kind=fPrec), allocatable, save :: neffdpop(:) !(numeffdpop)
  real(kind=fPrec), allocatable, save :: dpopbins(:) !(numeffdpop)
!  common  /effdpop/ neffdpop,dpopbins,npartdpop,counteddpop

  real(kind=fPrec) dpopmin,dpopmax,mydpop
  real(kind=fPrec), allocatable, save :: neff2d(:,:) !(numeff,numeffdpop)
!  common /eff2d/ neff2d

  integer, allocatable, save :: nimpact(:) !(50)
  real(kind=fPrec), allocatable, save :: sumimpact(:) !(50)
  real(kind=fPrec), allocatable, save :: sqsumimpact(:) !(50)
!  common  /rimpact/ sumimpact,sqsumimpact,nimpact

  character(len=:), allocatable, save :: ename(:) !(max_name_len)(nblz)
  integer, allocatable, save :: nampl(:) !(nblz)
  real(kind=fPrec), allocatable, save :: sum_ax(:) !(nblz)
  real(kind=fPrec), allocatable, save :: sqsum_ax(:) !(nblz)
  real(kind=fPrec), allocatable, save :: sum_ay(:) !(nblz)
  real(kind=fPrec), allocatable, save :: sqsum_ay(:) !(nblz)
  real(kind=fPrec), allocatable, save :: sampl(:) !(nblz)
!  common  /ampl_rev/ sum_ax,sqsum_ax,sum_ay,sqsum_ay,sampl,ename,nampl

  real(kind=fPrec), allocatable, save :: neffx(:) !(numeff)
  real(kind=fPrec), allocatable, save :: neffy(:) !(numeff)
!  common /efficiency/ neffx,neffy

  integer, allocatable, save :: secondary(:) !(npart)
  integer, allocatable, save :: tertiary(:) !(npart)
  integer, allocatable, save :: other(:) !(npart)
  integer, allocatable, save :: scatterhit(:) !(npart)
  integer, allocatable, save :: part_hit_before_pos(:) !(npart)
  integer, allocatable, save :: part_hit_before_turn(:) !(npart)

  real(kind=fPrec), allocatable, save :: part_indiv(:) !(npart)
  real(kind=fPrec), allocatable, save :: part_linteract(:) !(npart)

  integer, allocatable, save :: part_hit_pos(:) !(npart)
  integer, allocatable, save :: part_hit_turn(:) !(npart)
  integer, allocatable, save :: part_abs_pos(:) !(npart)
  integer, allocatable, save :: part_abs_turn(:) !(npart)
  integer, allocatable, save :: part_select(:) !(npart)
  integer, allocatable, save :: nabs_type(:) !(npart)
  integer, save :: n_tot_absorbed
  integer, save :: n_absorbed

  real(kind=fPrec), allocatable, save :: part_impact(:) !(npart)
!  common /stats/ part_impact, part_hit_pos,part_hit_turn, part_hit_before_pos, part_hit_before_turn, &
!  & part_abs_pos,part_abs_turn, nabs_type,part_indiv, part_linteract,secondary,tertiary,other,scatterhit

!  common /n_tot_absorbed/ n_tot_absorbed,n_absorbed
!  common /part_select/ part_select

!  logical firstrun
!  common /firstrun/ firstrun

  integer, save :: nsurvive, nsurvive_end, num_selhit, n_impact
!  common /outcoll/ nsurvive,num_selhit,n_impact,nsurvive_end

  integer, save :: napx00
!  common /napx00/ napx00

!  integer  icoll
!  common  /icoll/  icoll

!UPGRADE January 2005
  integer, save :: db_ncoll

  character(len=:), allocatable, save :: db_name1(:) !(max_name_len)(max_ncoll)
  character(len=:), allocatable, save :: db_name2(:) !(max_name_len)(max_ncoll)
  character(len=:), allocatable, save :: db_material(:) !(4)(max_ncoll)
!APRIL2005
  real(kind=fPrec), allocatable, save :: db_nsig(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: db_length(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: db_offset(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: db_rotation(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: db_bx(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: db_by(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: db_tilt(:,:) !(max_ncoll,2)
!  common /colldatabase/ db_nsig,db_length,db_rotation,db_offset,db_bx,db_by,db_tilt,db_name1,db_name2,db_material,db_ncoll

  integer, allocatable, save :: cn_impact(:)  !(max_ncoll)
  integer, allocatable, save :: cn_absorbed(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: caverage(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: csigma(:) !(max_ncoll)
!  common /collsummary/ caverage,csigma,cn_impact,cn_absorbed

! Change the following block to npart
! This is the array that the generated distribution is placed into
  real(kind=fPrec), allocatable, save :: myx(:) !(maxn)
  real(kind=fPrec), allocatable, save :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable, save :: myy(:) !(maxn)
  real(kind=fPrec), allocatable, save :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable, save :: myp(:) !(maxn)
  real(kind=fPrec), allocatable, save :: mys(:) !(maxn)
!  common /coord/ myx,myxp,myy,myyp,myp,mys

  integer, allocatable, save :: counted_r(:,:) !(npart,numeff)
  integer, allocatable, save :: counted_x(:,:) !(npart,numeff)
  integer, allocatable, save :: counted_y(:,:) !(npart,numeff)
!  common /counting/ counted_r,counted_x,counted_y

  integer, save ::   samplenumber
  character(len=4), save :: smpl
  character(len=80), save :: pfile
!  common /samplenumber/ pfile,smpl,samplenumber
!
!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
!+cd dblinopt
!
! THIS BLOCK IS COMMON TO WRITELIN,LINOPT,TRAUTHIN,THIN6D AND MAINCR
!
  real(kind=fPrec), allocatable, save :: tbetax(:)  !(nblz)
  real(kind=fPrec), allocatable, save :: tbetay(:)  !(nblz)
  real(kind=fPrec), allocatable, save :: talphax(:) !(nblz)
  real(kind=fPrec), allocatable, save :: talphay(:) !(nblz)
  real(kind=fPrec), allocatable, save :: torbx(:)   !(nblz)
  real(kind=fPrec), allocatable, save :: torbxp(:)  !(nblz)
  real(kind=fPrec), allocatable, save :: torby(:)   !(nblz)
  real(kind=fPrec), allocatable, save :: torbyp(:)  !(nblz)
  real(kind=fPrec), allocatable, save :: tdispx(:)  !(nblz)
  real(kind=fPrec), allocatable, save :: tdispy(:)  !(nblz)

!  common /rtwiss/ tbetax,tbetay,talphax,talphay,torbx,torbxp,torby,torbyp,tdispx,tdispy
!
!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
! Variables for finding the collimator with the smallest gap
! and defining, stroring the gap rms error
!
  character(len=max_name_len) :: coll_mingap1, coll_mingap2
  real(kind=fPrec), allocatable, save :: gap_rms_error(:) !(max_ncoll)
  real(kind=fPrec) :: nsig_err, sig_offset
  real(kind=fPrec) :: mingap, gap_h1, gap_h2, gap_h3, gap_h4
  integer :: coll_mingap_id

! common /gap_err/ gap_rms_error
!
!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
!+cd dbdaten

! IN "+CD DBTRTHIN", "+CD DBDATEN" and "+CD DBTHIN6D"
! logical cut_input
! common /cut/ cut_input

! IN "+CD DBTRTHIN" and "+CD DBDATEN"
  real(kind=fPrec), save :: remitx_dist,remity_dist,remitx_collgap,remity_collgap
! common  /remit/ remitx_dist, remity_dist,remitx_collgap,remity_collgap
!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
  logical, save :: coll_found(100)


!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
!+cd dbcolcom
  logical, save :: firstcoll,found,onesided
  integer rnd_lux,rnd_k1,rnd_k2

  integer, save :: myix,myktrack

  real(kind=fPrec) nspx,nspy,mux0,muy0
  real(kind=fPrec) ax0,ay0,bx0,by0
  real(kind=fPrec), save :: totals

  ! IN "+CD DBTRTHIN", "+CD DBDATEN" and "+CD DBTHIN6D"
!  logical cut_input
!  common /cut/ cut_input

  real(kind=fPrec), allocatable, save :: xbob(:) !(nblz)
  real(kind=fPrec), allocatable, save :: ybob(:) !(nblz)
  real(kind=fPrec), allocatable, save :: xpbob(:) !(nblz)
  real(kind=fPrec), allocatable, save :: ypbob(:) !(nblz)

  real(kind=fPrec), allocatable, save :: xineff(:) !(npart)
  real(kind=fPrec), allocatable, save :: yineff(:) !(npart)
  real(kind=fPrec), allocatable, save :: xpineff(:) !(npart)
  real(kind=fPrec), allocatable, save :: ypineff(:) !(npart)

!  common /xcheck/ xbob,ybob,xpbob,ypbob,xineff,yineff,xpineff,ypineff

  real(kind=fPrec), allocatable, save :: mux(:) !(nblz)
  real(kind=fPrec), allocatable, save :: muy(:) !(nblz)
!  common /mu/ mux,muy
 
!  common /collocal/ myix,myktrack,totals,firstcoll,found,onesided

! common /icoll/  icoll
!
!
!  common /materia/mat
!  common /phase/x,xp,z,zp,dpop
!  common /nommom/p0
!  common /cjaw1/zlm
! END BLOCK DBCOLLIM


!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!+cd dbpencil
!
! THIS BLOCK IS COMMON TO THIN6D, TRAUTHIN, COLLIMATE32 AND MAINCR
!
  integer, save :: ipencil
  real(kind=fPrec), save :: xp_pencil0,yp_pencil0
  real(kind=fPrec), allocatable, save :: x_pencil(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: y_pencil(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: pencil_dx(:) !(max_ncoll)
!  common  /pencil/  xp_pencil0,yp_pencil0,pencil_dx,ipencil
!  common  /pencil2/ x_pencil, y_pencil
!
!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
!+cd dbmkdist
!++ Vectors of coordinates

!  integer :: i,j,mynp,nloop
!  real(kind=fPrec) :: myx(maxn) !(maxn)
!  real(kind=fPrec) :: myxp(maxn) !(maxn)
!  real(kind=fPrec) :: myy(maxn) !(maxn)
!  real(kind=fPrec) :: myyp(maxn) !(maxn)
!  real(kind=fPrec) :: myp(maxn) !(maxn)
!  real(kind=fPrec) :: mys(maxn) !(maxn)
!
!  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
!  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
!  &xsigmax,ysigmay,myenom,nr,ndr
!
!
!  character(len=80) :: dummy

! IN "+CD DBTRTHIN", "+CD DBDATEN", "+CD DBTHIN6D", and "+CD DBMKDIST"
! USED IN MULTIPLE COMMON BLOCKS
  integer, save :: mynp
  logical, save :: cut_input
!  common /cut/ cut_input

!from +cd interac
!October 2013
!Mean excitation energy (GeV) values added by Claudia for Bethe-Bloch implementation:
!  data (exenergy(i),i=1,5)/ 63.7e-9,166e-9, 322e-9, 727e-9, 823e-9 /
!  data (exenergy(i),i=6,7)/ 78e-9, 78.0e-9 /
!  data (exenergy(i),i=8,nrmat)/ 87.1e-9, 152.9e-9, 424e-9, 320.8e-9, 682.2e-9/
  real(kind=fPrec), parameter :: exenergy(nmat) = &
 & [ 63.7e-9_fPrec, 166e-9_fPrec, 322e-9_fPrec, 727e-9_fPrec, 823e-9_fPrec, 78e-9_fPrec, 78.0e-9_fPrec, 87.1e-9_fPrec, &
 & 152.9e-9_fPrec, 424e-9_fPrec, 320.8e-9_fPrec, 682.2e-9_fPrec, zero, c1e10 ]
! common/meanexen/exenergy(nmat)

!+cd dbtrthin

! Note: no saves needed

! integer   mynp
! common /mynp/ mynp

!++ Vectors of coordinates

  real(kind=fPrec), private :: mygammax,mygammay

  character(len=80), private :: dummy

  ! IN "+CD DBTRTHIN" and "+CD DBDATEN"
!  real(kind=fPrec) remitx_dist,remity_dist,
! &     remitx_collgap,remity_collgap
!  common  /remit/ remitx_dist, remity_dist,
! &     remitx_collgap,remity_collgap


  real(kind=fPrec), private :: ielem,iclr,grd
  character(len=160), private :: ch
  character(len=320), private :: ch1
  logical, private :: flag

  integer, private :: k
  integer np0

  character(len=160), private :: cmd
  character(len=160), private :: cmd2
  character(len=1), private :: ch0
  character(len=2), private :: ch00
  character(len=3), private :: ch000
  character(len=4), private :: ch0000
!
!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!

  logical, public, save :: firstrun
  integer, save :: icoll

!+cd flukavars
! RB DM 2014 added variables for FLUKA output
  real(kind=fPrec), private, save :: xInt,xpInt,yInt,ypInt,sInt
! common/flukaVars/xInt,xpInt,yInt,ypInt,sInt

!+cd funint
  real(kind=fPrec), private, save :: tftot
!  common/funint/tftot

!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!+cd dbthin6d

  integer, private :: ios
  integer, save :: num_surhit
  integer, save :: numbin
  integer, save :: ibin
  integer, save :: num_selabs
  integer, save :: iturn_last_hit
  integer, save :: iturn_absorbed
  integer, save :: iturn_survive
  integer, save :: imov
  integer, save :: totalelem
  integer, save :: selelem
  integer, save :: unitnumber
  integer, save :: distnumber
  integer, save :: turnnumber
  integer, private, save :: jb

! SR, 29-08-2005: add the required variable for slicing collimators
  integer, private, save :: jjj, ijk

  real(kind=fPrec), save :: zbv

  real(kind=fPrec), save :: c_length    !length in m
  real(kind=fPrec), save :: c_rotation  !rotation angle vs vertical in radian
  real(kind=fPrec), save :: c_aperture  !aperture in m
  real(kind=fPrec), save :: c_offset    !offset in m
  real(kind=fPrec), save :: c_tilt(2)   !tilt in radian
  character(len=4), save :: c_material  !material

  integer, allocatable, save :: ipart(:) !(npart)
  integer, allocatable, save :: flukaname(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: cx(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: cxp(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: cy(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: cyp(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: cp(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: cs(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcx(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcxp(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcy(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcyp(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcp(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcs(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcx0(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcxp0(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcy0(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcyp0(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rcp0(:) !(npart)

  real(kind=fPrec), allocatable, private, save :: xgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: xpgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: ygrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: ypgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: pgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: ejfvgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: sigmvgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: rvvgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: dpsvgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: oidpsvgrd(:) !(npart)
  real(kind=fPrec), allocatable, private, save :: dpsv1grd(:) !(npart)

  real(kind=fPrec), save :: enom_gev,betax,betay,xmax,ymax
  real(kind=fPrec), save :: nsig,calc_aperture,gammax,gammay,gammax0,gammay0,gammax1,gammay1
  real(kind=fPrec), save :: xj,xpj,yj,ypj,pj
  real(kind=fPrec), save :: arcdx,arcbetax,xdisp,rxjco,ryjco
  real(kind=fPrec), save :: rxpjco,rypjco,c_rmstilt,c_systilt
  real(kind=fPrec), save :: scale_bx, scale_by, scale_bx0, scale_by0, xkick, ykick, bx_dist, by_dist
  real(kind=fPrec), save :: xmax_pencil, ymax_pencil, xmax_nom, ymax_nom, nom_aperture, pencil_aperture

  real(kind=fPrec), allocatable, save :: xp_pencil(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: yp_pencil(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: csum(:) !(max_ncoll)
  real(kind=fPrec), allocatable, save :: csqsum(:) !(max_ncoll)

  real(kind=fPrec), save :: x_pencil0, y_pencil0, sum, sqsum
  real(kind=fPrec), save :: average, sigma, sigsecut, nspxd, xndisp, zpj

  real(kind=fPrec), save :: dnormx,dnormy,driftx,drifty,xnorm,xpnorm,xangle,ynorm,ypnorm,yangle,grdpiover2,grdpiover4,grd3piover4

!SEPT2005-SR, 29-08-2005 --- add parameter for the array length ---- TW
  real(kind=fPrec), allocatable, save :: x_sl(:) !(100)
  real(kind=fPrec), allocatable, save :: x1_sl(:) !(100)
  real(kind=fPrec), allocatable, save :: x2_sl(:) !(100)
  real(kind=fPrec), allocatable, save :: y1_sl(:) !(100)
  real(kind=fPrec), allocatable, save :: y2_sl(:) !(100)
  real(kind=fPrec), allocatable, save :: angle1(:) !(100)
  real(kind=fPrec), allocatable, save :: angle2(:) !(100)

  real(kind=fPrec), save :: max_tmp, a_tmp1, a_tmp2, ldrift, mynex2, myney2, Nap1pos,Nap2pos,Nap1neg,Nap2neg
  real(kind=fPrec), save :: tiltOffsPos1,tiltOffsPos2,tiltOffsNeg1,tiltOffsNeg2
  real(kind=fPrec), save :: beamsize1, beamsize2,betax1,betax2,betay1,betay2, alphax1, alphax2,alphay1,alphay2,minAmpl
!SEPT2005


!  common /dbthinc/ cx,cxp,cy,cyp,                                   &
!  &cp,cs,rcx,rcxp,rcy,rcyp,                                          &
!  &rcp,rcs,rcx0,rcxp0,rcy0,                                          &
!  &rcyp0,rcp0,enom_gev,betax,betay,xmax,ymax,                        &
!  &nsig,calc_aperture,gammax,gammay,gammax0,gammay0,gammax1,gammay1, &
!  &xj,xpj,yj,ypj,pj,arcdx,arcbetax,xdisp,rxjco,ryjco,                &
!  &rxpjco,rypjco,c_rmstilt,                                          &
!  &c_systilt,scale_bx,scale_by,scale_bx0,scale_by0,xkick,            &
!  &ykick,bx_dist,by_dist,xmax_pencil,ymax_pencil,xmax_nom,ymax_nom,  &
!  &nom_aperture,pencil_aperture,xp_pencil,                           &
!  &yp_pencil,x_pencil0,y_pencil0,sum,sqsum,                          &
!  &csum,csqsum,average,sigma,sigsecut,nspxd,                         &
!  &xndisp,xgrd,xpgrd,ygrd,ypgrd,zpj,                                 &
!  &pgrd,ejfvgrd,sigmvgrd,rvvgrd,                                     &
!  &dpsvgrd,oidpsvgrd,dpsv1grd,                                       &
!  &dnormx,dnormy,driftx,drifty,                                      &
!  &xnorm,xpnorm,xangle,ynorm,ypnorm,yangle,                          &
!  &grdpiover2,grdpiover4,grd3piover4,                                &
!  &x_sl,x1_sl,x2_sl,                                                 &
!  &y1_sl, y2_sl,                                                &
!  &angle1, angle2,                                              &
!  &max_tmp,                                                     &
!  &a_tmp1, a_tmp2, ldrift, mynex2, myney2,                      &
!  &Nap1pos,Nap2pos,Nap1neg,Nap2neg,                             &
!  &tiltOffsPos1,tiltOffsPos2,tiltOffsNeg1,tiltOffsNeg2,         &
!  &beamsize1, beamsize2,betax1,betax2,betay1,betay2,            &
!  &alphax1, alphax2,alphay1,alphay2,minAmpl,                    &
!  &ios,num_surhit,numbin,ibin,                                       &
!  &num_selabs,iturn_last_hit,iturn_absorbed,iturn_survive,imov,      &
!  &ipart,totalelem,selelem,unitnumber,distnumber,turnnumber,         &
!  &jb,flukaname,                                                     &
!  &jjj,ijk,zbv,c_length,c_rotation,                                  &
!  &c_aperture,c_offset,c_tilt,c_material

! myran_gauss,rndm5,

!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
!+cd dbcollim
  integer, private, save :: nev
!  real(kind=fPrec), private, save :: c_xmin,c_xmax,c_xpmin,c_xpmax,c_zmin,c_zmax,c_zpmin,c_zpmax,length
!!  common /cmom/xmin,xmax,xpmin,xpmax,zmin,zmax,zpmin,zpmax,length,nev
!
!  real(kind=fPrec), private, save :: c_mybetax,c_mybetaz,mymux,mymuz,atdi
!!  common /other/mybetax,mybetaz,mymux,mymuz,atdi

  real(kind=fPrec), private, save :: length

! Common to interac and dbcollim
  integer, private, save :: mat
  real(kind=fPrec), private, save :: x,xp,z,zp,dpop
  real(kind=fPrec), private, save :: p0
  real(kind=fPrec), private, save :: zlm
!
!-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
!
!+cd interac
  integer, save :: mcurr
!+ca collMatNum
  real(kind=fPrec), save :: xintl(nmat)
  real(kind=fPrec), save :: radl(nmat)
  real(kind=fPrec), save :: zlm1
  real(kind=fPrec), save :: xpsd
  real(kind=fPrec), save :: zpsd
  real(kind=fPrec), save :: psd
  real(kind=fPrec), save :: anuc(nmat)
  real(kind=fPrec), save :: rho(nmat)
  real(kind=fPrec), save :: emr(nmat)
  real(kind=fPrec), save :: tlcut
  real(kind=fPrec), save :: hcut(nmat)
  real(kind=fPrec), save :: csect(0:5,nmat)
  real(kind=fPrec), save :: csref(0:5,nmat)
  real(kind=fPrec), save :: bnref(nmat)
  real(kind=fPrec), save :: freep(nmat)
  real(kind=fPrec), save :: cprob(0:5,nmat)
  real(kind=fPrec), save :: bn(nmat)
  real(kind=fPrec), save :: bpp
  real(kind=fPrec), save :: xln15s
  real(kind=fPrec), save :: ecmsq
  real(kind=fPrec), save :: pptot
  real(kind=fPrec), save :: ppel
  real(kind=fPrec), save :: ppsd
  real(kind=fPrec), save :: pptref
  real(kind=fPrec), save :: pperef
  real(kind=fPrec), save :: pref
  real(kind=fPrec), save :: pptco
  real(kind=fPrec), save :: ppeco
  real(kind=fPrec), save :: sdcoe
  real(kind=fPrec), save :: freeco
  real(kind=fPrec), save :: zatom(nmat)
  real(kind=fPrec), save :: dpodx(nmat)

!electron density and plasma energy
  real(kind=fPrec), save :: edens(nmat)
  real(kind=fPrec), save :: pleng(nmat)

! parameter(fnavo=6.02214129e23_fPrec)
  real(kind=fPrec), save :: cgen(200,nmat)
  character(4), save :: mname(nmat)

!  common/mater/anuc(nmat),zatom(nmat),rho(nmat),emr(nmat)
!  common/coul/tlcut,hcut(nmat),cgen(200,nmat),mcurr
!  common/scat/cs(0:5,nmat),csref(0:5,nmat),bnref(nmat),freep(nmat)
!  common/scatu/cprob(0:5,nmat),bn(nmat),bpp,xln15s,ecmsq
!  common/scatu2/xintl(nmat),radl(nmat),mname
!  common/scatpp/pptot,ppel,ppsd
!  common/sppref/pptref,pperef,pref,pptco,ppeco,sdcoe,freeco
!! real(kind=fPrec) exenergy
!! common/meanexen/exenergy(nmat)
!  common/cmcs1/zlm1
!  common/sindif/xpsd,zpsd,psd
!  common/cdpodx/dpodx
!  common/cions/edens(nmat),pleng(nmat)


!  common/materia/mat
!  common/phase/x,xp,z,zp,dpop
!  common/nommom/p0
!  common/cjaw1/zlm

!>
!! block data scdata
!! Cross section inputs and material property database
!! GRD CHANGED ON 2/2003 TO INCLUDE CODE FOR C, C2 from JBJ (rwa)
!<
  integer, private :: i
! Total number of materials are defined in nmat
! Number of real materials are defined in nrmat
! The last materials in nmat are 'vacuum' and 'black',see in sub. SCATIN

! Reference data at pRef=450Gev
  data (mname(i),i=1,nrmat)/ 'Be','Al','Cu','W','Pb','C','C2','MoGR','CuCD', 'Mo', 'Glid', 'Iner'/

  data mname(nmat-1), mname(nmat)/'vacu','blac'/

!GRD IMPLEMENT CHANGES FROM JBJ, 2/2003 RWA
  data (anuc(i),i=1,5)/ 9.01d0,26.98d0,63.55d0,183.85d0,207.19d0/
  data (anuc(i),i=6,7)/12.01d0,12.01d0/
  data (anuc(i),i=8,nrmat)/13.53d0,25.24d0,95.96d0,63.15d0,166.7d0/

  data (zatom(i),i=1,5)/ 4d0, 13d0, 29d0, 74d0, 82d0/
  data (zatom(i),i=6,7)/ 6d0, 6d0/
  data (zatom(i),i=8,nrmat)/ 6.65d0, 11.9d0, 42d0, 28.8d0, 67.7d0/

  data (rho(i),i=1,5)/ 1.848d0, 2.70d0, 8.96d0, 19.3d0, 11.35d0/
  data (rho(i),i=6,7)/ 1.67d0, 4.52d0/
  data (rho(i),i=8,nrmat)/ 2.5d0, 5.4d0, 10.22d0, 8.93d0, 18d0/

  data (radl(i),i=1,5)/ 0.353d0,0.089d0,0.0143d0,0.0035d0,0.0056d0/
  data (radl(i),i=6,7)/ 0.2557d0, 0.094d0/
  data (radl(i),i=8,nrmat)/ 0.1193d0, 0.0316d0, 0.0096d0, 0.0144d0, 0.00385d0/
  data radl(nmat-1),radl(nmat)/ 1.d12, 1.d12 /

!MAY06-GRD value for Tungsten (W) not stated
  data (emr(i),i=1,5)/  0.22d0, 0.302d0, 0.366d0, 0.520d0, 0.542d0/
  data (emr(i),i=6,7)/  0.25d0, 0.25d0/
  data (emr(i),i=8,nrmat)/ 0.25d0, 0.308d0, 0.481d0, 0.418d0, 0.578d0/

  data tlcut / 0.0009982d0/
  data (hcut(i),i=1,5)/0.02d0, 0.02d0, 3*0.01d0/
  data (hcut(i),i=6,7)/0.02d0, 0.02d0/
  data (hcut(i),i=8,nrmat)/0.02d0, 0.02d0, 0.02d0, 0.02d0, 0.02d0/

  data (dpodx(i),i=1,5)/ .55d0, .81d0, 2.69d0, 5.79d0, 3.4d0 /
  data (dpodx(i),i=6,7)/ .75d0, 1.5d0 /

! All cross-sections are in barns,nuclear values from RPP at 20geV
! Coulomb is integerated above t=tLcut[Gev2] (+-1% out Gauss mcs)

! in Cs and CsRef,1st index: Cross-sections for processes
! 0:Total, 1:absorption, 2:nuclear elastic, 3:pp or pn elastic
! 4:Single Diffractive pp or pn, 5:Coulomb for t above mcs

! Claudia 2013: updated cross section values. Unit: Barn. New 2013:
  data csref(0,1),csref(1,1),csref(5,1)/0.271d0, 0.192d0, 0.0035d-2/
  data csref(0,2),csref(1,2),csref(5,2)/0.643d0, 0.418d0, 0.034d-2/
  data csref(0,3),csref(1,3),csref(5,3)/1.253d0, 0.769d0, 0.153d-2/
  data csref(0,4),csref(1,4),csref(5,4)/2.765d0, 1.591d0, 0.768d-2/
  data csref(0,5),csref(1,5),csref(5,5)/3.016d0, 1.724d0, 0.907d-2/
  data csref(0,6),csref(1,6),csref(5,6)/0.337d0, 0.232d0, 0.0076d-2/
  data csref(0,7),csref(1,7),csref(5,7)/0.337d0, 0.232d0, 0.0076d-2/
  data csref(0,8),csref(1,8),csref(5,8)/0.362d0, 0.247d0, 0.0094d-2/
  data csref(0,9),csref(1,9),csref(5,9)/0.572d0, 0.370d0, 0.0279d-2/
  data csref(0,10),csref(1,10),csref(5,10)/1.713d0,1.023d0,0.265d-2/
  data csref(0,11),csref(1,11),csref(5,11)/1.246d0,0.765d0,0.139d-2/
  data csref(0,12),csref(1,12),csref(5,12)/2.548d0,1.473d0,0.574d-2/

! pp cross-sections and parameters for energy dependence
  data pptref,pperef,sdcoe,pref/0.04d0,0.007d0,0.00068d0,450.0d0/
  data pptco,ppeco,freeco/0.05788d0,0.04792d0,1.618d0/

! Nuclear elastic slope from Schiz et al.,PRD 21(3010)1980
!MAY06-GRD value for Tungsten (W) not stated
  data (bnref(i),i=1,5)/74.7d0,120.3d0,217.8d0,440.3d0,455.3d0/
  data (bnref(i),i=6,7)/70.d0, 70.d0/
  data (bnref(i),i=8,nrmat)/ 76.7d0, 115.0d0, 273.9d0, 208.7d0, 392.1d0/
!GRD LAST 2 ONES INTERPOLATED

! Cprob to choose an interaction in iChoix
  data (cprob(0,i),i=1,nmat)/nmat*zero/
  data (cprob(5,i),i=1,nmat)/nmat*one/
  ! file units
  integer, private, save :: dist0_unit, survival_unit, collgaps_unit, collimator_temp_db_unit
  integer, private, save :: impact_unit, tracks2_unit, pencilbeam_distr_unit, coll_ellipse_unit, all_impacts_unit
  integer, private, save :: FLUKA_impacts_unit, FLUKA_impacts_all_unit, coll_scatter_unit, FirstImpacts_unit, RHIClosses_unit
  integer, private, save :: twisslike_unit, sigmasettings_unit, distsec_unit, efficiency_unit, efficiency_dpop_unit
  integer, private, save :: coll_summary_unit, amplitude_unit, amplitude2_unit, betafunctions_unit, orbitchecking_unit, distn_unit
  integer, private, save :: filename_dis_unit, coll_db_unit, CollPositions_unit, all_absorptions_unit, efficiency_2d_unit
  integer, private, save :: collsettings_unit, outlun
  ! These are not in use
  !integer, save :: betatron_unit, beta_beat_unit

#ifdef HDF5
  ! Variables to save hdf5 dataset indices
  integer, private, save :: coll_hdf5_survival
  integer, private, save :: coll_hdf5_allImpacts
  integer, private, save :: coll_hdf5_fstImpacts
  integer, private, save :: coll_hdf5_allAbsorb
  integer, private, save :: coll_hdf5_collScatter
#endif

contains

! General routines:
! collimate_init()
! collimate_start_sample()
! collimate_start_turn()
! collimate_start_element()
! collimate_start_collimator()
! collimate_do_collimator()
! collimate_end_collimator()
! collimate_end_element()
! collimate_end_turn()
! collimate_end_sample()
! collimate_exit()
!
! To stop a messy future, each of these should contain calls to
! implementation specific functions: e.g. collimate_init_k2(), etc.
! These should contain the "real" code.

! In addition, these files contain:
! 1: The RNG used in collimation.
! 2: A bunch distribution generator

subroutine collimation_allocate_arrays

  implicit none

  call alloc(tbetax,  nblz, zero, 'tbetax')  !(nblz)
  call alloc(tbetay,  nblz, zero, 'tbetay')  !(nblz)
  call alloc(talphax, nblz, zero, 'talphax') !(nblz)
  call alloc(talphay, nblz, zero, 'talphay') !(nblz)
  call alloc(torbx,   nblz, zero, 'torbx')   !(nblz)
  call alloc(torbxp,  nblz, zero, 'torbxp')  !(nblz)
  call alloc(torby,   nblz, zero, 'torby')   !(nblz)
  call alloc(torbyp,  nblz, zero, 'torbyp')  !(nblz)
  call alloc(tdispx,  nblz, zero, 'tdispx')  !(nblz)
  call alloc(tdispy,  nblz, zero, 'tdispy')  !(nblz)

  call alloc(flukaname, npart, 0, "flukaname") !(npart)
  call alloc(ipart, npart, 0, "ipart") !(npart)
  call alloc(cx,    npart, zero, "cx") !(npart)
  call alloc(cxp,   npart, zero, "cxp") !(npart)
  call alloc(cy,    npart, zero, "cy") !(npart)
  call alloc(cyp,   npart, zero, "cyp") !(npart)
  call alloc(cp,    npart, zero, "cp") !(npart)
  call alloc(cs,    npart, zero, "cs") !(npart)
  call alloc(rcx,   npart, zero, "rcx") !(npart)
  call alloc(rcxp,  npart, zero, "rcxp") !(npart)
  call alloc(rcy,   npart, zero, "rcy") !(npart)
  call alloc(rcyp,  npart, zero, "rcyp") !(npart)
  call alloc(rcp,   npart, zero, "rcp") !(npart)
  call alloc(rcs,   npart, zero, "rcs") !(npart)
  call alloc(rcx0,  npart, zero, "rcx0") !(npart)
  call alloc(rcxp0, npart, zero, "rcxp0") !(npart)
  call alloc(rcy0,  npart, zero, "rcy0") !(npart)
  call alloc(rcyp0, npart, zero, "rcyp0") !(npart)
  call alloc(rcp0,  npart, zero, "rcp0") !(npart)

  call alloc(xgrd,      npart, zero, "xgrd") !(npart)
  call alloc(xpgrd,     npart, zero, "xpgrd") !(npart)
  call alloc(ygrd,      npart, zero, "ygrd") !(npart)
  call alloc(ypgrd,     npart, zero, "ypgrd") !(npart)
  call alloc(pgrd,      npart, zero, "pgrd") !(npart)
  call alloc(ejfvgrd,   npart, zero, "ejfvgrd") !(npart)
  call alloc(sigmvgrd,  npart, zero, "sigmvgrd") !(npart)
  call alloc(rvvgrd,    npart, zero, "rvvgrd") !(npart)
  call alloc(dpsvgrd,   npart, zero, "dpsvgrd") !(npart)
  call alloc(oidpsvgrd, npart, zero, "oidpsvgrd") !(npart)
  call alloc(dpsv1grd,  npart, zero, "dpsv1grd") !(npart)

  call alloc(xbob,    nblz, zero, "xbob") !(nblz)
  call alloc(ybob,    nblz, zero, "ybob") !(nblz)
  call alloc(xpbob,   nblz, zero, "xpbob") !(nblz)
  call alloc(ypbob,   nblz, zero, "ypbob") !(nblz)

  call alloc(xineff,  npart, zero, "xineff") !(npart)
  call alloc(yineff,  npart, zero, "yineff") !(npart)
  call alloc(xpineff, npart, zero, "xpineff") !(npart)
  call alloc(ypineff, npart, zero, "ypineff") !(npart)

  call alloc(mux,     nblz, zero, "mux") !(nblz)
  call alloc(muy,     nblz, zero, "muy") !(nblz)

  call alloc(counteddpop, npart, numeffdpop, 0, "counteddpop") !(npart,numeffdpop)
  call alloc(counted2d, npart, numeff, numeffdpop, 0, "counted2d") !(npart,numeff,numeffdpop)

  call alloc(ename,    max_name_len, nblz, ' ', "ename") !(nblz)
  call alloc(nampl,    nblz, 0, "nampl") !(nblz)
  call alloc(sum_ax,   nblz, zero, "sum_ax") !(nblz)
  call alloc(sqsum_ax, nblz, zero, "sqsum_ax") !(nblz)
  call alloc(sum_ay,   nblz, zero, "sum_ay") !(nblz)
  call alloc(sqsum_ay, nblz, zero, "sqsum_ay") !(nblz)
  call alloc(sampl,    nblz, zero, "sampl") !(nblz)

  call alloc(secondary,            npart, 0, "secondary") !(npart)
  call alloc(tertiary,             npart, 0, "tertiary") !(npart)
  call alloc(other,                npart, 0, "other") !(npart)
  call alloc(scatterhit,           npart, 0, "scatterhit") !(npart)
  call alloc(part_hit_before_pos,  npart, 0, "part_hit_before_pos") !(npart)
  call alloc(part_hit_before_turn, npart, 0, "part_hit_before_turn") !(npart)
  call alloc(part_hit_pos,         npart, 0, "part_hit_pos") !(npart)
  call alloc(part_hit_turn,        npart, 0, "part_hit_turn") !(npart)
  call alloc(part_abs_pos,         npart, 0, "part_abs_pos") !(npart)
  call alloc(part_abs_turn,        npart, 0, "part_abs_turn") !(npart)
  call alloc(part_select,          npart, 0, "part_select") !(npart)
  call alloc(nabs_type,            npart, 0, "nabs_type") !(npart)

  call alloc(part_impact,    npart, zero, "part_impact") !(npart)
  call alloc(part_indiv,     npart, zero, "part_indiv") !(npart)
  call alloc(part_linteract, npart, zero, "part_linteract") !(npart)


  call alloc(counted_r, npart, numeff, 0, "counted_r") !(npart,numeff)
  call alloc(counted_x, npart, numeff, 0, "counted_x") !(npart,numeff)
  call alloc(counted_y, npart, numeff, 0, "counted_y") !(npart,numeff)

! Change the following block to npart
  call alloc(myx,  npart, zero, "myx") !(maxn)
  call alloc(myxp, npart, zero, "myxp") !(maxn)
  call alloc(myy,  npart, zero, "myy") !(maxn)
  call alloc(myyp, npart, zero, "myyp") !(maxn)
  call alloc(myp,  npart, zero, "myp") !(maxn)
  call alloc(mys,  npart, zero, "mys") !(maxn)

! Fixed allocations follow:
  call alloc(gap_rms_error, max_ncoll, zero, "gap_rms_error") !(max_ncoll)
  call alloc(xp_pencil, max_ncoll, zero, "xp_pencil")
  call alloc(yp_pencil, max_ncoll, zero, "yp_pencil")
  call alloc(csum,      max_ncoll, zero, "csum")
  call alloc(csqsum,    max_ncoll, zero, "csqsum")

  call alloc(x_pencil,  max_ncoll, zero, "x_pencil") !(max_ncoll)
  call alloc(y_pencil,  max_ncoll, zero, "y_pencil") !(max_ncoll)
  call alloc(pencil_dx, max_ncoll, zero, "pencil_dx") !(max_ncoll)

!SEPT2005-SR, 29-08-2005 --- add parameter for the array length ---- TW
  call alloc(x_sl, 100, zero, "x_sl") !(100)
  call alloc(x1_sl, 100, zero, "x1_sl") !(100)
  call alloc(x2_sl, 100, zero, "x2_sl") !(100)
  call alloc(y1_sl, 100, zero, "y1_sl") !(100)
  call alloc(y2_sl, 100, zero, "y2_sl") !(100)
  call alloc(angle1, 100, zero, "angle1") !(100)
  call alloc(angle2, 100, zero, "angle2") !(100)

  call alloc(npartdpop, numeffdpop, 0, "npartdpop") !(numeffdpop)
  call alloc(neff, numeff, zero, "neff") !(numeff)
  call alloc(rsig, numeff, zero, "rsig") !(numeff)
  call alloc(neffdpop, numeffdpop, zero, "neffdpop") !(numeffdpop)
  call alloc(dpopbins, numeffdpop, zero, "dpopbins") !(numeffdpop)
  call alloc(neff2d, numeff, numeffdpop, zero, "neff2d") !(numeff,numeffdpop)

  call alloc(nimpact, 50, 0, "nimpact") !(50)
  call alloc(sumimpact, 50, zero, "sumimpact") !(50)
  call alloc(sqsumimpact, 50, zero, "sqsumimpact") !(50)

  call alloc(neffx, numeff, zero, "neffx") !(numeff)
  call alloc(neffy, numeff, zero, "neffy") !(numeff)
  call alloc(db_name1, max_name_len, max_ncoll, ' ', "db_name1") !(max_ncoll)
  call alloc(db_name2, max_name_len, max_ncoll, ' ', "db_name2") !(max_ncoll)
  call alloc(db_material, 4, max_ncoll, '    ', "db_material") !(max_ncoll)
  call alloc(db_nsig, max_ncoll, zero, "db_nsig") !(max_ncoll)
  call alloc(db_length, max_ncoll, zero, "db_length") !(max_ncoll)
  call alloc(db_offset, max_ncoll, zero, "db_offset") !(max_ncoll)
  call alloc(db_rotation, max_ncoll, zero, "db_rotation") !(max_ncoll)
  call alloc(db_bx, max_ncoll, zero, "db_bx") !(max_ncoll)
  call alloc(db_by, max_ncoll, zero, "db_by") !(max_ncoll)
  call alloc(db_tilt, max_ncoll, 2, zero, "db_tilt") !(max_ncoll,2)

  call alloc(cn_impact, max_ncoll, 0, "cn_impact")  !(max_ncoll)
  call alloc(cn_absorbed, max_ncoll, 0, "cn_absorbed") !(max_ncoll)
  call alloc(caverage, max_ncoll, zero, "caverage") !(max_ncoll)
  call alloc(csigma, max_ncoll, zero, "csigma") !(max_ncoll)

end subroutine collimation_allocate_arrays

subroutine collimation_expand_arrays(npart_new, nblz_new)

  implicit none

  integer, intent(in) :: npart_new
  integer, intent(in) :: nblz_new

  call resize(tbetax,  nblz_new, zero, 'tbetax')  !(nblz)
  call resize(tbetay,  nblz_new, zero, 'tbetay')  !(nblz)
  call resize(talphax, nblz_new, zero, 'talphax') !(nblz)
  call resize(talphay, nblz_new, zero, 'talphay') !(nblz)
  call resize(torbx,   nblz_new, zero, 'torbx')   !(nblz)
  call resize(torbxp,  nblz_new, zero, 'torbxp')  !(nblz)
  call resize(torby,   nblz_new, zero, 'torby')   !(nblz)
  call resize(torbyp,  nblz_new, zero, 'torbyp')  !(nblz)
  call resize(tdispx,  nblz_new, zero, 'tdispx')  !(nblz)
  call resize(tdispy,  nblz_new, zero, 'tdispy')  !(nblz)

  call resize(flukaname, npart_new, 0, "flukaname") !(npart)
  call resize(ipart, npart_new, 0, "ipart") !(npart)
  call resize(cx,    npart_new, zero, "cx") !(npart)
  call resize(cxp,   npart_new, zero, "cxp") !(npart)
  call resize(cy,    npart_new, zero, "cy") !(npart)
  call resize(cyp,   npart_new, zero, "cyp") !(npart)
  call resize(cp,    npart_new, zero, "cp") !(npart)
  call resize(cs,    npart_new, zero, "cs") !(npart)
  call resize(rcx,   npart_new, zero, "rcx") !(npart)
  call resize(rcxp,  npart_new, zero, "rcxp") !(npart)
  call resize(rcy,   npart_new, zero, "rcy") !(npart)
  call resize(rcyp,  npart_new, zero, "rcyp") !(npart)
  call resize(rcp,   npart_new, zero, "rcp") !(npart)
  call resize(rcs,   npart_new, zero, "rcs") !(npart)
  call resize(rcx0,  npart_new, zero, "rcx0") !(npart)
  call resize(rcxp0, npart_new, zero, "rcxp0") !(npart)
  call resize(rcy0,  npart_new, zero, "rcy0") !(npart)
  call resize(rcyp0, npart_new, zero, "rcyp0") !(npart)
  call resize(rcp0,  npart_new, zero, "rcp0") !(npart)

  call resize(xgrd,      npart_new, zero, "xgrd") !(npart)
  call resize(xpgrd,     npart_new, zero, "xpgrd") !(npart)
  call resize(ygrd,      npart_new, zero, "ygrd") !(npart)
  call resize(ypgrd,     npart_new, zero, "ypgrd") !(npart)
  call resize(pgrd,      npart_new, zero, "pgrd") !(npart)
  call resize(ejfvgrd,   npart_new, zero, "ejfvgrd") !(npart)
  call resize(sigmvgrd,  npart_new, zero, "sigmvgrd") !(npart)
  call resize(rvvgrd,    npart_new, zero, "rvvgrd") !(npart)
  call resize(dpsvgrd,   npart_new, zero, "dpsvgrd") !(npart)
  call resize(oidpsvgrd, npart_new, zero, "oidpsvgrd") !(npart)
  call resize(dpsv1grd,  npart_new, zero, "dpsv1grd") !(npart)

  call resize(xbob,    nblz_new, zero, "xbob") !(nblz)
  call resize(ybob,    nblz_new, zero, "ybob") !(nblz)
  call resize(xpbob,   nblz_new, zero, "xpbob") !(nblz)
  call resize(ypbob,   nblz_new, zero, "ypbob") !(nblz)

  call resize(xineff,  npart_new, zero, "xineff") !(npart)
  call resize(yineff,  npart_new, zero, "yineff") !(npart)
  call resize(xpineff, npart_new, zero, "xpineff") !(npart)
  call resize(ypineff, npart_new, zero, "ypineff") !(npart)

  call resize(mux,     nblz_new, zero, "mux") !(nblz)
  call resize(muy,     nblz_new, zero, "muy") !(nblz)

  call resize(counteddpop, npart_new, numeffdpop, 0, "counteddpop") !(npart,numeffdpop)
  call resize(counted2d,   npart_new, numeff, numeffdpop, 0, "counted2d") !(npart,numeff,numeffdpop)

  call resize(ename,    max_name_len, nblz_new, ' ', "ename") !(nblz_new)
  call resize(nampl,    nblz_new, 0, "nampl") !(nblz_new)
  call resize(sum_ax,   nblz_new, zero, "sum_ax") !(nblz_new)
  call resize(sqsum_ax, nblz_new, zero, "sqsum_ax") !(nblz_new)
  call resize(sum_ay,   nblz_new, zero, "sum_ay") !(nblz_new)
  call resize(sqsum_ay, nblz_new, zero, "sqsum_ay") !(nblz_new)
  call resize(sampl,    nblz_new, zero, "sampl") !(nblz_new)

  call resize(secondary,            npart_new, 0, "secondary") !(npart_new)
  call resize(tertiary,             npart_new, 0, "tertiary") !(npart_new)
  call resize(other,                npart_new, 0, "other") !(npart_new)
  call resize(scatterhit,           npart_new, 0, "scatterhit") !(npart_new)
  call resize(part_hit_before_pos,  npart_new, 0, "part_hit_before_pos") !(npart_new)
  call resize(part_hit_before_turn, npart_new, 0, "part_hit_before_turn") !(npart_new)
  call resize(part_hit_pos,         npart_new, 0, "part_hit_pos") !(npart_new)
  call resize(part_hit_turn,        npart_new, 0, "part_hit_turn") !(npart_new)
  call resize(part_abs_pos,         npart_new, 0, "part_abs_pos") !(npart_new)
  call resize(part_abs_turn,        npart_new, 0, "part_abs_turn") !(npart_new)
  call resize(part_select,          npart_new, 0, "part_select") !(npart_new)
  call resize(nabs_type,            npart_new, 0, "nabs_type") !(npart_new)

  call resize(part_impact,    npart_new, zero, "part_impact") !(npart_new)
  call resize(part_indiv,     npart_new, zero, "part_indiv") !(npart_new)
  call resize(part_linteract, npart_new, zero, "part_linteract") !(npart_new)


  call alloc(counted_r, npart_new, numeff, 0, "counted_r") !(npart_new,numeff)
  call alloc(counted_x, npart_new, numeff, 0, "counted_x") !(npart_new,numeff)
  call alloc(counted_y, npart_new, numeff, 0, "counted_y") !(npart_new,numeff)

! Change the following block to npart
  call resize(myx,  npart_new, zero, "myx") !(maxn)
  call resize(myxp, npart_new, zero, "myxp") !(maxn)
  call resize(myy,  npart_new, zero, "myy") !(maxn)
  call resize(myyp, npart_new, zero, "myyp") !(maxn)
  call resize(myp,  npart_new, zero, "myp") !(maxn)
  call resize(mys,  npart_new, zero, "mys") !(maxn)

end subroutine collimation_expand_arrays

!>
!! collimate_init()
!! This routine is called once at the start of the simulation and
!! can be used to do any initial configuration and/or file loading.
!<
subroutine collimate_init()

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

#ifdef HDF5
  type(h5_dataField), allocatable :: fldDist0(:)
  integer                         :: fmtDist0, setDist0
#endif
  integer i,ix,j,jb,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen
  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom
!+ca dbdaten

#ifdef HDF5
  if(h5_useForCOLL) call h5_initForCollimation
#endif

#ifdef G4COLLIMAT
! These should be configured in the scatter block when possible/enabled
  real(kind=fPrec) g4_ecut
  integer g4_physics
#endif

  call funit_requestUnit('colltrack.out', outlun)
  open(unit=outlun, file='colltrack.out')

  write(lout,*) '         -------------------------------'
  write(lout,*)
  write(lout,*) '          Program      C O L L T R A C K '
  write(lout,*)
  write(lout,*) '            R. Assmann           -    AB/ABP'
  write(lout,*) '            C. Bracco            -    AB/ABP'
  write(lout,*) '            V. Previtali         -    AB/ABP'
  write(lout,*) '            S. Redaelli          -    AB/OP'
  write(lout,*) '            G. Robert-Demolaize  -    BNL'
  write(lout,*) '            A. Rossi             -    AB/ABP'
  write(lout,*) '            T. Weiler            -    IEKP'
  write(lout,*) '                 CERN 2001 - 2009'
  write(lout,*)
  write(lout,*) '         -------------------------------'
  write(lout,*) 'Collimation version of Sixtrack running... 08/2009'

  write(outlun,*)
  write(outlun,*)
  write(outlun,*) '         -------------------------------'
  write(outlun,*)
  write(outlun,*) '         Program      C O L L T R A C K '
  write(outlun,*)
  write(outlun,*) '            R. Assmann       -    AB/ABP'
  write(outlun,*) '             C.Bracco        -    AB/ABP'
  write(outlun,*) '           V. Previtali      -    AB/ABP'
  write(outlun,*) '           S. Redaelli       -    AB/OP'
  write(outlun,*) '      G. Robert-Demolaize    -    BNL'
  write(outlun,*) '             A. Rossi        -    AB/ABP'
  write(outlun,*) '             T. Weiler       -    IEKP'
  write(outlun,*)
  write(outlun,*) '                 CERN 2001 - 2009'
  write(outlun,*)
  write(outlun,*) '         -------------------------------'
  write(outlun,*)
  write(outlun,*)

  write(lout,*) '                     R. Assmann, F. Schmidt, CERN'
  write(lout,*) '                           C. Bracco,        CERN'
  write(lout,*) '                           V. Previtali,     CERN'
  write(lout,*) '                           S. Redaelli,      CERN'
  write(lout,*) '                       G. Robert-Demolaize,  BNL'
  write(lout,*) '                           A. Rossi,         CERN'
  write(lout,*) '                           T. Weiler         IEKP'

  write(lout,*)
  write(lout,*) 'Generating particle distribution at FIRST element!'
  write(lout,*) 'Optical functions obtained from Sixtrack internal!'
  write(lout,*) 'Emittance and energy obtained from Sixtrack input!'
  write(lout,*)
  write(lout,*)

  write(lout,*) 'Info: Betax0   [m]    ', tbetax(1)
  write(lout,*) 'Info: Betay0   [m]    ', tbetay(1)
  write(lout,*) 'Info: Alphax0         ', talphax(1)
  write(lout,*) 'Info: Alphay0         ', talphay(1)
  write(lout,*) 'Info: Orbitx0  [mm]   ', torbx(1)
  write(lout,*) 'Info: Orbitxp0 [mrad] ', torbxp(1)
  write(lout,*) 'Info: Orbity0  [mm]   ', torby(1)
  write(lout,*) 'Info: Orbitpy0 [mrad] ', torbyp(1)
  write(lout,*) 'Info: Emitx0_dist [um]', remitx_dist
  write(lout,*) 'Info: Emity0_dist [um]', remity_dist
  write(lout,*) 'Info: Emitx0_collgap [um]', remitx_collgap
  write(lout,*) 'Info: Emity0_collgap [um]', remity_collgap
  write(lout,*) 'Info: E0       [MeV]  ', e0
  write(lout,*)
  write(lout,*)

  myemitx0_dist = remitx_dist*c1m6
  myemity0_dist = remity_dist*c1m6
  myemitx0_collgap = remitx_collgap*c1m6
  myemity0_collgap = remity_collgap*c1m6

  myalphax = talphax(1)
  myalphay = talphay(1)
  mybetax  = tbetax(1)
  mybetay  = tbetay(1)

!07-2006      myenom   = e0
!      MYENOM   = 1.001*E0
!
  if (myemitx0_dist.le.zero .or. myemity0_dist.le.zero .or. myemitx0_collgap.le.zero .or. myemity0_collgap.le.zero) then
    write(lout,*) 'ERR> EMITTANCES NOT DEFINED! CHECK COLLIMAT BLOCK!'
    write(lout,*) "ERR> EXPECTED FORMAT OF LINE 9 IN COLLIMAT BLOCK:"
    write(lout,*) "emitnx0_dist  emitny0_dist  emitnx0_collgap  emitny0_collgap"

    write(lout,*) "ERR> ALL EMITTANCES SHOULD BE NORMALIZED.", &
      "FIRST PUT EMITTANCE FOR DISTRIBTION GENERATION, THEN FOR COLLIMATOR POSITION ETC. UNITS IN [MM*MRAD]."
    write(lout,*) "ERR> EXAMPLE:"
    write(lout,*) "2.5 2.5 3.5 3.5"
    call prror(-1)
  end if

!++  Calculate the gammas
  mygammax = (one+myalphax**2)/mybetax
  mygammay = (one+myalphay**2)/mybetay

!++  Number of points and generate distribution
!
!GRD SEMI-AUTOMATIC INPUT
!      NLOOP=10
!      MYNEX=6.003
!      MYDEX=0.0015
!      MYNEY=6.003
!      MYDEY=0.0015
!      DO_COLL=1
!      NSIG_PRIM=5.
!      NSIG_SEC=6.
  rselect=64

  write(lout,*) 'INFO>  NLOOP     = ', nloop
  write(lout,*) 'INFO>  DO_THISDIS     = ', do_thisdis
  write(lout,*) 'INFO>  MYNEX     = ', mynex
  write(lout,*) 'INFO>  MYDEX     = ', mdex
  write(lout,*) 'INFO>  MYNEY     = ', myney
  write(lout,*) 'INFO>  MYDEY     = ', mdey
  write(lout,*) 'INFO>  FILENAME_DIS     = ', filename_dis
  write(lout,*) 'INFO>  ENERROR     = ', enerror
  write(lout,*) 'INFO>  BUNCHLENGTH     = ', bunchlength
  write(lout,*) 'INFO>  RSELECT   = ', int(rselect)
  write(lout,*) 'INFO>  DO_COLL   = ', do_coll
!APRIL2005
!+if cr
!      write(lout,*) 'INFO>  NSIG_PRIM = ', nsig_prim
!+ei
!+if .not.cr
!      write(*,*) 'INFO>  NSIG_PRIM = ', nsig_prim
!+ei
!+if cr
!      write(lout,*) 'INFO>  NSIG_SEC  = ', nsig_sec
!+ei
!+if .not.cr
!      write(*,*) 'INFO>  NSIG_SEC  = ', nsig_sec
!+ei
  write(lout,*) 'INFO>  DO_NSIG   = ', do_nsig
  write(lout,*) 'INFO>  NSIG_TCP3    = ', nsig_tcp3
  write(lout,*) 'INFO>  NSIG_TCSG3   = ', nsig_tcsg3
  write(lout,*) 'INFO>  NSIG_TCSM3   = ', nsig_tcsm3
  write(lout,*) 'INFO>  NSIG_TCLA3   = ', nsig_tcla3
  write(lout,*) 'INFO>  NSIG_TCP7    = ', nsig_tcp7
  write(lout,*) 'INFO>  NSIG_TCSG7   = ', nsig_tcsg7
  write(lout,*) 'INFO>  NSIG_TCSM7   = ', nsig_tcsm7
  write(lout,*) 'INFO>  NSIG_TCLA7   = ', nsig_tcla7
  write(lout,*) 'INFO>  NSIG_TCLP    = ', nsig_tclp
  write(lout,*) 'INFO>  NSIG_TCLI    = ', nsig_tcli
! write(lout,*) 'INFO>  NSIG_TCTH    = ', nsig_tcth
! write(lout,*) 'INFO>  NSIG_TCTV    = ', nsig_tctv
  write(lout,*) 'INFO>  NSIG_TCTH1   = ', nsig_tcth1
  write(lout,*) 'INFO>  NSIG_TCTV1   = ', nsig_tctv1
  write(lout,*) 'INFO>  NSIG_TCTH2   = ', nsig_tcth2
  write(lout,*) 'INFO>  NSIG_TCTV2   = ', nsig_tctv2
  write(lout,*) 'INFO>  NSIG_TCTH5   = ', nsig_tcth5
  write(lout,*) 'INFO>  NSIG_TCTV5   = ', nsig_tctv5
  write(lout,*) 'INFO>  NSIG_TCTH8   = ', nsig_tcth8
  write(lout,*) 'INFO>  NSIG_TCTV8   = ', nsig_tctv8
  write(lout,*) 'INFO>  NSIG_TCDQ    = ', nsig_tcdq
  write(lout,*) 'INFO>  NSIG_TCSTCDQ = ', nsig_tcstcdq
  write(lout,*) 'INFO>  NSIG_TDI     = ', nsig_tdi
  write(lout,*) 'INFO>  NSIG_TCXRP   = ', nsig_tcxrp
  write(lout,*) 'INFO>  NSIG_TCRYP   = ', nsig_tcryo

  write(lout,*)
  write(lout,*) 'INFO> INPUT PARAMETERS FOR THE SLICING:'
  write(lout,*)
  write(lout,*) 'INFO>  N_SLICES    = ', n_slices
  write(lout,*) 'INFO>  SMIN_SLICES = ',smin_slices
  write(lout,*) 'INFO>  SMAX_SLICES = ',smax_slices
  write(lout,*) 'INFO>  RECENTER1   = ',recenter1
  write(lout,*) 'INFO>  RECENTER2   = ',recenter2
  write(lout,*)
  write(lout,*) 'INFO>  FIT1_1   = ',fit1_1
  write(lout,*) 'INFO>  FIT1_2   = ',fit1_2
  write(lout,*) 'INFO>  FIT1_3   = ',fit1_3
  write(lout,*) 'INFO>  FIT1_4   = ',fit1_4
  write(lout,*) 'INFO>  FIT1_5   = ',fit1_5
  write(lout,*) 'INFO>  FIT1_6   = ',fit1_6
  write(lout,*) 'INFO>  SCALING1 = ',ssf1
  write(lout,*)
  write(lout,*) 'INFO>  FIT2_1   = ',fit2_1
  write(lout,*) 'INFO>  FIT2_2   = ',fit2_2
  write(lout,*) 'INFO>  FIT2_3   = ',fit2_3
  write(lout,*) 'INFO>  FIT2_4   = ',fit2_4
  write(lout,*) 'INFO>  FIT2_5   = ',fit2_5
  write(lout,*) 'INFO>  FIT2_6   = ',fit2_6
  write(lout,*) 'INFO>  SCALING2 = ',ssf2
  write(lout,*)

!SEPT2005
!
! HERE WE CHECK IF THE NEW INPUT IS READ CORRECTLY
!
  write(lout,*) 'INFO>  EMITXN0_DIST      = ', emitnx0_dist
  write(lout,*) 'INFO>  EMITYN0_DIST      = ', emitny0_dist
  write(lout,*) 'INFO>  EMITXN0_COLLGAP   = ', emitnx0_collgap
  write(lout,*) 'INFO>  EMITYN0_COLLGAP   = ', emitny0_collgap
  write(lout,*)
  write(lout,*) 'INFO>  DO_SELECT         = ', do_select
  write(lout,*) 'INFO>  DO_NOMINAL        = ', do_nominal
  write(lout,*) 'INFO>  RND_SEED          = ', rnd_seed
  write(lout,*) 'INFO>  DOWRITE_DIST      = ', dowrite_dist
  write(lout,*) 'INFO>  NAME_SEL          = ', name_sel
  write(lout,*) 'INFO>  DO_ONESIDE        = ', do_oneside
  write(lout,*) 'INFO>  DOWRITE_IMPACT    = ', dowrite_impact
  write(lout,*) 'INFO>  DOWRITE_SECONDARY = ', dowrite_secondary
  write(lout,*) 'INFO>  DOWRITE_AMPLITUDE = ', dowrite_amplitude
  write(lout,*)
  write(lout,*) 'INFO>  XBEAT             = ', xbeat
  write(lout,*) 'INFO>  XBEATPHASE        = ', xbeatphase
  write(lout,*) 'INFO>  YBEAT             = ', ybeat
  write(lout,*) 'INFO>  YBEATPHASE        = ', ybeatphase
  write(lout,*)
  write(lout,*) 'INFO>  C_RMSTILT_PRIM     = ', c_rmstilt_prim
  write(lout,*) 'INFO>  C_RMSTILT_SEC      = ', c_rmstilt_sec
  write(lout,*) 'INFO>  C_SYSTILT_PRIM     = ', c_systilt_prim
  write(lout,*) 'INFO>  C_SYSTILT_SEC      = ', c_systilt_sec
  write(lout,*) 'INFO>  C_RMSOFFSET_PRIM   = ', c_rmsoffset_prim
  write(lout,*) 'INFO>  C_SYSOFFSET_PRIM   = ', c_sysoffset_prim
  write(lout,*) 'INFO>  C_RMSOFFSET_SEC    = ', c_rmsoffset_sec
  write(lout,*) 'INFO>  C_SYSOFFSET_SEC    = ', c_sysoffset_sec
  write(lout,*) 'INFO>  C_OFFSETTITLT_SEED = ', c_offsettilt_seed
  write(lout,*) 'INFO>  C_RMSERROR_GAP     = ', c_rmserror_gap
  write(lout,*) 'INFO>  DO_MINGAP          = ', do_mingap
  write(lout,*)
  write(lout,*) 'INFO>  RADIAL            = ', radial
  write(lout,*) 'INFO>  NR                = ', nr
  write(lout,*) 'INFO>  NDR               = ', ndr
  write(lout,*)
  write(lout,*) 'INFO>  DRIFTSX           = ', driftsx
  write(lout,*) 'INFO>  DRIFTSY           = ', driftsy
  write(lout,*) 'INFO>  CUT_INPUT         = ', cut_input
  write(lout,*) 'INFO>  SYSTILT_ANTISYMM  = ', systilt_antisymm
  write(lout,*)
  write(lout,*) 'INFO>  IPENCIL           = ', ipencil
  write(lout,*) 'INFO>  PENCIL_OFFSET     = ', pencil_offset
  write(lout,*) 'INFO>  PENCIL_RMSX       = ', pencil_rmsx
  write(lout,*) 'INFO>  PENCIL_RMSY       = ', pencil_rmsy
  write(lout,*) 'INFO>  PENCIL_DISTR      = ', pencil_distr
  write(lout,*)
  write(lout,*) 'INFO>  COLL_DB           = ', coll_db
  write(lout,*) 'INFO>  IBEAM             = ', ibeam
  write(lout,*)
  write(lout,*) 'INFO>  DOWRITETRACKS     = ', dowritetracks
  write(lout,*)
  write(lout,*) 'INFO>  CERN              = ', cern
  write(lout,*)
  write(lout,*) 'INFO>  CASTORDIR     = ', castordir
  write(lout,*)
  write(lout,*) 'INFO>  JOBNUMBER     = ', jobnumber
  write(lout,*)
  write(lout,*) 'INFO>  CUTS     = ', sigsecut2, sigsecut3
  write(lout,*)

  mynp = nloop*napx
  napx00 = napx

  write(lout,*) 'INFO>  NAPX     = ', napx, mynp
  write(lout,*) 'INFO>  Sigma_x0 = ', sqrt(mybetax*myemitx0_dist)
  write(lout,*) 'INFO>  Sigma_y0 = ', sqrt(mybetay*myemity0_dist)

! HERE WE SET THE MARKER FOR INITIALIZATION:
  firstrun = .true.

! ...and here is implemented colltrack's beam distribution:

!++  Initialize random number generator
  if (rnd_seed.eq.0) rnd_seed = mclock_liar()
  if (rnd_seed.lt.0) rnd_seed = abs(rnd_seed)
  rnd_lux = 3
  rnd_k1  = 0
  rnd_k2  = 0
  call rluxgo(rnd_lux, rnd_seed, rnd_k1, rnd_k2)
!  call recuin(rnd_seed, 0)
  write(lout,*)
  write(outlun,*) 'INFO>  rnd_seed: ', rnd_seed

!Call distribution routines only if collimation block is in fort.3, otherwise
!the standard sixtrack would be prevented by the 'stop' command
  if(do_coll) then
    if(radial) then
      call makedis_radial(mynp, myalphax, myalphay, mybetax, &
     &      mybetay, myemitx0_dist, myemity0_dist, myenom, nr, ndr, myx, myxp, myy, myyp, myp, mys)
    else
      if(do_thisdis.eq.1) then
        call makedis(mynp, myalphax, myalphay, mybetax, mybetay, myemitx0_dist, myemity0_dist, &
     &           myenom, mynex, mdex, myney, mdey, myx, myxp, myy, myyp, myp, mys)
      else if(do_thisdis.eq.2) then
        call makedis_st(mynp, myalphax, myalphay, mybetax, mybetay, myemitx0_dist, myemity0_dist, &
     &           myenom, mynex, mdex, myney, mdey, myx, myxp, myy, myyp, myp, mys)
      else if(do_thisdis.eq.3) then
        call makedis_de(mynp, myalphax, myalphay, mybetax, mybetay, myemitx0_dist, myemity0_dist, &
     &           myenom, mynex, mdex, myney, mdey,myx, myxp, myy, myyp, myp, mys,enerror,bunchlength)
      else if(do_thisdis.eq.4) then
        call readdis(filename_dis, mynp, myx, myxp, myy, myyp, myp, mys)
      else if(do_thisdis.eq.5) then
        call makedis_ga(mynp, myalphax, myalphay, mybetax, mybetay, myemitx0_dist, myemity0_dist, &
     &           myenom, mynex, mdex, myney, mdey, myx, myxp, myy, myyp, myp, mys, enerror, bunchlength )
      else if(do_thisdis.eq.6) then
        call readdis_norm(filename_dis, mynp, myalphax, myalphay, mybetax, mybetay, &
     &           myemitx0_dist, myemity0_dist, myenom, myx, myxp, myy, myyp, myp, mys, enerror, bunchlength)
      else
        write(lout,*) 'ERROR> review your distribution parameters !!'
        call prror(-1)
      end if
    end if
  end if
!++  Reset distribution for pencil beam
!
  if(ipencil.gt.0) then
    write(lout,*) 'WARN>  Distributions reset to pencil beam!'
    write(lout,*)
    write(outlun,*) 'WARN>  Distributions reset to pencil beam!'
    do j = 1, mynp
      myx(j)  = zero
      myxp(j) = zero
      myy(j)  = zero
      myyp(j) = zero
    end do
  endif

!++  Optionally write the generated particle distribution
#ifdef HDF5
  if(h5_useForCOLL .and. dowrite_dist) then
    allocate(fldDist0(6))
    fldDist0(1)  = h5_dataField(name="X",  type=h5_typeReal)
    fldDist0(2)  = h5_dataField(name="XP", type=h5_typeReal)
    fldDist0(3)  = h5_dataField(name="Y",  type=h5_typeReal)
    fldDist0(4)  = h5_dataField(name="YP", type=h5_typeReal)
    fldDist0(5)  = h5_dataField(name="S",  type=h5_typeReal)
    fldDist0(6)  = h5_dataField(name="P",  type=h5_typeReal)
    call h5_createFormat("collDist0", fldDist0, fmtDist0)
    call h5_createDataSet("dist0", h5_collID, fmtDist0, setDist0, mynp)
    call h5_prepareWrite(setDist0, mynp)
    call h5_writeData(setDist0, 1, mynp, myx(1:mynp))
    call h5_writeData(setDist0, 2, mynp, myxp(1:mynp))
    call h5_writeData(setDist0, 3, mynp, myy(1:mynp))
    call h5_writeData(setDist0, 4, mynp, myyp(1:mynp))
    call h5_writeData(setDist0, 5, mynp, mys(1:mynp))
    call h5_writeData(setDist0, 6, mynp, myp(1:mynp))
    call h5_finaliseWrite(setDist0)
    deallocate(fldDist0)
  else
#endif
    call funit_requestUnit('dist0.dat', dist0_unit)
    open(unit=dist0_unit,file='dist0.dat') !was 52
    if(dowrite_dist) then
      do j = 1, mynp
        write(dist0_unit,'(6(1X,E23.15))') myx(j), myxp(j), myy(j), myyp(j), mys(j), myp(j)
      end do
    end if
    close(dist0_unit)
#ifdef HDF5
  end if
#endif

!++  Initialize efficiency array
  do i=1,iu
    sum_ax(i)   = zero
    sqsum_ax(i) = zero
    sum_ay(i)   = zero
    sqsum_ay(i) = zero
    nampl(i)    = zero
    sampl(i)    = zero
  end do

  nspx = zero
  nspy = zero
  np0  = mynp
  ax0  = myalphax
  bx0  = mybetax
  mux0 = mux(1)
  ay0  = myalphay
  by0  = mybetay
  muy0 = muy(1)
  iturn = 1
  ie    = 1
  n_tot_absorbed = 0

  if(int(mynp/napx00) .eq. 0) then
    write (lout,*) ""
    write (lout,*) "********************************************"
    write (lout,*) "Error in setting up collimation tracking:"
    write (lout,*) "Number of samples is zero!"
    write (lout,*) "Did you forget the COLL block in fort.3?"
    write (lout,*) "If you want to do standard (not collimation) tracking, please use the standard SixTrack."
    write (lout,*) "Value of do_coll = ", do_coll
    write (lout,*) "Value of mynp    = ", mynp
    write (lout,*) "Value of napx00  = ", napx00
    write (lout,*) "********************************************"
    call prror(-1)
  end if


  call funit_requestUnit('CollPositions.dat', CollPositions_unit)
  open(unit=CollPositions_unit, file='CollPositions.dat')

!++  Read collimator database
  call readcollimator

!Then do any implementation specific initial loading
#ifdef COLLIMATE_K2
  call collimate_init_k2
#endif

#ifdef MERLINSCATTER
  call collimate_init_merlin
#endif

#ifdef G4COLLIMAT
!! This function lives in the G4Interface.cpp file in the g4collimat folder
!! Accessed by linking libg4collimat.a
!! Set the energy cut at 70% - i.e. 30% energy loss
  g4_ecut = 0.7_fPrec

!! Select the physics engine to use
!! 0 = FTFP_BERT
!! 1 = QGSP_BERT
  g4_physics = 0

  call g4_collimation_init(e0, rnd_seed, g4_ecut, g4_physics)
#endif

end subroutine collimate_init

! ================================================================================================ !
!  Parse Input Line
! ================================================================================================ !
subroutine collimate_parseInputLine(inLine, iLine, iErr)

  use string_tools
  use mod_common, only : napx

  implicit none

  character(len=*), intent(in)    :: inLine
  integer,          intent(inout) :: iLine
  logical,          intent(inout) :: iErr

  character(len=:), allocatable   :: lnSplit(:)
  integer nSplit
  logical spErr

!+ca database
!+ca dbcolcom
!+ca dbpencil

  call chr_split(inLine, lnSplit, nSplit, spErr)
  if(spErr) then
    write(lout,"(a)") "COLL> ERROR Failed to parse input line."
    iErr = .true.
    return
  end if

  if(nSplit == 0) return

  select case(iLine)

  case(1)

    if(nSplit /= 1) then
      write(lout,"(a,i0)") "COLL> ERROR Expected 1 value on line 1, got ",nSplit
      iErr = .true.
      return
    end if

    if(nSplit > 0) call chr_cast(lnSPlit(1),do_coll,iErr)

  case(2)

    if(nSplit > 0) call chr_cast(lnSPlit(1),nloop,iErr)
    if(nSplit > 1) call chr_cast(lnSPlit(2),myenom,iErr)

    if(nloop /= 1) then
      write(lout,"(a,i0)") "COLL> ERROR Support for multiple samples is deprecated. nloop must be 1, got ",nloop
      iErr = .true.
      return
    end if

    if(napx*2 > npart) then
      write(lout,"(2(a,i0))") "COLL> ERROR Maximum number of particles is ", npart, ", got ",(napx*2)
      iErr = .true.
      return
   endif

  case(3)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), do_thisdis,  iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), mynex,       iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), mdex,        iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), myney,       iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), mdey,        iErr)
    if(nSplit > 5)  filename_dis = lnSPlit(6)
    if(nSplit > 6)  call chr_cast(lnSPlit(7), enerror,     iErr)
    if(nSplit > 7)  call chr_cast(lnSPlit(8), bunchlength, iErr)

  case(4)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), do_nsig,     iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), nsig_tcp3,   iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), nsig_tcsg3,  iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), nsig_tcsm3,  iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), nsig_tcla3,  iErr)
    if(nSplit > 5)  call chr_cast(lnSPlit(6), nsig_tcp7,   iErr)
    if(nSplit > 6)  call chr_cast(lnSPlit(7), nsig_tcsg7,  iErr)
    if(nSplit > 7)  call chr_cast(lnSPlit(8), nsig_tcsm7,  iErr)
    if(nSplit > 8)  call chr_cast(lnSPlit(9), nsig_tcla7,  iErr)
    if(nSplit > 9)  call chr_cast(lnSPlit(10),nsig_tclp,   iErr)
    if(nSplit > 10) call chr_cast(lnSPlit(11),nsig_tcli,   iErr)
    if(nSplit > 11) call chr_cast(lnSPlit(12),nsig_tcdq,   iErr)
    if(nSplit > 12) call chr_cast(lnSPlit(13),nsig_tcstcdq,iErr)
    if(nSplit > 13) call chr_cast(lnSPlit(14),nsig_tdi,    iErr)

  case(5)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), nsig_tcth1,iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), nsig_tcth2,iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), nsig_tcth5,iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), nsig_tcth8,iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), nsig_tctv1,iErr)
    if(nSplit > 5)  call chr_cast(lnSPlit(6), nsig_tctv2,iErr)
    if(nSplit > 6)  call chr_cast(lnSPlit(7), nsig_tctv5,iErr)
    if(nSplit > 7)  call chr_cast(lnSPlit(8), nsig_tctv8,iErr)
    if(nSplit > 8)  call chr_cast(lnSPlit(9), nsig_tcxrp,iErr)
    if(nSplit > 9)  call chr_cast(lnSPlit(10),nsig_tcryo,iErr)

  case(6)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), n_slices,   iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), smin_slices,iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), smax_slices,iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), recenter1,  iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), recenter2,  iErr)

  case(7)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), fit1_1,iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), fit1_2,iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), fit1_3,iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), fit1_4,iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), fit1_5,iErr)
    if(nSplit > 5)  call chr_cast(lnSPlit(6), fit1_6,iErr)
    if(nSplit > 6)  call chr_cast(lnSPlit(7), ssf1,  iErr)

  case(8)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), fit2_1,iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), fit2_2,iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), fit2_3,iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), fit2_4,iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), fit2_5,iErr)
    if(nSplit > 5)  call chr_cast(lnSPlit(6), fit2_6,iErr)
    if(nSplit > 6)  call chr_cast(lnSPlit(7), ssf2,  iErr)

  case(9)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), emitnx0_dist,   iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), emitny0_dist,   iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), emitnx0_collgap,iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), emitny0_collgap,iErr)

  case(10)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), do_select,        iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), do_nominal,       iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), rnd_seed,         iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), dowrite_dist,     iErr)
    if(nSplit > 4)  name_sel = lnSPlit(5)
    if(nSplit > 5)  call chr_cast(lnSPlit(6), do_oneside,       iErr)
    if(nSplit > 6)  call chr_cast(lnSPlit(7), dowrite_impact,   iErr)
    if(nSplit > 7)  call chr_cast(lnSPlit(8), dowrite_secondary,iErr)
    if(nSplit > 8)  call chr_cast(lnSPlit(9), dowrite_amplitude,iErr)

  case(11)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), xbeat,     iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), xbeatphase,iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), ybeat,     iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), ybeatphase,iErr)

  case(12)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), c_rmstilt_prim,   iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), c_rmstilt_sec,    iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), c_systilt_prim,   iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), c_systilt_sec,    iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), c_rmsoffset_prim, iErr)
    if(nSplit > 5)  call chr_cast(lnSPlit(6), c_rmsoffset_sec,  iErr)
    if(nSplit > 6)  call chr_cast(lnSPlit(7), c_sysoffset_prim, iErr)
    if(nSplit > 7)  call chr_cast(lnSPlit(8), c_sysoffset_sec,  iErr)
    if(nSplit > 8)  call chr_cast(lnSPlit(9), c_offsettilt_seed,iErr)
    if(nSplit > 9)  call chr_cast(lnSPlit(10),c_rmserror_gap,   iErr)
    if(nSplit > 10) call chr_cast(lnSPlit(11),do_mingap,        iErr)

  case(13)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), radial,iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), nr,    iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), ndr,   iErr)

  case(14)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), driftsx,         iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), driftsy,         iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), cut_input,       iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), systilt_antisymm,iErr)

  case(15)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), ipencil,      iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), pencil_offset,iErr)
    if(nSplit > 2)  call chr_cast(lnSPlit(3), pencil_rmsx,  iErr)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), pencil_rmsy,  iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), pencil_distr, iErr)
#ifdef G4COLLIMAT
    if(ipencil > 0) then
      write(lout,"(a)") "COLL> ERROR Pencil distribution not supported with geant4"
      iErr = .true.
      return
    endif
#endif

  case(16)
    if(nSplit > 0)  coll_db =  lnSPlit(1)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), ibeam, iErr)

  case(17)
    if(nSplit > 0)  call chr_cast(lnSPlit(1), dowritetracks,iErr)
    if(nSplit > 1)  call chr_cast(lnSPlit(2), cern,         iErr)
    if(nSplit > 2)  castordir = lnSPlit(3)
    if(nSplit > 3)  call chr_cast(lnSPlit(4), jobnumber,    iErr)
    if(nSplit > 4)  call chr_cast(lnSPlit(5), sigsecut2,    iErr)
    if(nSplit > 5)  call chr_cast(lnSPlit(6), sigsecut3,    iErr)

  case default
    write(lout,"(a,i0,a)") "COLL> ERROR Unexpected line ",iLine," encountered."
    iErr = .true.

  end select

end subroutine collimate_parseInputLine

!>
!! collimate_start_sample()
!! This routine is called from trauthin before each sample
!! is injected into thin 6d
!<
subroutine collimate_start_sample(nsample)

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond
#ifdef CR
  use checkpoint_restart
#endif

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr,nsample
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

#ifdef HDF5
  type(h5_dataField), allocatable :: setFields(:)
  integer fmtHdf
#endif

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbthin6d
!+ca dbcolcom


  j = nsample
  samplenumber=j

! HERE WE OPEN ALL THE NEEDED OUTPUT FILES

  !FIXME : never used?
  ! call funit_requestUnit('betatron.dat', betatron_unit)
  ! open(unit=betatron_unit,file='betatron.dat') !was 99

  !FIXME : never used?
  ! call funit_requestUnit('beta_beat.dat', beta_beat_unit)
  ! open(unit=beta_beat_unit, file='beta_beat.dat') !was 42
  ! write(beta_beat_unit,*) '# 1=s 2=bx/bx0 3=by/by0 4=sigx0 5=sigy0 6=crot 7=acalc'

  ! Survival Output
#ifdef HDF5
  if(h5_useForCOLL) then
    allocate(setFields(2))
    setFields(1) = h5_dataField(name="TURN",  type=h5_typeInt)
    setFields(2) = h5_dataField(name="NSURV", type=h5_typeInt)
    call h5_createFormat("collSurvival", setFields, fmtHdf)
    call h5_createDataSet("survival", h5_collID, fmtHdf, coll_hdf5_survival, numl)
    deallocate(setFields)
  else
#endif
    call funit_requestUnit('survival.dat', survival_unit)
    open(unit=survival_unit, file='survival.dat') ! RB, DM: 2014 bug fix !was 44
    write(survival_unit,*) '# 1=turn 2=n_particle'
#ifdef HDF5
  end if
#endif

  call funit_requestUnit('collgaps.dat', collgaps_unit)
  open(unit=collgaps_unit, file='collgaps.dat') !was 43
  if(firstrun) write(collgaps_unit,*) '# ID name  angle[rad]  betax[m]  betay[m] halfgap[m]', &
 & '  Material  Length[m]  sigx[m]  sigy[m] tilt1[rad] tilt2[rad] nsig'

!      if (dowrite_impact) then
!        open(unit=46, file='coll_impact.dat')
!        write(46,*)                                                     &
!     &'# 1=sample 2=iturn 3=icoll 4=nimp 5=nabs 6=imp_av 7=imp_sig'
!      endif
!
  call funit_requestUnit('collimator-temp.db', collimator_temp_db_unit)
  open(unit=collimator_temp_db_unit, file='collimator-temp.db') !was 40
!
!      open(unit=47, file='tertiary.dat')
!      write(47,*)                                                       &
!     &'# 1=x 2=xp 3=y 4=yp 5=p 6=Ax 7=Axd 8=Ay 9=Ar 10=Ard'
!
!      if (dowrite_secondary) then
!        open(unit=48, file='secondary.dat')
!        write(48,'(2a)')                                                &
!     &'# 1=x 2=xp 3=y 4=yp 5=p 6=Ax 7=Axd 8=Ay 9=Ar 10=Ard'
!      endif

! TW06/08 added ouputfile for real collimator settings (incluing slicing, ...)
  call funit_requestUnit('collsettings.dat', collsettings_unit)
  open(unit=collsettings_unit, file='collsettings.dat') !was 55

  if(firstrun) then
    write(collsettings_unit,*) '# name  slicenumber  halfgap[m]  gap_offset[m] tilt jaw1[rad]  tilt jaw2[rad] length[m] material'
    write(CollPositions_unit,*) '%Ind           Name   Pos[m]'
  end if

  if(dowrite_impact) then
    call funit_requestUnit('impact.db', impact_unit)
    open(unit=impact_unit,file='impact.dat') !was 49
    write(impact_unit,*) '# 1=impact 2=divergence'
  endif


  if (dowritetracks) then
!GRD SPECIAL FILE FOR SECONDARY HALO
    if(cern) then
!      open(unit=41,file='stuff')
!      write(41,*) samplenumber
!      close(41)
!      open(unit=41,file='stuff')
!      read(41,*) smpl
!      close(41)
      read(samplenumber,*) smpl

      pfile(1:8) = 'tracks2.'

      if(samplenumber.le.9) then
        pfile(9:9) = smpl
        pfile(10:13) = '.dat'
      else if(samplenumber.gt.9.and.samplenumber.le.99) then
        pfile(9:10) = smpl
        pfile(11:14) = '.dat'
      else if(samplenumber.gt.99.and.samplenumber.le.int(mynp/napx00)) then
        pfile(9:11) = smpl
        pfile(12:15) = '.dat'
      end if

      if(samplenumber.le.9) then
        call funit_requestUnit(pfile(1:13), tracks2_unit)
        open(unit=tracks2_unit,file=pfile(1:13))
      end if

      if(samplenumber.gt.9.and.samplenumber.le.99) then
        call funit_requestUnit(pfile(1:14), tracks2_unit)
        open(unit=tracks2_unit,file=pfile(1:14))
      end if

      if(samplenumber.gt.99.and. samplenumber.le.int(mynp/napx00)) then
        call funit_requestUnit(pfile(1:15), tracks2_unit)
        open(unit=tracks2_unit,file=pfile(1:15))
      end if
    else
      call funit_requestUnit('tracks2.dat', tracks2_unit)
      open(unit=tracks2_unit,file='tracks2.dat') !was 38
    end if !end if (cern)

    if(firstrun) write(tracks2_unit,*) '# 1=name 2=turn 3=s 4=x 5=xp 6=y 7=yp 8=DE/E 9=type'

!AUGUST2006:write pencul sheet beam coordiantes to file ---- TW
    call funit_requestUnit('pencilbeam_distr.dat', pencilbeam_distr_unit)
    open(unit=pencilbeam_distr_unit, file='pencilbeam_distr.dat') !was 9997
    if(firstrun) write(pencilbeam_distr_unit,*) 'x    xp    y      yp'
#ifdef HDF5
    if(h5_writeTracks2) call h5tr2_init
#endif
  end if !end if (dowritetracks) then

!GRD-SR,09-02-2006 => new series of output controlled by the 'dowrite_impact flag
  if(do_select) then
    call funit_requestUnit('coll_ellipse.dat', coll_ellipse_unit)
    open(unit=coll_ellipse_unit, file='coll_ellipse.dat') !was 45
    if(firstrun) then
      write(coll_ellipse_unit,*) '#  1=name 2=x 3=y 4=xp 5=yp 6=E 7=s 8=turn 9=halo 10=nabs_type'
    end if
  end if

  if(dowrite_impact) then
#ifdef HDF5
    if(h5_useForCOLL .and. firstrun) then

      ! All Impacts and All Absorbtions
      allocate(setFields(3))
      setFields(1) = h5_dataField(name="ID",   type=h5_typeInt)
      setFields(2) = h5_dataField(name="TURN", type=h5_typeInt)
      setFields(3) = h5_dataField(name="S",    type=h5_typeReal)
      call h5_createFormat("collAllImpactAbsorb", setFields, fmtHdf)
      call h5_createDataSet("all_impacts",     h5_collID, fmtHdf, coll_hdf5_allImpacts)
      call h5_createDataSet("all_absorptions", h5_collID, fmtHdf, coll_hdf5_allAbsorb)
      deallocate(setFields)

      ! First Impacts
      allocate(setFields(14))
      setFields(1)  = h5_dataField(name="ID",     type=h5_typeInt)
      setFields(2)  = h5_dataField(name="TURN",   type=h5_typeInt)
      setFields(3)  = h5_dataField(name="ICOLL",  type=h5_typeInt)
      setFields(4)  = h5_dataField(name="NABS",   type=h5_typeInt)
      setFields(5)  = h5_dataField(name="S_IMP",  type=h5_typeReal)
      setFields(6)  = h5_dataField(name="S_OUT",  type=h5_typeReal)
      setFields(7)  = h5_dataField(name="X_IN",   type=h5_typeReal)
      setFields(8)  = h5_dataField(name="XP_IN",  type=h5_typeReal)
      setFields(9)  = h5_dataField(name="Y_IN",   type=h5_typeReal)
      setFields(10) = h5_dataField(name="YP_IN",  type=h5_typeReal)
      setFields(11) = h5_dataField(name="X_OUT",  type=h5_typeReal)
      setFields(12) = h5_dataField(name="XP_OUT", type=h5_typeReal)
      setFields(13) = h5_dataField(name="Y_OUT",  type=h5_typeReal)
      setFields(14) = h5_dataField(name="YP_OUT", type=h5_typeReal)
      call h5_createFormat("collFirstImpacts", setFields, fmtHdf)
      call h5_createDataSet("first_impacts", h5_collID, fmtHdf, coll_hdf5_fstImpacts)
      deallocate(setFields)

      ! Coll Scatter
      allocate(setFields(7))
      setFields(1) = h5_dataField(name="ID",    type=h5_typeInt)
      setFields(2) = h5_dataField(name="TURN",  type=h5_typeInt)
      setFields(3) = h5_dataField(name="ICOLL", type=h5_typeInt)
      setFields(4) = h5_dataField(name="NABS",  type=h5_typeInt)
      setFields(5) = h5_dataField(name="DP",    type=h5_typeReal)
      setFields(6) = h5_dataField(name="DX",    type=h5_typeReal)
      setFields(7) = h5_dataField(name="DY",    type=h5_typeReal)
      call h5_createFormat("collScatter", setFields, fmtHdf)
      call h5_createDataSet("coll_scatter", h5_collID, fmtHdf, coll_hdf5_collScatter)
      deallocate(setFields)

    else
#endif
    call funit_requestUnit('all_impacts.dat', all_impacts_unit)
    call funit_requestUnit('all_absorptions.dat', all_absorptions_unit)
    call funit_requestUnit('FLUKA_impacts.dat', FLUKA_impacts_unit)
    call funit_requestUnit('FLUKA_impacts_all.dat', FLUKA_impacts_all_unit)
    call funit_requestUnit('Coll_Scatter.dat', coll_scatter_unit)
    call funit_requestUnit('FirstImpacts.dat', FirstImpacts_unit)

    open(unit=all_impacts_unit, file='all_impacts.dat') !was 46
    open(unit=all_absorptions_unit, file='all_absorptions.dat') !was 47
    open(unit=FLUKA_impacts_unit, file='FLUKA_impacts.dat') !was 48
! RB: adding output files FLUKA_impacts_all.dat and coll_scatter.dat
    open(unit=FLUKA_impacts_all_unit, file='FLUKA_impacts_all.dat') !was 4801
    open(unit=coll_scatter_unit, file='Coll_Scatter.dat') !was 3998
    open(unit=FirstImpacts_unit, file='FirstImpacts.dat') !was 39

    if (firstrun) then
      write(all_impacts_unit,'(a)') '# 1=name 2=turn 3=s'
      write(all_absorptions_unit,'(a)') '# 1=name 2=turn 3=s'
      write(FLUKA_impacts_unit,'(a)') '# 1=icoll 2=c_rotation 3=s 4=x 5=xp 6=y 7=yp 8=nabs 9=np 10=turn'
      write(FirstImpacts_unit,*)                                                   &
 &     '%1=name,2=iturn, 3=icoll, 4=nabs, 5=s_imp[m], 6=s_out[m], ',&
 &     '7=x_in(b!)[m], 8=xp_in, 9=y_in, 10=yp_in, ',                &
 &     '11=x_out [m], 12=xp_out, 13=y_out, 14=yp_out'

! RB: write headers in new output files
      write(FLUKA_impacts_all_unit,'(a)') '# 1=icoll 2=c_rotation 3=s 4=x 5=xp 6=y 7=yp 8=nabs 9=np 10=turn'
      write(coll_scatter_unit,*) &
 &     "#1=icoll, 2=iturn, 3=np, 4=nabs (1:Nuclear-Inelastic,2:Nuclear-Elastic,3:pp-Elastic,4:Single-Diffractive,5:Coulomb)" &
 &     ,", 5=dp, 6=dx', 7=dy'"
    end if ! if (firstrun) then
#ifdef HDF5
    end if
#endif
  end if ! if(dowrite_impact) then

  if(name_sel(1:3).eq.'COL') then
    call funit_requestUnit('RHIClosses.dat', RHIClosses_unit)
    open(unit=RHIClosses_unit, file='RHIClosses.dat') !was 555
    if(firstrun) write(RHIClosses_unit,'(a)') '# 1=name 2=turn 3=s 4=x 5=xp 6=y 7=yp 8=dp/p 9=type'
  end if

!++  Copy new particles to tracking arrays. Also add the orbit offset at
!++  start of ring!

  do i = 1, napx00
    xv(1,i)  = c1e3 *  myx(i+(j-1)*napx00) + torbx(1)              !hr08
    yv(1,i)  = c1e3 * myxp(i+(j-1)*napx00) + torbxp(1)             !hr08
    xv(2,i)  = c1e3 *  myy(i+(j-1)*napx00) + torby(1)              !hr08
    yv(2,i)  = c1e3 * myyp(i+(j-1)*napx00) + torbyp(1)             !hr08

!JULY2005 assignation of the proper bunch length
    sigmv(i) = mys(i+(j-1)*napx00)
    ejv(i)   = myp(i+(j-1)*napx00)

!GRD FOR NOT FAST TRACKING ONLY
    ejfv(i)   = sqrt(ejv(i)**2-pma**2)                             !hr08
    rvv(i)    = (ejv(i)*e0f)/(e0*ejfv(i))
    dpsv(i)   = (ejfv(i)-e0f)/e0f
    oidpsv(i) = one/(one+dpsv(i))
    moidpsv(i)= mtc(i)/(one+dpsv(i))
    omoidpsv(i)=c1e3*((one-mtc(i))*oidpsv(i))
    dpsv1(i)  = (dpsv(i)*c1e3)*oidpsv(i)                          !hr08

    nlostp(i)=i

    do ieff =1, numeff
      counted_r(i,ieff) = 0
      counted_x(i,ieff) = 0
      counted_y(i,ieff) = 0

      do ieffdpop =1, numeffdpop
        counted2d(i,ieff,ieffdpop) = 0
      end do

    end do

    do ieffdpop =1, numeffdpop
      counteddpop(i,ieffdpop) = 0
    end do

  end do

!!!!!!!!!!!!!!!!!!!!!!START THIN6D CUT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!++  Some initialization
  do i = 1, numeff
    rsig(i) = (real(i,fPrec)/two - half) + five                           !hr08
  end do

  dpopbins(1) = c1m4

  do i = 2, numeffdpop
    dpopbins(i) = real(i-1,fPrec)*4e-4_fPrec
  end do

  firstcoll = .true.

!GRD HERE WE NEED TO INITIALIZE SOME COLLIMATION PARAMETERS
  napx = napx00

  do j = 1, napx
    part_hit_pos(j)   = 0
    part_hit_turn(j)  = 0
    part_abs_pos(j)   = 0
    part_abs_turn(j)  = 0
    part_select(j)    = 1
    part_indiv(j)     = -c1m6
    part_linteract(j) = zero
    part_impact(j)    = 0
    tertiary(j)       = 0
    secondary(j)      = 0
    other(j)          = 0
    scatterhit(j)     = 0
    nabs_type(j)      = 0
    ipart(j)          = j
    flukaname(j)      = 0
  end do

!++  This we only do once, for the first call to this routine. Numbers
!++  are saved in memory to use exactly the same info for each sample.
!++  COMMON block to decide for first usage and to save coll info.
  if(firstrun) then
  !Reading of collimation database moved to subroutine collimate_init

#ifdef BEAMGAS
!YIL call beam gas initiation routine
  call beamGasInit(myenom)
#endif

  write(lout,*) 'number of collimators', db_ncoll
  do icoll = 1, db_ncoll
    write(lout,*) 'COLLIMATOR', icoll, ' ', db_name1(icoll)
    write(lout,*) 'collimator', icoll, ' ', db_name2(icoll)
    coll_found(icoll) = .FALSE.
  end do

!******write settings for alignment error in colltrack.out file
  write(outlun,*) ' '
  write(outlun,*) 'Alignment errors settings (tilt, offset,...)'
  write(outlun,*) ' '
  write(outlun,*) 'SETTING> c_rmstilt_prim   : ', c_rmstilt_prim
  write(outlun,*) 'SETTING> c_rmstilt_sec    : ', c_rmstilt_sec
  write(outlun,*) 'SETTING> c_systilt_prim   : ', c_systilt_prim
  write(outlun,*) 'SETTING> c_systilt_sec    : ', c_systilt_sec
  write(outlun,*) 'SETTING> c_rmsoffset_prim : ', c_rmsoffset_prim
  write(outlun,*) 'SETTING> c_rmsoffset_sec  : ', c_rmsoffset_sec
  write(outlun,*) 'SETTING> c_sysoffset_prim : ', c_sysoffset_prim
  write(outlun,*) 'SETTING> c_sysoffset_sec  : ', c_sysoffset_sec
  write(outlun,*) 'SETTING> c_offsettilt seed: ', c_offsettilt_seed
  write(outlun,*) 'SETTING> c_rmserror_gap   : ', c_rmserror_gap
  write(outlun,*) 'SETTING> do_mingap        : ', do_mingap
  write(outlun,*) ' '

!     TW - 01/2007
!     added offset and random_seed for tilt and offset
!*****intialize random generator with offset_seed
  c_offsettilt_seed = abs(c_offsettilt_seed)
  rnd_lux = 3
  rnd_k1  = 0
  rnd_k2  = 0
  call rluxgo(rnd_lux, c_offsettilt_seed, rnd_k1, rnd_k2)
!      write(outlun,*) 'INFO>  c_offsettilt seed: ', c_offsettilt_seed

! reset counter to assure starting at the same position in case of
! using rndm5 somewhere else in the code before
  zbv = rndm5(1)

!++  Generate random tilts (Gaussian distribution plus systematic)
!++  Do this only for the first call of this routine (first sample)
!++  Keep all collimator database info and errors in memeory (COMMON
!++  block) in order to re-use exactly the same information for every
!++  sample.
  if(c_rmstilt_prim.gt.zero .or. c_rmstilt_sec.gt.zero .or. c_systilt_prim.ne.zero .or. c_systilt_sec.ne.zero) then
    do icoll = 1, db_ncoll
      if(db_name1(icoll)(1:3).eq.'TCP') then
        c_rmstilt = c_rmstilt_prim
        c_systilt = c_systilt_prim
      else
        c_rmstilt = c_rmstilt_sec
        c_systilt = c_systilt_sec
      end if

      db_tilt(icoll,1) = c_systilt+c_rmstilt*myran_gauss(three)

      if(systilt_antisymm) then
        db_tilt(icoll,2) = -one*c_systilt+c_rmstilt*myran_gauss(three)
      else
        db_tilt(icoll,2) =      c_systilt+c_rmstilt*myran_gauss(three)
      end if

      write(outlun,*) 'INFO>  Collimator ', db_name1(icoll), ' jaw 1 has tilt [rad]: ', db_tilt(icoll,1)
      write(outlun,*) 'INFO>  Collimator ', db_name1(icoll), ' jaw 2 has tilt [rad]: ', db_tilt(icoll,2)
    end do
  end if

!++  Generate random offsets (Gaussian distribution plus systematic)
!++  Do this only for the first call of this routine (first sample)
!++  Keep all collimator database info and errors in memeory (COMMON
!++  block) in order to re-use exactly the same information for every
!++  sample and throughout a all run.
 if(c_sysoffset_prim.ne.zero .or. c_sysoffset_sec.ne.zero .or.c_rmsoffset_prim.gt.zero .or.c_rmsoffset_sec.gt.zero) then
   do icoll = 1, db_ncoll

     if(db_name1(icoll)(1:3).eq.'TCP') then
       db_offset(icoll) = c_sysoffset_prim + c_rmsoffset_prim*myran_gauss(three)
     else
       db_offset(icoll) = c_sysoffset_sec +  c_rmsoffset_sec*myran_gauss(three)
     end if

     write(outlun,*) 'INFO>  offset: ', db_name1(icoll), db_offset(icoll)
   end do
 endif

!++  Generate random offsets (Gaussian distribution)
!++  Do this only for the first call of this routine (first sample)
!++  Keep all collimator database info and errors in memeory (COMMON
!++  block) in order to re-use exactly the same information for every
!++  sample and throughout a all run.
!         if (c_rmserror_gap.gt.0.) then
!            write(outlun,*) 'INFO> c_rmserror_gap = ',c_rmserror_gap
  do icoll = 1, db_ncoll
    gap_rms_error(icoll) = c_rmserror_gap * myran_gauss(three)
    write(outlun,*) 'INFO>  gap_rms_error: ', db_name1(icoll),gap_rms_error(icoll)
  end do

!---- creating a file with beta-functions at TCP/TCS
  call funit_requestUnit('twisslike.out', twisslike_unit)
  open(unit=twisslike_unit, file='twisslike.out') !was 10000
  call funit_requestUnit('sigmasettings.out', sigmasettings_unit)
  open(unit=sigmasettings_unit, file='sigmasettings.out') !was 10001
  mingap = 20

  do j=1,iu
! this transformation gives the right marker/name to the corresponding
! beta-dunctions or vice versa ;)
    if(ic(j).le.nblo) then
      do jb=1,mel(ic(j))
        myix=mtyp(ic(j),jb)
      end do
    else
      myix=ic(j)-nblo
    end if

! Using same code-block as below to evalute the collimator opening
! for each collimator, this is needed to get the smallest collimator gap
! in principal only looking for primary and secondary should be enough
! JULY 2008 added changes (V6.503) for names in TCTV -> TCTVA and TCTVB
! both namings before and after V6.503 can be used
    if ( bez(myix)(1:2).eq.'TC'.or. bez(myix)(1:2).eq.'tc'.or. bez(myix)(1:2).eq.'TD'.or. bez(myix)(1:2).eq.'td'&
 &  .or. bez(myix)(1:3).eq.'COL'.or. bez(myix)(1:3).eq.'col') then
      if(bez(myix)(1:3).eq.'TCP' .or. bez(myix)(1:3).eq.'tcp') then
        if(bez(myix)(7:9).eq.'3.B' .or. bez(myix)(7:9).eq.'3.b') then
          nsig = nsig_tcp3
        else
          nsig = nsig_tcp7
        endif
      else if(bez(myix)(1:4).eq.'TCSG' .or. bez(myix)(1:4).eq.'tcsg') then
        if(bez(myix)(8:10).eq.'3.B' .or. bez(myix)(8:10).eq.'3.b' .or. bez(myix)(9:11).eq.'3.B' .or. bez(myix)(9:11).eq.'3.b') then
          nsig = nsig_tcsg3
        else
          nsig = nsig_tcsg7
        endif
        if(bez(myix)(5:6).eq.'.4'.and.bez(myix)(8:9).eq.'6.') then
          nsig = nsig_tcstcdq
        endif
      else if(bez(myix)(1:4).eq.'TCSP' .or. bez(myix)(1:4).eq.'tcsp') then
        if(bez(myix)(9:11).eq.'6.B'.or. bez(myix)(9:11).eq.'6.b') then
          nsig = nsig_tcstcdq
        end if
      else if(bez(myix)(1:4).eq.'TCSM' .or. bez(myix)(1:4).eq.'tcsm') then
        if(bez(myix)(8:10).eq.'3.B' .or. bez(myix)(8:10).eq.'3.b' .or.bez(myix)(9:11).eq.'3.B' .or. bez(myix)(9:11).eq.'3.b') then
          nsig = nsig_tcsm3
        else
          nsig = nsig_tcsm7
        end if
      else if(bez(myix)(1:4).eq.'TCLA' .or. bez(myix)(1:4).eq.'tcla') then
        if(bez(myix)(9:11).eq.'7.B' .or. bez(myix)(9:11).eq.'7.b') then
          nsig = nsig_tcla7
        else
          nsig = nsig_tcla3
        end if
      else if(bez(myix)(1:4).eq.'TCDQ' .or. bez(myix)(1:4).eq.'tcdq') then
         nsig = nsig_tcdq
      ! YIL11: Checking only the IR value for TCT's..
      else if(bez(myix)(1:4).eq.'TCTH'.or.bez(myix)(1:4).eq.'tcth'.or.bez(myix)(1:5).eq.'TCTPH'.or.bez(myix)(1:5).eq.'tctph') then
        if(bez(myix)(8:8).eq.'1' .or. bez(myix)(9:9).eq.'1' ) then
          nsig = nsig_tcth1
        else if(bez(myix)(8:8).eq.'2' .or. bez(myix)(9:9).eq.'2' ) then
          nsig = nsig_tcth2
        else if(bez(myix)(8:8).eq.'5'.or. bez(myix)(9:9).eq.'5' ) then
          nsig = nsig_tcth5
        else if(bez(myix)(8:8).eq.'8' .or.  bez(myix)(9:9).eq.'8' ) then
          nsig = nsig_tcth8
        end if
      else if(bez(myix)(1:4).eq.'TCTV'.or.bez(myix)(1:4).eq.'tctv'.or.bez(myix)(1:5).eq.'TCTPV'.or.bez(myix)(1:5).eq.'tctpv') then
        if(bez(myix)(8:8).eq.'1' .or. bez(myix)(9:9).eq.'1' ) then
           nsig = nsig_tctv1
        else if(bez(myix)(8:8).eq.'2' .or. bez(myix)(9:9).eq.'2' ) then
           nsig = nsig_tctv2
        else if(bez(myix)(8:8).eq.'5' .or. bez(myix)(9:9).eq.'5' ) then
           nsig = nsig_tctv5
        else if(bez(myix)(8:8).eq.'8' .or. bez(myix)(9:9).eq.'8' ) then
           nsig = nsig_tctv8
        end if
      else if(bez(myix)(1:3).eq.'TDI' .or. bez(myix)(1:3).eq.'tdi') then
        nsig = nsig_tdi
      else if(bez(myix)(1:4).eq.'TCLP' .or. bez(myix)(1:4).eq.'tclp' .or.bez(myix)(1:4).eq.'TCL.' .or.bez(myix)(1:4).eq.'tcl.'.or. &
 &            bez(myix)(1:4).eq.'TCLX' .or. bez(myix)(1:4).eq.'tclx') then
        nsig = nsig_tclp
      else if(bez(myix)(1:4).eq.'TCLI' .or. bez(myix)(1:4).eq.'tcli') then
         nsig = nsig_tcli
      else if(bez(myix)(1:4).eq.'TCXR' .or. bez(myix)(1:4).eq.'tcxr') then
        nsig = nsig_tcxrp
      !     TW 04/2008 ---- start adding TCRYO
      else if(bez(myix)(1:5).eq.'TCRYO'.or.bez(myix)(1:5).eq.'tcryo'.or.bez(myix)(1:5).eq.'TCLD.'.or.bez(myix)(1:5).eq.'tcld.') then
        nsig = nsig_tcryo
      !     TW 04/2008 ---- end adding TCRYO
      else if(bez(myix)(1:3).eq.'COL' .or. bez(myix)(1:3).eq.'col') then
        if(bez(myix)(1:4).eq.'COLM'.or.bez(myix)(1:4).eq.'colm'.or.bez(myix)(1:5).eq.'COLH0'.or.bez(myix)(1:5).eq.'colh0') then
          nsig = nsig_tcth1
        else if(bez(myix)(1:5).eq.'COLV0' .or. bez(myix)(1:5).eq.'colv0') then
          nsig = nsig_tcth2
        else if(bez(myix)(1:5).eq.'COLH1' .or. bez(myix)(1:5).eq.'colh1') then
      !     JUNE2005   HERE WE USE NSIG_TCTH2 AS THE OPENING IN THE VERTICAL
      !     JUNE2005   PLANE FOR THE PRIMARY COLLIMATOR OF RHIC; NSIG_TCTH5 STANDS
      !     JUNE2005   FOR THE OPENING OF THE FIRST SECONDARY COLLIMATOR OF RHIC
          nsig = nsig_tcth5
        else if(bez(myix)(1:5).eq.'COLV1' .or. bez(myix)(1:5).eq.'colv1') then
          nsig = nsig_tcth8
        else if(bez(myix)(1:5).eq.'COLH2' .or. bez(myix)(1:5).eq.'colh2') then
          nsig = nsig_tctv1
        end if
!     JUNE2005   END OF DEDICATED TREATMENT OF RHIC OPENINGS
      else
        write(lout,*) "WARNING: Problem detected while writing twisslike.out' and 'sigmasettings.out': Collimator name '", &
 &                    trim(adjustl(bez(myix))), "' was not recognized!"
        write(lout,*) " ->Setting nsig=1000.0."
        nsig = c1e3
      end if

      do i = 1, db_ncoll
! start searching minimum gap
        if((db_name1(i)(1:max_name_len).eq.bez(myix)(1:max_name_len)).or. &
           (db_name2(i)(1:max_name_len).eq.bez(myix)(1:max_name_len))) then
          if( db_length(i) .gt. zero ) then
            nsig_err = nsig + gap_rms_error(i)

! jaw 1 on positive side x-axis
            gap_h1 = nsig_err - sin_mb(db_tilt(i,1))*db_length(i)/2
            gap_h2 = nsig_err + sin_mb(db_tilt(i,1))*db_length(i)/2

! jaw 2 on negative side of x-axis (see change of sign comapred
! to above code lines, alos have a look to setting of tilt angle)
            gap_h3 = nsig_err + sin_mb(db_tilt(i,2))*db_length(i)/2
            gap_h4 = nsig_err - sin_mb(db_tilt(i,2))*db_length(i)/2

! find minumum halfgap
! --- searching for smallest halfgap
!! ---scaling for beta beat needed?
!                        if (do_nominal) then
!                           bx_dist = db_bx(icoll) * scale_bx / scale_bx0
!                           by_dist = db_by(icoll) * scale_by / scale_by0
!                        else
!                           bx_dist = tbetax(j) * scale_bx / scale_bx0
!                           by_dist = tbetay(j) * scale_by / scale_by0
!                        endif
            if (do_nominal) then
              bx_dist = db_bx(icoll)
              by_dist = db_by(icoll)
            else
              bx_dist = tbetax(j)
              by_dist = tbetay(j)
            end if

            sig_offset = db_offset(i)/(sqrt(bx_dist**2 * cos_mb(db_rotation(i))**2 + by_dist**2 * sin_mb(db_rotation(i))**2 ))
            write(twisslike_unit,*) bez(myix),tbetax(j),tbetay(j), torbx(j),torby(j), nsig, gap_rms_error(i)
            write(sigmasettings_unit,*) bez(myix), gap_h1, gap_h2, gap_h3, gap_h4, sig_offset, db_offset(i), nsig, gap_rms_error(i)

            if((gap_h1 + sig_offset) .le. mingap) then
              mingap = gap_h1 + sig_offset
              coll_mingap_id = i
              coll_mingap1 = db_name1(i)
              coll_mingap2 = db_name2(i)
            else if((gap_h2 + sig_offset) .le. mingap) then
              mingap = gap_h2 + sig_offset
              coll_mingap_id = i
              coll_mingap1 = db_name1(i)
              coll_mingap2 = db_name2(i)
            else if((gap_h3 - sig_offset) .le. mingap) then
              mingap = gap_h3 - sig_offset
              coll_mingap_id = i
              coll_mingap1 = db_name1(i)
              coll_mingap2 = db_name2(i)
            else if((gap_h4 - sig_offset) .le. mingap) then
              mingap = gap_h4 - sig_offset
              coll_mingap_id = i
              coll_mingap1 = db_name1(i)
              coll_mingap2 = db_name2(i)
            end if
          end if
        end if
      end do !do i = 1, db_ncoll

! could be done more elegant the above code to search the minimum gap
! and should also consider the jaw tilt
    end if
  end do !do j=1,iu

  write(twisslike_unit,*) coll_mingap_id, coll_mingap1, coll_mingap2,  mingap
  write(twisslike_unit,*) 'INFO> IPENCIL initial ', ipencil

! if pencil beam is used and on collimator with smallest gap the
! distribution should be generated, set ipencil to coll_mingap_id
  if (ipencil.gt.0 .and. do_mingap) then
    ipencil = coll_mingap_id
  end if

  write(twisslike_unit,*) 'INFO> IPENCIL new (if do_mingap) ', ipencil
  write(sigmasettings_unit,*) coll_mingap_id, coll_mingap1, coll_mingap2,  mingap

! if pencil beam is used and on collimator with smallest gap the
! distribution should be generated, set ipencil to coll_mingap_id
  write(sigmasettings_unit,*) 'INFO> IPENCIL new (if do_mingap) ',ipencil
  write(sigmasettings_unit,*) 'INFO> rnd_seed is (before reinit)',rnd_seed

  close(twisslike_unit)
  close(sigmasettings_unit)

!****** re-intialize random generator with rnd_seed
!       reinit with initial value used in first call
  rnd_lux = 3
  rnd_k1  = 0
  rnd_k2  = 0
  call rluxgo(rnd_lux, rnd_seed, rnd_k2, rnd_k2)
!  call recuin(rnd_seed, 0)
! TW - 01/2007

!GRD INITIALIZE LOCAL ADDITIVE PARAMETERS, I.E. THE ONE WE DON'T WANT
!GRD TO KEEP OVER EACH LOOP
  do j=1,napx
    tertiary(j)=0
    secondary(j)=0
    other(j)=0
    scatterhit(j)=0
    nabs_type(j) = 0
  end do

  do k = 1, numeff
    neff(k)  = zero
    neffx(k) = zero
    neffy(k) = zero

   do j = 1, numeffdpop
     neff2d(k,j) = zero
   end do
  end do

  do k = 1, numeffdpop
    neffdpop(k)  = zero
    npartdpop(k) = 0
  end do

  do j=1,max_ncoll
    cn_impact(j)   = 0
    cn_absorbed(j) = 0
    csum(j)   = zero
    csqsum(j) = zero
  end do

!++ End of first call stuff (end of first run)
  end if

!GRD NOW WE CAN BEGIN THE LOOPS
end subroutine collimate_start_sample

!>
!! collimate_start_collimator()
!! This routine is called each time we hit a collimator
!<
subroutine collimate_start_collimator(stracki)

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom
!+ca dbthin6d

  real(kind=fPrec) c5m4,stracki

#ifdef FAST
  c5m4=5.0e-4_fPrec
#endif

  if(bez(myix)(1:3).eq.'TCP' .or. bez(myix)(1:3).eq.'tcp') then
    if(bez(myix)(7:9).eq.'3.B' .or. bez(myix)(7:9).eq.'3.b') then
      nsig = nsig_tcp3
    else
      nsig = nsig_tcp7
    end if

  else if(bez(myix)(1:4).eq.'TCSG' .or.  bez(myix)(1:4).eq.'tcsg') then
    if(bez(myix)(8:10).eq.'3.B'.or.bez(myix)(8:10).eq.'3.b'.or.bez(myix)(9:11).eq.'3.B'.or.bez(myix)(9:11).eq.'3.b') then
      nsig = nsig_tcsg3
    else
      nsig = nsig_tcsg7
    end if
    if((bez(myix)(5:6).eq.'.4'.and.bez(myix)(8:9).eq.'6.')) then
      nsig = nsig_tcstcdq
    end if
  else if(bez(myix)(1:4).eq.'TCSP' .or. bez(myix)(1:4).eq.'tcsp') then
    if(bez(myix)(9:11).eq.'6.B'.or. bez(myix)(9:11).eq.'6.b') then
      nsig = nsig_tcstcdq
    end if
  else if(bez(myix)(1:4).eq.'TCSM' .or. bez(myix)(1:4).eq.'tcsm') then
    if(bez(myix)(8:10).eq.'3.B' .or. bez(myix)(8:10).eq.'3.b' .or. bez(myix)(9:11).eq.'3.B' .or. bez(myix)(9:11).eq.'3.b') then
      nsig = nsig_tcsm3
    else
      nsig = nsig_tcsm7
    end if
  else if(bez(myix)(1:4).eq.'TCLA' .or. bez(myix)(1:4).eq.'tcla') then
    if(bez(myix)(9:11).eq.'7.B' .or. bez(myix)(9:11).eq.'7.b') then
      nsig = nsig_tcla7
    else
      nsig = nsig_tcla3
    endif
  else if(bez(myix)(1:4).eq.'TCDQ' .or. bez(myix)(1:4).eq.'tcdq') then
    nsig = nsig_tcdq
! YIL11: Checking only the IR value for TCT's..
  else if(bez(myix)(1:4).eq.'TCTH' .or. bez(myix)(1:4).eq.'tcth' .or. bez(myix)(1:5).eq.'TCTPH' .or. bez(myix)(1:5).eq.'tctph') then
    if(bez(myix)(8:8).eq.'1' .or. bez(myix)(9:9).eq.'1' ) then
      nsig = nsig_tcth1
    else if(bez(myix)(8:8).eq.'2' .or. bez(myix)(9:9).eq.'2' ) then
      nsig = nsig_tcth2
    else if(bez(myix)(8:8).eq.'5'.or. bez(myix)(9:9).eq.'5' ) then
      nsig = nsig_tcth5
    else if(bez(myix)(8:8).eq.'8' .or. bez(myix)(9:9).eq.'8' ) then
      nsig = nsig_tcth8
    end if
  else if(bez(myix)(1:4).eq.'TCTV' .or.bez(myix)(1:4).eq.'tctv'.or.bez(myix)(1:5).eq.'TCTPV' .or.bez(myix)(1:5).eq.'tctpv' ) then
    if(bez(myix)(8:8).eq.'1' .or. bez(myix)(9:9).eq.'1' ) then
       nsig = nsig_tctv1
    else if(bez(myix)(8:8).eq.'2' .or. bez(myix)(9:9).eq.'2' ) then
       nsig = nsig_tctv2
    else if(bez(myix)(8:8).eq.'5' .or. bez(myix)(9:9).eq.'5' ) then
       nsig = nsig_tctv5
    else if(bez(myix)(8:8).eq.'8' .or. bez(myix)(9:9).eq.'8' ) then
       nsig = nsig_tctv8
    end if
  else if(bez(myix)(1:3).eq.'TDI' .or. bez(myix)(1:3).eq.'tdi') then
    nsig = nsig_tdi
  else if(bez(myix)(1:4).eq.'TCLP' .or.bez(myix)(1:4).eq.'tclp'.or.bez(myix)(1:4).eq.'TCL.'.or.bez(myix)(1:4).eq.'tcl.'.or. &
&         bez(myix)(1:4).eq.'TCLX' .or.bez(myix)(1:4).eq.'tclx') then
    nsig = nsig_tclp
  else if(bez(myix)(1:4).eq.'TCLI' .or. bez(myix)(1:4).eq.'tcli') then
    nsig = nsig_tcli
  else if(bez(myix)(1:4).eq.'TCXR' .or. bez(myix)(1:4).eq.'tcxr') then
    nsig = nsig_tcxrp
  else if(bez(myix)(1:5).eq.'TCRYO'.or.bez(myix)(1:5).eq.'tcryo'.or.bez(myix)(1:5).eq.'TCLD.' .or. bez(myix)(1:5).eq.'tcld.') then
    nsig = nsig_tcryo
  else if(bez(myix)(1:3).eq.'COL' .or. bez(myix)(1:3).eq.'col') then
    if(bez(myix)(1:4).eq.'COLM' .or. bez(myix)(1:4).eq.'colm' .or. bez(myix)(1:5).eq.'COLH0' .or. bez(myix)(1:5).eq.'colh0') then
      nsig = nsig_tcth1
    elseif(bez(myix)(1:5).eq.'COLV0' .or. bez(myix)(1:5).eq.'colv0') then
      nsig = nsig_tcth2
    else if(bez(myix)(1:5).eq.'COLH1' .or. bez(myix)(1:5).eq.'colh1') then
!     JUNE2005   HERE WE USE NSIG_TCTH2 AS THE OPENING IN THE VERTICAL
!     JUNE2005   PLANE FOR THE PRIMARY COLLIMATOR OF RHIC; NSIG_TCTH5 STANDS
!     JUNE2005   FOR THE OPENING OF THE FIRST SECONDARY COLLIMATOR OF RHIC
      nsig = nsig_tcth5
    else if(bez(myix)(1:5).eq.'COLV1' .or. bez(myix)(1:5).eq.'colv1') then
      nsig = nsig_tcth8
    else if(bez(myix)(1:5).eq.'COLH2' .or. bez(myix)(1:5).eq.'colh2') then
      nsig = nsig_tctv1
    end if
  else
    if(firstrun.and.iturn.eq.1) then
      write(lout,*) "WARNING: When setting opening for the collimator named '" // trim(adjustl(bez(myix))) // &
   &  "' from fort.3, the name was not recognized."
      write(lout,*) " -> Setting nsig=1000.0."
    end if
  nsig=c1e3
!JUNE2005   END OF DEDICATED TREATMENT OF RHIC OPENINGS
  end if

!++  Write trajectory for any selected particle
  c_length = zero

! SR, 23-11-2005: To avoid binary entries in 'amplitude.dat'
  if( firstrun ) then
    if(rselect.gt.0 .and. rselect.lt.65) then
      do j = 1, napx
        xj  = (xv(1,j)-torbx(ie))/c1e3
        xpj = (yv(1,j)-torbxp(ie))/c1e3
        yj  = (xv(2,j)-torby(ie))/c1e3
        ypj = (yv(2,j)-torbyp(ie))/c1e3
        pj  = ejv(j)/c1e3

        if(iturn.eq.1.and.j.eq.1) then
          sum_ax(ie)=zero
          sum_ay(ie)=zero
        end if

!-- DRIFT PART
        if(stracki.eq.0.) then
          if(iexact.eq.0) then
            xj  = xj + half*c_length*xpj
            yj  = yj + half*c_length*ypj
          else
            zpj = sqrt(one-xpj**2-ypj**2)
            xj  = xj + half*c_length*(xpj/zpj)
            yj  = yj + half*c_length*(ypj/zpj)
          end if
        end if

        gammax = (one + talphax(ie)**2)/tbetax(ie)
        gammay = (one + talphay(ie)**2)/tbetay(ie)

        if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
          nspx = sqrt(abs( gammax*(xj)**2 + two*talphax(ie)*xj*xpj +tbetax(ie)*xpj**2 )/myemitx0_collgap)
          nspy = sqrt(abs( gammay*(yj)**2 + two*talphay(ie)*yj*ypj +tbetay(ie)*ypj**2 )/myemity0_collgap)
          sum_ax(ie)   = sum_ax(ie) + nspx
          sqsum_ax(ie) = sqsum_ax(ie) + nspx**2
          sum_ay(ie)   = sum_ay(ie) + nspy
          sqsum_ay(ie) = sqsum_ay(ie) + nspy**2
          nampl(ie)    = nampl(ie) + 1
        else
          nspx = zero
          nspy = zero
        end if

          sampl(ie)    = totals
          ename(ie)    = bez(myix)(1:max_name_len)
      end do !do j = 1, napx
    end if !if(rselect.gt.0 .and. rselect.lt.65) then
  end if !if( firstrun ) then

!GRD HERE WE LOOK FOR ADEQUATE DATABASE INFORMATION
  found = .false.

!     SR, 01-09-2005: to set found = .TRUE., add the condition L>0!!
  do j = 1, db_ncoll
    if((db_name1(j)(1:max_name_len).eq.bez(myix)(1:max_name_len)) .or. &
       (db_name2(j)(1:max_name_len).eq.bez(myix)(1:max_name_len))) then
      if( db_length(j) .gt. zero ) then
        found = .true.
        icoll = j
        if(firstrun) then
          coll_found(j) = .TRUE.
          write(CollPositions_unit,*) j, db_name1(j), totals
        end if
      end if
    end if
  end do

  if(.not. found .and. firstrun .and. iturn.eq.1) then
    write(lout,*) 'WARN>  Collimator not found in colldb: ', bez(myix)
  end if

end subroutine collimate_start_collimator

!>
!! collimate_do_collimator()
!! This routine is calls the actual scattering functions
!<
subroutine collimate_do_collimator(stracki)

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom
!+ca dbthin6d

  real(kind=fPrec) c5m4,stracki

#ifdef G4COLLIMAT
  integer g4_lostc
  integer :: part_hit_flag = 0
  integer :: part_abs_flag = 0
  real(kind=fPrec) x_tmp,y_tmp,xp_tmp,yp_tmp
#endif

#ifdef FAST
  c5m4=5.0e-4_fPrec
#endif

!-----------------------------------------------------------------------
!GRD NEW COLLIMATION PARAMETERS
!-----------------------------------------------------------------------
!++  Get the aperture from the beta functions and emittance
!++  A simple estimate of beta beating can be included that
!++  has twice the betatron phase advance
  if(.not. do_nsig) nsig = db_nsig(icoll)

  scale_bx = (one + xbeat*sin_mb(four*pi*mux(ie)+xbeatphase) )
  scale_by = (one + ybeat*sin_mb(four*pi*muy(ie)+ybeatphase) )

  if(firstcoll) then
    scale_bx0 = scale_bx
    scale_by0 = scale_by
    firstcoll = .false.
  end if
!-------------------------------------------------------------------
!++  Assign nominal OR design beta functions for later
  if(do_nominal) then
    bx_dist = db_bx(icoll) * scale_bx / scale_bx0
    by_dist = db_by(icoll) * scale_by / scale_by0
  else
    bx_dist = tbetax(ie) * scale_bx / scale_bx0
    by_dist = tbetay(ie) * scale_by / scale_by0
  end if

!++  Write beam ellipse at selected collimator
! ---- changed name_sel(1:11) name_sel(1:12) to be checked if feasible!!
  if (((db_name1(icoll).eq.name_sel(1:max_name_len)) .or.&
       (db_name2(icoll).eq.name_sel(1:max_name_len))) .and. dowrite_dist) then
!          if (firstrun .and.                                            &
!     &         ((db_name1(icoll).eq.name_sel(1:11))                     &
!     &         .or.(db_name2(icoll).eq.name_sel(1:11)))                 &
!     &         .and. dowrite_dist) then
! --- get halo on each turn
!     &.and. iturn.eq.1 .and. dowrite_dist) then
! --- put open and close at the pso. where it is done for the
! --- other files belonging to dowrite_impact flag !(may not a good loc.)
!            open(unit=45, file='coll_ellipse.dat')
!            write(45,'(a)')                                             &
!     &'#  1=x 2=y 3=xp 4=yp 5=E 6=s'
    do j = 1, napx
      write(coll_ellipse_unit,'(1X,I8,6(1X,E15.7),3(1X,I4,1X,I4))') ipart(j),xv(1,j), xv(2,j), yv(1,j), yv(2,j), &
     &        ejv(j), mys(j),iturn,secondary(j)+tertiary(j)+other(j)+scatterhit(j),nabs_type(j)
    end do
  end if

!-------------------------------------------------------------------
!++  Output to temporary database and screen
  if(iturn.eq.1.and.firstrun) then
    write(collimator_temp_db_unit,*) '# '
    write(collimator_temp_db_unit,*) db_name1(icoll)!(1:11)
    write(collimator_temp_db_unit,*) db_material(icoll)
    write(collimator_temp_db_unit,*) db_length(icoll)
    write(collimator_temp_db_unit,*) db_rotation(icoll)
    write(collimator_temp_db_unit,*) db_offset(icoll)
    write(collimator_temp_db_unit,*) tbetax(ie)
    write(collimator_temp_db_unit,*) tbetay(ie)

    write(outlun,*) ' '
    write(outlun,*)   'Collimator information: '
    write(outlun,*) ' '
    write(outlun,*) 'Name:                ', db_name1(icoll)!(1:11)
    write(outlun,*) 'Material:            ', db_material(icoll)
    write(outlun,*) 'Length [m]:          ', db_length(icoll)
    write(outlun,*) 'Rotation [rad]:      ', db_rotation(icoll)
    write(outlun,*) 'Offset [m]:          ', db_offset(icoll)
    write(outlun,*) 'Design beta x [m]:   ', db_bx(icoll)
    write(outlun,*) 'Design beta y [m]:   ', db_by(icoll)
    write(outlun,*) 'Optics beta x [m]:   ', tbetax(ie)
    write(outlun,*) 'Optics beta y [m]:   ', tbetay(ie)
  end if

!-------------------------------------------------------------------
!++  Calculate aperture of collimator
!JUNE2005   HERE ONE HAS TO HAVE PARTICULAR TREATMENT OF THE OPENING OF
!JUNE2005   THE PRIMARY COLLIMATOR OF RHIC
  if(db_name1(icoll)(1:4).ne.'COLM') then
    nsig = nsig + gap_rms_error(icoll)
    xmax = nsig*sqrt(bx_dist*myemitx0_collgap)
    ymax = nsig*sqrt(by_dist*myemity0_collgap)
    xmax_pencil = (nsig+pencil_offset)*sqrt(bx_dist*myemitx0_collgap)
    ymax_pencil = (nsig+pencil_offset)*sqrt(by_dist*myemity0_collgap)
    xmax_nom   = db_nsig(icoll)*sqrt(db_bx(icoll)*myemitx0_collgap)
    ymax_nom   = db_nsig(icoll)*sqrt(db_by(icoll)*myemity0_collgap)
    c_rotation = db_rotation(icoll)
    c_length   = db_length(icoll)
    c_material = db_material(icoll)
    c_offset   = db_offset(icoll)
    c_tilt(1)  = db_tilt(icoll,1)
    c_tilt(2)  = db_tilt(icoll,2)

    calc_aperture   = sqrt( xmax**2 * cos_mb(c_rotation)**2 + ymax**2 * sin_mb(c_rotation)**2 )
    nom_aperture    = sqrt( xmax_nom**2 * cos_mb(c_rotation)**2 + ymax_nom**2 * sin_mb(c_rotation)**2 )
    pencil_aperture = sqrt( xmax_pencil**2 * cos_mb(c_rotation)**2+ ymax_pencil**2 * sin_mb(c_rotation)**2 )

!++  Get x and y offsets at collimator center point
    x_pencil(icoll) = xmax_pencil * (cos_mb(c_rotation))
    y_pencil(icoll) = ymax_pencil * (sin_mb(c_rotation))

!++  Get corresponding beam angles (uses xp_max)
    xp_pencil(icoll) = -one * sqrt(myemitx0_collgap/tbetax(ie))*talphax(ie)* xmax / sqrt(myemitx0_collgap*tbetax(ie))
    yp_pencil(icoll) = -one * sqrt(myemity0_collgap/tbetay(ie))*talphay(ie)* ymax / sqrt(myemity0_collgap*tbetay(ie))

! that the way xp is calculated for makedis subroutines !!!!
!        if (rndm4().gt.0.5) then
!          myxp(j)  = sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-        &
!     &myalphax*myx(j)/mybetax
!        else
!          myxp(j)  = -1*sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-     &
!     &myalphax*myx(j)/mybetax
!        endif
!            xp_pencil(icoll) =                                          &
!     &           sqrt(sqrt((myemitx0/tbetax(ie)                         &
!     &           -x_pencil(icoll)**2/tbetax(ie)**2)**2))                &
!     &           -talphax(ie)*x_pencil(icoll)/tbetax(ie)
!            write(*,*) " ************************************ "
!            write(*,*) myemitx0/tbetax(ie)                              &
!     &           -x_pencil(icoll)**2/tbetax(ie)**2
!            write(*,*)sqrt(sqrt((myemitx0/tbetax(ie)                    &
!     &           -x_pencil(icoll)**2/tbetax(ie)**2)**2))
!            write(*,*) -talphax(ie)*x_pencil(icoll)/tbetax(ie)
!            write(*,*) sqrt(myemitx0/tbetax(ie))*talphax(ie)            &
!     &                   * x_pencil(icoll) / sqrt(myemitx0*tbetax(ie))
!            write(*,*)  sqrt(sqrt((myemitx0/tbetax(ie)                  &
!     &           -x_pencil(icoll)**2/tbetax(ie)**2)**2))                &
!     &           -talphax(ie)*x_pencil(icoll)/tbetax(ie)
!            write(*,*) xp_pencil(icoll)
!            write(*,*) " ************************************ "
!
!            yp_pencil(icoll) =                                          &
!     &           sqrt(sqrt((myemity0/tbetay(ie)                         &
!     &           -y_pencil(icoll)**2/tbetay(ie)**2)**2))                &
!     &           -talphay(ie)*y_pencil(icoll)/tbetay(ie)
!!
    xp_pencil0 = xp_pencil(icoll)
    yp_pencil0 = yp_pencil(icoll)

    pencil_dx(icoll) = sqrt(xmax_pencil**2 * cos_mb(c_rotation)**2 + ymax_pencil**2 * sin_mb(c_rotation)**2)-calc_aperture

!++ TW -- tilt for of jaw for pencil beam
!++ as in Ralphs orig routine, but not in collimate subroutine itself
!            nprim = 3
!            if ( (icoll.eq.ipencil) &
!     &           icoll.le.nprim .and. (j.ge.(icoll-1)*nev/nprim)        &
!     &           .and. (j.le.(icoll)*nev/nprim))) then
! this is done for every bunch (64 particle bucket)
! important: Sixtrack calculates in "mm" and collimate2 in "m"
! therefore 1E-3 is used to

! RB: added condition that pencil_distr.ne.3 in order to do the tilt
    if((icoll.eq.ipencil).and.(iturn.eq.1).and. (pencil_distr.ne.3)) then
!!               write(*,*) " ************************************** "
!!               write(*,*) " * INFO> seting tilt for pencil beam  * "
!!               write(*,*) " ************************************** "

!! respects if the tilt symmetric or not, for systilt_antiymm c_tilt is
!! -systilt + rmstilt otherwise +systilt + rmstilt
!!               if (systilt_antisymm) then
!! to align the jaw/pencil to the beam always use the minus regardless which
!! orientation of the jaws was used (symmetric/antisymmetric)
      c_tilt(1) = c_tilt(1) +    (xp_pencil0*cos_mb(c_rotation) + sin_mb(c_rotation)*yp_pencil0)
      c_tilt(2) = c_tilt(2) -one*(xp_pencil0*cos_mb(c_rotation) + sin_mb(c_rotation)*yp_pencil0)
      write(lout,*) "INFO> Changed tilt1  ICOLL  to  ANGLE  ", icoll, c_tilt(1)
      write(lout,*) "INFO> Changed tilt2  ICOLL  to  ANGLE  ", icoll, c_tilt(2)
    end if
!++ TW -- tilt angle changed (added to genetated on if spec. in fort.3)

!JUNE2005   HERE IS THE SPECIAL TREATMENT...
  else if(db_name1(icoll)(1:4).eq.'COLM') then
    xmax = nsig_tcth1*sqrt(bx_dist*myemitx0_collgap)
    ymax = nsig_tcth2*sqrt(by_dist*myemity0_collgap)

    c_rotation = db_rotation(icoll)
    c_length   = db_length(icoll)
    c_material = db_material(icoll)
    c_offset   = db_offset(icoll)
    c_tilt(1)  = db_tilt(icoll,1)
    c_tilt(2)  = db_tilt(icoll,2)
    calc_aperture = xmax
    nom_aperture = ymax
  end if

!-------------------------------------------------------------------
!++  Further output
  if(firstrun) then
    if(iturn.eq.1) then
      write(outlun,*) xp_pencil(icoll), yp_pencil(icoll), pencil_dx(icoll)
      write(outlun,'(a,i4)') 'Collimator number:   ', icoll
      write(outlun,*) 'Beam size x [m]:     ', sqrt(tbetax(ie)*myemitx0_collgap), "(from collgap emittance)"
      write(outlun,*) 'Beam size y [m]:     ', sqrt(tbetay(ie)*myemity0_collgap), "(from collgap emittance)"
      write(outlun,*) 'Divergence x [urad]:     ', c1e6*xp_pencil(icoll)
      write(outlun,*) 'Divergence y [urad]:     ', c1e6*yp_pencil(icoll)
      write(outlun,*) 'Aperture (nom) [m]:  ', nom_aperture
      write(outlun,*) 'Aperture (cal) [m]:  ', calc_aperture
      write(outlun,*) 'Collimator halfgap [sigma]:  ', nsig
      write(outlun,*) 'RMS error on halfgap [sigma]:  ', gap_rms_error(icoll)
      write(outlun,*) ' '

      write(collgaps_unit,'(i10,1x,a,4(1x,e19.10),1x,a,6(1x,e13.5))')   &
     &icoll,db_name1(icoll)(1:12),                                      &
     &db_rotation(icoll),                                               &
     &tbetax(ie), tbetay(ie), calc_aperture,                            &
     &db_material(icoll),                                               &
     &db_length(icoll),                                                 &
     &sqrt(tbetax(ie)*myemitx0_collgap),                                &
     &sqrt(tbetay(ie)*myemity0_collgap),                                &
     &db_tilt(icoll,1),                                                 &
     &db_tilt(icoll,2),                                                 &
     &nsig

! coll settings file
      if(n_slices.le.1) then
        write(collsettings_unit,'(a,1x,i10,5(1x,e13.5),1x,a)')          &
     &db_name1(icoll)(1:12),                                            &
     &n_slices,calc_aperture,                                           &
     &db_offset(icoll),                                                 &
     &db_tilt(icoll,1),                                                 &
     &db_tilt(icoll,2),                                                 &
     &db_length(icoll),                                                 &
     &db_material(icoll)
      end if !if(n_slices.le.1) then
    end if !if(iturn.eq.1) then
  end if !if(firstrun) then

!++  Assign aperture which we define as the FULL width (factor 2)!!!
!JUNE2005 AGAIN, SOME SPECIFIC STUFF FOR RHIC
  if(db_name1(icoll)(1:4).eq.'COLM') then
    c_aperture = two*calc_aperture
    nom_aperture = two*nom_aperture
  else if(db_name1(icoll)(1:4).ne.'COLM') then
    c_aperture = two*calc_aperture
  end if

  c_aperture = two*calc_aperture
!          IF(IPENCIL.GT.zero) THEN
!          C_APERTURE = 2.*pencil_aperture

  if(firstrun.and.iturn.eq.1.and.icoll.eq.7) then
    call funit_requestUnit('distsec', distsec_unit)
    open(unit=distsec_unit,file='distsec') !was 99
    do j=1,napx
      write(distsec_unit,'(4(1X,E15.7))') xv(1,j),yv(1,j),xv(2,j),yv(2,j)
    end do
    close(distsec_unit)
  end if

! RB: addition matched halo sampled directly on the TCP using pencil beam flag
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if ((iturn.eq.1).and.(ipencil.eq.icoll).and.(pencil_distr.eq.3)) then

!     create distribution where the normalized distance between jaw and beam is the smallest - this is where particles will first impact:
!     without imperfections, it is:
!              -- at the face of the collimator for the case of beta'<0 (POSITIVE alpha - beam converging) and
!              -- at the exit of the collimator for the case of beta'>0 (NEGATIVE alpha beam diverging)

!     with imperfections: include errors on gap, tilt and offset. We have to calculate the normalized distance to each corner separately!

!     First: calculate optical parameters at start and end of collimator (half a collimator length upstream and downstream of present s-position)
!     Assuming a purely vertical or horizontal halo - need to add more conditions for other cases!

!     Using standard twiss transfer matrix for a drift : ( new_halo_model_checks.nb )
!     at start of collimator:
    ldrift = -c_length / two !Assign the drift length over which the optics functions are propagated
    betax1 = tbetax(ie) - two*ldrift*talphax(ie) + (ldrift**2 * (one+talphax(ie)**2))/tbetax(ie)
    betay1 = tbetay(ie) - two*ldrift*talphay(ie) + (ldrift**2 * (one+talphay(ie)**2))/tbetay(ie)

    alphax1 = talphax(ie) - (ldrift*(1+talphax(ie)**2))/tbetax(ie)
    alphay1 = talphay(ie) - (ldrift*(1+talphay(ie)**2))/tbetay(ie)

!   at end of collimator:
    ldrift = c_length / two
    betax2 = tbetax(ie) - two*ldrift*talphax(ie) + (ldrift**2 * (one+talphax(ie)**2))/tbetax(ie)
    betay2 = tbetay(ie) - two*ldrift*talphay(ie) + (ldrift**2 * (one+talphay(ie)**2))/tbetay(ie)

    alphax2 = talphax(ie) - (ldrift*(1+talphax(ie)**2))/tbetax(ie)
    alphay2 = talphay(ie) - (ldrift*(1+talphay(ie)**2))/tbetay(ie)

!   calculate beam size at start and end of collimator. account for collimation plane
    if((mynex.gt.0).and.(myney.eq.zero)) then  ! horizontal halo
      beamsize1 = sqrt(betax1 * myemitx0_collgap)
      beamsize2 = sqrt(betax2 * myemitx0_collgap)
    else if((mynex.eq.0).and.(myney.gt.zero)) then   ! vertical halo
      beamsize1 = sqrt(betay1 * myemity0_collgap)
      beamsize2 = sqrt(betay2 * myemity0_collgap)
    else
      write(lout,*) "attempting to use a halo not purely in the horizontal or vertical plane with pencil_dist=3 - abort."
      call prror(-1)
    end if

!   calculate offset from tilt of positive and negative jaws, at start and end
!   remember: tilt angle is defined such that one corner stays at nominal position, the other corner is more open

!   jaw in positive x (or y):
    if(c_tilt(1).ge.0) then
      tiltOffsPos1 = zero
      tiltOffsPos2 = abs(sin_mb(c_tilt(1))) * c_length
    else
      tiltOffsPos1 = abs(sin_mb(c_tilt(1))) * c_length
      tiltOffsPos2 = zero
    end if

!   jaw in negative x (or y):
    if(c_tilt(2).ge.0) then
      tiltOffsNeg1 = abs(sin_mb(c_tilt(2))) * c_length
      tiltOffsNeg2 = zero
    else
      tiltOffsNeg1 = zero
      tiltOffsNeg2 = abs(sin_mb(c_tilt(2))) * c_length
    end if

!   calculate half distance from jaws to beam center (in units of beam sigma) at the beginning of the collimator, positive and neg jaws.
    Nap1pos=((c_aperture/two + c_offset) + tiltOffsPos1)/beamsize1
    Nap2pos=((c_aperture/two + c_offset) + tiltOffsPos2)/beamsize2
    Nap1neg=((c_aperture/two - c_offset) + tiltOffsNeg1)/beamsize1
    Nap2neg=((c_aperture/two - c_offset) + tiltOffsNeg2)/beamsize2

! debugging output - can be removed when not needed
!            write(7878,*) c_tilt(1),c_tilt(2),c_offset
!       write(7878,*) tiltOffsPos1,tiltOffsPos2,tiltOffsNeg1,tiltOffsNeg2
!            write(7878,*) Nap1pos,Nap2pos,Nap1neg,Nap2neg
!            write(7878,*) min(Nap1pos,Nap2pos,Nap1neg,Nap2neg)
!            write(7878,*) mynex * sqrt(tbetax(ie)/betax1)

!   Minimum normalized distance from jaw to beam center - this is the n_sigma at which the halo should be generated
    minAmpl = min(Nap1pos,Nap2pos,Nap1neg,Nap2neg)

!   Assign amplitudes in x and y for the halo generation function
    if((mynex.gt.0).and.(myney.eq.zero)) then ! horizontal halo
       mynex2 = minAmpl
    else if((mynex.eq.0).and.(myney.gt.zero)) then ! vertical halo
       myney2 = minAmpl
    end if               ! other cases taken care of above - in these cases, program has already stopped

!   assign optics parameters to use for the generation of the starting halo - at start or end of collimator
    if((minAmpl.eq.Nap1pos).or.(minAmpl.eq.Nap1neg)) then ! min normalized distance occurs at start of collimator
      mybetax=betax1
      mybetay=betay1
      myalphax=alphax1
      myalphay=alphay1
      ldrift = -c_length / two
    else               ! min normalized distance occurs at end of collimator
      mybetax=betax2
      mybetay=betay2
      myalphax=alphax2
      myalphay=alphay2
      ldrift = c_length / two
    end if

!    write(7878,*) napx,myalphax,myalphay,mybetax,mybetay,myemitx0_collgap,myemity0_collgap,myenom,mynex2,mdex,myney2,mdey

!   create new pencil beam distribution with spread at start or end of collimator at the minAmpl
!   note: if imperfections are active, equal amounts of particles are still generated on the two jaws.
!   but it might be then that only one jaw is hit on the first turn, thus only by half of the particles
!   the particle generated on the other side will then hit the same jaw several turns later, possibly smearing the impact parameter
!   This could possibly be improved in the future.
    call makedis_coll(napx,myalphax,myalphay, mybetax, mybetay, myemitx0_collgap, myemity0_collgap, &
 &                    myenom, mynex2, mdex, myney2, mdey, myx, myxp, myy, myyp, myp, mys)

    do j = 1, napx
      xv(1,j)  = c1e3*myx(j)  + torbx(ie)
      yv(1,j)  = c1e3*myxp(j) + torbxp(ie)
      xv(2,j)  = c1e3*myy(j)  + torby(ie)
      yv(2,j)  = c1e3*myyp(j) + torbyp(ie)
      sigmv(j) = mys(j)
      ejv(j)   = myp(j)

!      as main routine will track particles back half a collimator length (to start of jaw),
!      track them now forward (if generated at face) or backward (if generated at end)
!      1/2 collimator length to center of collimator (ldrift pos or neg)
       xv(1,j)  = xv(1,j) - ldrift*yv(1,j)
       xv(2,j)  = xv(2,j) - ldrift*yv(2,j)

!      write out distribution - generated either at the BEGINNING or END of the collimator
!       write(4997,'(6(1X,E15.7))') myx(j), myxp(j), myy(j), myyp(j), mys(j), myp(j)
    end do
  end if

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! end RB addition

!++  Copy particle data to 1-dim array and go back to meters
  do j = 1, napx
    rcx(j)  = (xv(1,j)-torbx(ie)) /c1e3
    rcxp(j) = (yv(1,j)-torbxp(ie))/c1e3
    rcy(j)  = (xv(2,j)-torby(ie)) /c1e3
    rcyp(j) = (yv(2,j)-torbyp(ie))/c1e3
    rcp(j)  = ejv(j)/c1e3
    rcs(j)  = zero
    part_hit_before_turn(j) = part_hit_turn(j)
    part_hit_before_pos(j)  = part_hit_pos(j)
    rcx0(j)  = rcx(j)
    rcxp0(j) = rcxp(j)
    rcy0(j)  = rcy(j)
    rcyp0(j) = rcyp(j)
    rcp0(j)  = rcp(j)
    ejf0v(j) = ejfv(j)

!++  For zero length element track back half collimator length
!  DRIFT PART
    if (stracki.eq.0.) then
      if(iexact.eq.0) then
        rcx(j)  = rcx(j) - half*c_length*rcxp(j)
        rcy(j)  = rcy(j) - half*c_length*rcyp(j)
      else
        zpj=sqrt(one-rcxp(j)**2-rcyp(j)**2)
        rcx(j) = rcx(j) - half*c_length*(rcxp(j)/zpj)
        rcy(j) = rcy(j) - half*c_length*(rcyp(j)/zpj)
      end if
    else
      write(lout,*) 'ERROR: Non-zero length collimator: ', db_name1(icoll), ' length = ', stracki
      call prror(-1)
    end if

    flukaname(j) = ipart(j)
  end do

!++  Do the collimation tracking
  enom_gev = myenom*c1m3

!++  Allow primaries to be one-sided, if requested
  if ((db_name1(icoll)(1:3).eq.'TCP' .or. db_name1(icoll)(1:3).eq.'COL') .and. do_oneside) then
    onesided = .true.
  else
    onesided = .false.
  end if

!GRD HERE IS THE MAJOR CHANGE TO THE CODE: IN ORDER TO TRACK PROPERLY THE
!GRD SPECIAL RHIC PRIMARY COLLIMATOR, IMPLEMENTATION OF A DEDICATED ROUTINE
  if(found) then
    if(db_name1(icoll)(1:4).eq.'COLM') then
      call collimaterhic(c_material,                                    &
     &              c_length, c_rotation,                               &
     &              c_aperture, nom_aperture,                           &
     &              c_offset, c_tilt,                                   &
     &              rcx, rcxp, rcy, rcyp,                               &
     &              rcp, rcs, napx, enom_gev,                           &
     &              part_hit_pos,part_hit_turn,                         &
     &              part_abs_pos,part_abs_turn,                         &
     &              part_impact, part_indiv, part_linteract,            &
     &              onesided,                                           &
!GRD let's also add the FLUKA possibility
     &              flukaname)
    else

!GRD-SR, 09-02-2006
!Force the treatment of the TCDQ equipment as a onsided collimator.
!Both for Beam 1 and Beam 2, the TCDQ is at positive x side.
!              if(db_name1(icoll)(1:4).eq.'TCDQ' ) onesided = .true.
! to treat all collimators onesided
! -> only for worst case TCDQ studies
      if(db_name1(icoll)(1:4).eq.'TCDQ') onesided = .true.
      if(db_name1(icoll)(1:5).eq.'TCXRP') onesided = .true.

!==> SLICE here is possible
!
!     SR, 29-08-2005: Slice the collimator jaws in 'n_slices' pieces
!     using two 4th-order polynomial fits. For each slices, the new
!     gaps and centre are calculates
!     It is assumed that the jaw point closer to the beam defines the
!     nominal aperture.
!
!     SR, 01-09-2005: new official version - input assigned through
!     the 'fort.3' file.
!               if (n_slices.gt.1d0 .and.                                &
!     &              totals.gt.smin_slices .and.                         &
!     &              totals.lt.smax_slices .and.                         &
!     &              db_name1(icoll)(1:4).eq.'TCSG' ) then
!                  if (firstrun) then
!                  write(*,*) 'INFOslice - Collimator ',
!     &              db_name1(icoll), ' sliced in ',n_slices,
!     &              ' pieces!'
!                  endif
!CB

      if(n_slices.gt.1d0 .and. totals.gt.smin_slices .and. totals.lt.smax_slices .and. &
 &      (db_name1(icoll)(1:4).eq.'TCSG' .or. db_name1(icoll)(1:3).eq.'TCP' .or. db_name1(icoll)(1:4).eq.'TCLA'.or. &
 &       db_name1(icoll)(1:3).eq.'TCT' .or. db_name1(icoll)(1:4).eq.'TCLI'.or. db_name1(icoll)(1:4).eq.'TCL.'.or.  &
!     RB: added slicing of TCRYO as well
 &       db_name1(icoll)(1:5).eq.'TCRYO')) then

        if(firstrun) then
          write(lout,*) 'INFO> slice - Collimator ', db_name1(icoll), ' sliced in ',n_slices, ' pieces !'
        end if

!!     In this preliminary try, all secondary collimators are sliced.
!!     Slice only collimators with finite length!!
!               if (db_name1(icoll)(1:4).eq.'TCSG' .and.
!     &              c_length.gt.0d0 ) then
!!     Slice the primaries, to have more statistics faster!
!!               if (db_name1(icoll)(1:3).eq.'TCP' .and.
!!     +              c_length.gt.0d0 ) then
!!
!!
!!     Calculate longitudinal positions of slices and corresponding heights
!!     and angles from the fit parameters.
!!     -> MY NOTATION: y1_sl: jaw at x > 0; y2_sl: jaw at x < 0;
!!     Note: here, take (n_slices+1) points in order to calculate the
!!           tilt angle of the last slice!!

!     CB:10-2007 deformation of the jaws scaled with length
        do jjj=1,n_slices+1
          x_sl(jjj) = (jjj-1) * c_length / real(n_slices,fPrec)

          y1_sl(jjj) = fit1_1 + fit1_2*x_sl(jjj) + fit1_3/c_length*(x_sl(jjj)**2) +           &
 &                           fit1_4*(x_sl(jjj)**3) + fit1_5*(x_sl(jjj)**4) + fit1_6*(x_sl(jjj)**5)

          y2_sl(jjj) = -one * (fit2_1 + fit2_2*x_sl(jjj) + fit2_3/c_length*(x_sl(jjj)**2) +   &
 &                           fit2_4*(x_sl(jjj)**3) + fit2_5*(x_sl(jjj)**4) + fit2_6*(x_sl(jjj)**5))
        end do

!       Apply the slicing scaling factors (ssf's):
!
!          do jjj=1,n_slices+1
!             y1_sl(jjj) = ssf1 * y1_sl(jjj)
!             y2_sl(jjj) = ssf2 * y2_sl(jjj)
!          enddo

!       CB:10-2007 coordinates rotated of the tilt
        do jjj=1,n_slices+1
          y1_sl(jjj) = ssf1 * y1_sl(jjj)
          y2_sl(jjj) = ssf2 * y2_sl(jjj)
! CB code
          x1_sl(jjj) = x_sl(jjj) *cos_mb(db_tilt(icoll,1))-y1_sl(jjj)*sin_mb(db_tilt(icoll,1))
          x2_sl(jjj) = x_sl(jjj) *cos_mb(db_tilt(icoll,2))-y2_sl(jjj)*sin_mb(db_tilt(icoll,2))
          y1_sl(jjj) = y1_sl(jjj)*cos_mb(db_tilt(icoll,1))+x_sl(jjj) *sin_mb(db_tilt(icoll,1))
          y2_sl(jjj) = y2_sl(jjj)*cos_mb(db_tilt(icoll,2))+x_sl(jjj) *sin_mb(db_tilt(icoll,2))
        end do

!       Sign of the angle defined differently for the two jaws!
        do jjj=1,n_slices
          angle1(jjj) = (( y1_sl(jjj+1) - y1_sl(jjj) ) / ( x1_sl(jjj+1)-x1_sl(jjj) ))
          angle2(jjj) = (( y2_sl(jjj+1) - y2_sl(jjj) ) / ( x2_sl(jjj+1)-x2_sl(jjj) ))
        end do

!       Sign of the angle defined differently for the two jaws!
!                    do jjj=1,n_slices
!                       angle1(jjj) = ( y1_sl(jjj+1) - y1_sl(jjj) ) /     &
!       &                    (c_length / dble(n_slices) )
!                       angle2(jjj) = ( y2_sl(jjj+1) - y2_sl(jjj) ) /     &
!       &                    (c_length / dble(n_slices) )
!                    enddo
!       For both jaws, look for the 'deepest' point (closest point to beam)
!       Then, shift the vectors such that this closest point defines
!       the nominal aperture
!       Index here must go up to (n_slices+1) in case the last point is the
!       closest (and also for the later calculation of 'a_tmp1' and 'a_tmp2')

!       SR, 01-09-2005: add the recentring flag, as given in 'fort.3' to
!       choose whether recentre the deepest point or not
        max_tmp = c1e6
        do jjj=1, n_slices+1
          if( y1_sl(jjj).lt.max_tmp ) then
            max_tmp = y1_sl(jjj)
          end if
        end do

        do jjj=1, n_slices+1
          y1_sl(jjj) = y1_sl(jjj) - (max_tmp * recenter1) + (half*c_aperture)
        end do

        max_tmp = -c1e6

        do jjj=1, n_slices+1
          if( y2_sl(jjj).gt.max_tmp ) then
            max_tmp = y2_sl(jjj)
          end if
        end do

        do jjj=1, n_slices+1
          y2_sl(jjj) = y2_sl(jjj) - (max_tmp * recenter2) - (half*c_aperture)
        end do

!!      Check the collimator jaw surfaces (beam frame, before taking into
!!      account the azimuthal angle of the collimator)
        if(firstrun) then
          write(lout,*) 'Slicing collimator ',db_name1(icoll)
           do jjj=1,n_slices
             write(lout,*) x_sl(jjj), y1_sl(jjj), y2_sl(jjj), angle1(jjj), angle2(jjj), db_tilt(icoll,1), db_tilt(icoll,2)
           end do
        end if
!
!!     Check the calculation of slice gap and centre
!                  if (firstrun) then
!                     write(*,*) 'Verify centre and gap!'
!                     do jjj=1,n_slices
!                        if ( angle1(jjj).gt.0d0 ) then
!                           a_tmp1 = y1_sl(jjj)
!                        else
!                           a_tmp1 = y1_sl(jjj+1)
!                        endif
!                        if ( angle2(jjj).lt.0d0 ) then
!                           a_tmp2 = y2_sl(jjj)
!                        else
!                           a_tmp2 = y2_sl(jjj+1)
!                        endif
!                        write(*,*) a_tmp1 - a_tmp2,
!     +                       0.5 * ( a_tmp1 + a_tmp2 )
!                     enddo
!                  endif
!
!       Now, loop over the number of slices and call collimate2 each time!
!       For each slice, the corresponding offset and angle are to be used.
        do jjj=1,n_slices

!         First calculate aperture and centre of the slice
!         Note that:
!         (1)due to our notation for the angle sign,
!         the rotation point of the slice (index j or j+1)
!         DEPENDS on the angle value!!
!         (2) New version of 'collimate2' is required: one must pass
!         the slice number in order the calculate correctly the 's'
!         coordinate in the impact files.

!         Here, 'a_tmp1' and 'a_tmp2' are, for each slice, the closest
!         corners to the beam
          if( angle1(jjj).gt.zero ) then
            a_tmp1 = y1_sl(jjj)
          else
            a_tmp1 = y1_sl(jjj+1)
          end if

          if( angle2(jjj).lt.zero ) then
            a_tmp2 = y2_sl(jjj)
          else
            a_tmp2 = y2_sl(jjj+1)
          end if

!!     Write down the information on slice centre and offset
!                     if (firstrun) then
!                        write(*,*) 'Processing slice number ',jjj,
!     &                       ' of ',n_slices,' for the collimator ',
!     &                       db_name1(icoll)
!                        write(*,*) 'Aperture [m]= ',
!     &                       a_tmp1 - a_tmp2
!                        write(*,*) 'Offset [m]  = ',
!     &                       0.5 * ( a_tmp1 + a_tmp2 )
!                     endif
!!
!     Be careful! the initial tilt must be added!
!     We leave it like this for the moment (no initial tilt)
!         c_tilt(1) = c_tilt(1) + angle1(jjj)
!         c_tilt(2) = c_tilt(2) + angle2(jjj)
          c_tilt(1) = angle1(jjj)
          c_tilt(2) = angle2(jjj)
!     New version of 'collimate2' is required: one must pass the
!     slice number in order the calculate correctly the 's'
!     coordinate in the impact files.
!     +                    a_tmp1 - a_tmp2,
!     +                    0.5 * ( a_tmp1 + a_tmp2 ),
! -- TW SEP07 added compatility for tilt, gap and ofset errors to slicing
! -- TW gaprms error is already included in the c_aperture used above
! -- TW tilt error is added to y1_sl and y2_sl therfore included in
! -- TW angle1 and angle2 no additinal changes needed
! -- TW offset error directly added to call of collimate2

! --- TW JUNE08
          if (firstrun) then
            write(collsettings_unit,'(a,1x,i10,5(1x,e13.5),1x,a)')      &
     &                       db_name1(icoll)(1:12),                     &
     &                       jjj,                                       &
     &                       (a_tmp1 - a_tmp2)/two,                     &
     &                       half * (a_tmp1 + a_tmp2) + c_offset,       &
     &                       c_tilt(1),                                 &
     &                       c_tilt(2),                                 &
     &                       c_length / real(n_slices,fPrec),           &
     &                       db_material(icoll)
          end if
! --- TW JUNE08
                     call collimate2(c_material,                        &
     &                    c_length / real(n_slices,fPrec),              &
     &                    c_rotation,                                   &
     &                    a_tmp1 - a_tmp2,                              &
     &                    half * ( a_tmp1 + a_tmp2 ) + c_offset,        &
     &                    c_tilt,                                       &
     &                    rcx, rcxp, rcy, rcyp,                         &
     &                    rcp, rcs, napx, enom_gev,                     &
     &                    part_hit_pos, part_hit_turn,                  &
     &                    part_abs_pos, part_abs_turn,                  &
     &                    part_impact, part_indiv,                      &
     &                    part_linteract, onesided, flukaname,          &
     &                    secondary,                                    &
     &                    jjj, nabs_type)
        end do !do jjj=1,n_slices
      else !if(n_slices.gt.one .and. totals.gt.smin_slices .and. totals.lt.smax_slices .and.
!     Treatment of non-sliced collimators

#ifdef G4COLLIMAT
!! Add the geant4 geometry
        if(firstrun.and.iturn.eq.1) then
          call g4_add_collimator(db_name1(icoll), c_material, c_length, c_aperture, c_rotation, c_offset)
        endif

!! Here we do the real collimation
!! First set the correct collimator
        call g4_set_collimator(db_name1(icoll))
        flush(lout)

!! Loop over all our particles
        g4_lostc = 0
        do j = 1, napx
          if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
!! Rotate particles in the frame of the collimator
!! There is more precision if we do it here rather
!! than in the g4 geometry
            x_tmp = rcx(j)
            y_tmp = rcy(j)
            xp_tmp = rcxp(j)
            yp_tmp = rcyp(j)
            rcx(j) = x_tmp*cos_mb(c_rotation) +sin_mb(c_rotation)*y_tmp
            rcy(j) = y_tmp*cos_mb(c_rotation) -sin_mb(c_rotation)*x_tmp
            rcxp(j) = xp_tmp*cos_mb(c_rotation)+sin_mb(c_rotation)*yp_tmp
            rcyp(j) = yp_tmp*cos_mb(c_rotation)-sin_mb(c_rotation)*xp_tmp

!! Call the geant4 collimation function
            call g4_collimate(rcx(j), rcy(j), rcxp(j), rcyp(j), rcp(j))

!! Get the particle back + information
            call g4_collimate_return(rcx(j), rcy(j), rcxp(j), rcyp(j), rcp(j), part_hit_flag, part_abs_flag, &
 &                                   part_impact(j), part_indiv(j), part_linteract(j))

!! Rotate back into the accelerator frame
            x_tmp   = rcx(j)
            y_tmp   = rcy(j)
            xp_tmp  = rcxp(j)
            yp_tmp  = rcyp(j)
            rcx(j)  = x_tmp *cos_mb(-one*c_rotation) + sin_mb(-one*c_rotation)*y_tmp
            rcy(j)  = y_tmp *cos_mb(-one*c_rotation) - sin_mb(-one*c_rotation)*x_tmp
            rcxp(j) = xp_tmp*cos_mb(-one*c_rotation) + sin_mb(-one*c_rotation)*yp_tmp
            rcyp(j) = yp_tmp*cos_mb(-one*c_rotation) - sin_mb(-one*c_rotation)*xp_tmp

!           If a particle hit
            if(part_hit_flag.ne.0) then
              part_hit_pos(j) = ie
              part_hit_turn(j) = iturn
            end if

!           If a particle died (the checking if it is already dead is at the start of the loop)
!           Geant just has a general inelastic process that single diffraction is part of
!           Therefore we can not know if this interaction was SD or some other inelastic type
            if(part_abs_flag.ne.0) then
              if(dowrite_impact) then
!! FLUKA_impacts.dat
                write(FLUKA_impacts_unit,'(i4,(1x,f6.3),(1x,f8.6),4(1x,e19.10),i2,2(1x,i7))') &
 &                    icoll,c_rotation,zero,zero,zero,zero,zero,part_abs_flag,flukaname(j),iturn
              end if

              part_abs_pos(j)  = ie
              part_abs_turn(j) = iturn
              rcx(j) = 99.99e-3_fPrec
              rcy(j) = 99.99e-3_fPrec
              g4_lostc = g4_lostc + 1
            end if
          flush(lout)
          end if !part_abs_pos(j) .ne. 0 .and. part_abs_turn(j) .ne. 0
        end do   !do j = 1, napx
!      write(lout,*) 'COLLIMATOR LOSSES ', db_name1(icoll), g4_lostc
#endif
#ifndef G4COLLIMAT
! This is what is called in a normal collimation run
                  call collimate2(c_material, c_length, c_rotation,     &
     &                 c_aperture, c_offset, c_tilt,                    &
     &                 rcx, rcxp, rcy, rcyp,                            &
     &                 rcp, rcs, napx, enom_gev,                        &
     &                 part_hit_pos,part_hit_turn,                      &
     &                 part_abs_pos, part_abs_turn,                     &
     &                 part_impact, part_indiv, part_linteract,         &
     &                 onesided, flukaname, secondary, 1, nabs_type)
#endif
      end if !if (n_slices.gt.one .and.
    end if !if(db_name1(icoll)(1:4).eq.'COLM') then
  end if !if (found) then
end subroutine collimate_do_collimator

!>
!! collimate_end_collimator()
!! This routine is called at the exit of a collimator
!<
subroutine collimate_end_collimator()

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

#ifdef HDF5
  ! For tracks2
  integer hdfturn,hdfpid,hdftyp
  real(kind=fPrec) hdfx,hdfxp,hdfy,hdfyp,hdfdee,hdfs
#endif

  real(kind=fPrec) c5m4,stracki

#ifdef FAST
  c5m4=5.0e-4_fPrec
#endif

!++  Output information:
!++
!++  PART_HIT_POS (MAX_NPART)  Hit flag for last hit
!++  PART_HIT_TURN(MAX_NPART)  Hit flag for last hit
!++  PART_ABS_POS (MAX_NPART)  Abs flag
!++  PART_ABS_TURN(MAX_NPART)  Abs flag
!++  PART_IMPACT  (MAX_NPART)  Impact parameter (0 for inner face)
!++  PART_INDIV   (MAX_NPART)  Divergence of impacting particles
!------------------------------------------------------------------------------
!++  Calculate average impact parameter and save info for all
!++  collimators. Copy information back and do negative drift.
  n_impact = 0
  n_absorbed = 0
  sum      = zero
  sqsum    = zero

!++  Copy particle data back and do path length stuff; check for absorption
!++  Add orbit offset back.
  do j = 1, napx

!APRIL2005 IN ORDER TO GET RID OF NUMERICAL ERRORS, JUST DO THE TREATMENT FOR
!APRIL2005 IMPACTING PARTICLES...
    if(part_hit_pos(j) .eq.ie .and. part_hit_turn(j).eq.iturn) then
!++  For zero length element track back half collimator length
! DRIFT PART
      if (stracki.eq.0.) then
        if(iexact.eq.0) then
          rcx(j)  = rcx(j) - half*c_length*rcxp(j)
          rcy(j)  = rcy(j) - half*c_length*rcyp(j)
        else
          zpj=sqrt(one-rcxp(j)**2-rcyp(j)**2)
          rcx(j) = rcx(j) - half*c_length*(rcxp(j)/zpj)
          rcy(j) = rcy(j) - half*c_length*(rcyp(j)/zpj)
        end if
      end if

!++  Now copy data back to original verctor
      xv(1,j) = rcx(j)  * c1e3 + torbx(ie)
      yv(1,j) = rcxp(j) * c1e3 + torbxp(ie)
      xv(2,j) = rcy(j)  * c1e3 + torby(ie)
      yv(2,j) = rcyp(j) * c1e3 + torbyp(ie)
      ejv(j)  = rcp(j)  * c1e3

!++  Energy update, as recommended by Frank
      ejfv(j)   = sqrt(ejv(j)*ejv(j)-nucm(j)*nucm(j))
      rvv(j)    = (ejv(j)*e0f)/(e0*ejfv(j))
      dpsv(j)   = (ejfv(j)-e0f)/e0f
      oidpsv(j) = one/(one+dpsv(j))
      moidpsv(j) = mtc(j)/(one+dpsv(j))
      omoidpsv(j)=c1e3*((one-mtc(j))*oidpsv(j))
      dpsv1(j)  = dpsv(j)*c1e3*oidpsv(j)
      yv(1,j)   = ejf0v(j)/ejfv(j)*yv(1,j)
      yv(2,j)   = ejf0v(j)/ejfv(j)*yv(2,j)

!++   For absorbed particles set all coordinates to zero. Also
!++   include very large offsets, let's say above 100mm or
!++   100mrad.
      if( (part_abs_pos(j).ne.0 .and. part_abs_turn(j).ne.0) .or.&
 &      xv(1,j).gt.c1e2 .or. yv(1,j).gt.c1e2 .or. xv(2,j).gt.c1e2 .or. yv(2,j).gt.c1e2) then
        xv(1,j) = zero
        yv(1,j) = zero
        xv(2,j) = zero
        yv(2,j) = zero
        ejv(j)  = myenom
        sigmv(j)= zero
        part_abs_pos(j)=ie
        part_abs_turn(j)=iturn
        secondary(j) = 0
        tertiary(j)  = 0
        other(j)     = 0
        scatterhit(j)= 0
        nabs_type(j) = 0
      end if

!APRIL2005 ...OTHERWISE JUST GET BACK FORMER COORDINATES
    else
      xv(1,j) = rcx0(j)  * c1e3 + torbx(ie)
      yv(1,j) = rcxp0(j) * c1e3 + torbxp(ie)
      xv(2,j) = rcy0(j)  * c1e3 + torby(ie)
      yv(2,j) = rcyp0(j) * c1e3 + torbyp(ie)
      ejv(j)  = rcp0(j)  * c1e3
    end if
!APRIL2005
!
!TW for roman pot checking
!            if(icoll.eq.73) then
!               do j = 1,napx
!                  write(9998,*)flukaname(j),rcx0(j),rcy0(j),rcx(j),     &
!     &rcy(j),rcxp0(j),rcyp0(j),rcxp(j),rcyp(j)
!               enddo
!            elseif(icoll.eq.74) then
!               do j = 1,napx
!                  write(9999,*)flukaname(j),rcx0(j),rcy0(j),rcx(j),     &
!     &rcy(j),rcxp0(j),rcyp0(j),rcxp(j),rcyp(j)
!               enddo
!            endif
!
!++  Write trajectory for any selected particle
!
!!            if (firstrun) then
!!              if (rselect.gt.0 .and. rselect.lt.65) then
!            DO j = 1, NAPX
!
!!              xj     = (xv(1,j)-torbx(ie))/1d3
!!              xpj    = (yv(1,j)-torbxp(ie))/1d3
!!              yj     = (xv(2,j)-torby(ie))/1d3
!!              ypj    = (yv(2,j)-torbyp(ie))/1d3
!!              pj     = ejv(j)/1d3
!GRD
!07-2006 TEST
!!              if (iturn.eq.1.and.j.eq.1) then
!!              sum_ax(ie)=0d0
!!              sum_ay(ie)=0d0
!!              endif
!GRD
!
!!              gammax = (1d0 + talphax(ie)**2)/tbetax(ie)
!!              gammay = (1d0 + talphay(ie)**2)/tbetay(ie)
!
!!             if (part_abs(j).eq.0) then
!!          nspx    = sqrt(                                               &
!!     &abs( gammax*(xj)**2 +                                             &
!!     &2d0*talphax(ie)*xj*xpj +                                          &
!!     &tbetax(ie)*xpj**2 )/myemitx0                                      &
!!     &)
!!                nspy    = sqrt(                                         &
!!     &abs( gammay*(yj)**2 +                                             &
!!     &2d0*talphay(ie)*yj*ypj +                                          &
!!     &tbetay(ie)*ypj**2 )/myemity0                                      &
!!     &)

!++  First check for particle interaction at this collimator and this turn
    if(part_hit_pos (j).eq.ie .and. part_hit_turn(j).eq.iturn) then

!++  Fill the change in particle angle into histogram
      if(dowrite_impact) then
#ifdef HDF5
        if(h5_useForSCAT) then
          call h5_prepareWrite(coll_hdf5_allImpacts, 1)
          call h5_writeData(coll_hdf5_allImpacts, 1, 1, ipart(j))
          call h5_writeData(coll_hdf5_allImpacts, 2, 1, iturn)
          call h5_writeData(coll_hdf5_allImpacts, 3, 1, sampl(ie))
          call h5_finaliseWrite(coll_hdf5_allImpacts)
        else
#endif
          write(all_impacts_unit,'(i8,1x,i4,1x,f8.2)') ipart(j),iturn,sampl(ie)
#ifdef HDF5
        end if
#endif
      end if

      ! Particle has impacted
      if(part_abs_pos(j) .ne.0 .and. part_abs_turn(j).ne.0) then
        if(dowrite_impact) then
#ifdef HDF5
          if(h5_useForSCAT) then
            call h5_prepareWrite(coll_hdf5_allAbsorb, 1)
            call h5_writeData(coll_hdf5_allAbsorb, 1, 1, ipart(j))
            call h5_writeData(coll_hdf5_allAbsorb, 2, 1, iturn)
            call h5_writeData(coll_hdf5_allAbsorb, 3, 1, sampl(ie))
            call h5_finaliseWrite(coll_hdf5_allAbsorb)
          else
#endif
            write(all_absorptions_unit,'(i8,1x,i4,1x,f8.2)') ipart(j),iturn,sampl(ie)
#ifdef HDF5
          end if
#endif
        end if

      !Here we've found a newly hit particle
      else if(part_abs_pos (j).eq.0 .and.  part_abs_turn(j).eq.0) then
        xkick = rcxp(j) - rcxp0(j)
        ykick = rcyp(j) - rcyp0(j)

        ! Indicate wether this is a secondary / tertiary / other particle;
        !  note that 'scatterhit' (equals 8 when set) is set in SCATTER.
        if(db_name1(icoll)(1:3).eq.'TCP'   .or. &
           db_name1(icoll)(1:4).eq.'COLM'  .or. &
           db_name1(icoll)(1:5).eq.'COLH0' .or. &
           db_name1(icoll)(1:5).eq.'COLV0'       ) then
          secondary(j) = 1
        else if(db_name1(icoll)(1:3).eq.'TCS'   .or. &
                db_name1(icoll)(1:4).eq.'COLH1' .or. &
                db_name1(icoll)(1:4).eq.'COLV1' .or. &
                db_name1(icoll)(1:4).eq.'COLH2'       ) then
          tertiary(j)  = 2
       else if((db_name1(icoll)(1:3).eq.'TCL') .or. &
               (db_name1(icoll)(1:3).eq.'TCT') .or. &
               (db_name1(icoll)(1:3).eq.'TCD') .or. &
               (db_name1(icoll)(1:3).eq.'TDI')       ) then
          other(j)     = 4
        end if
      else
        write(lout,*) "Error in collimate_end_collimator"
        write(lout,*) "Particle cannot be both absorbed and not absorbed."
        write(lout,*) part_abs_pos (j),  part_abs_turn(j)
        call prror(-1)
      end if

!GRD THIS LOOP MUST NOT BE WRITTEN INTO THE "IF(FIRSTRUN)" LOOP !!!!!
      if(dowritetracks) then
        if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
          if((secondary(j) .eq. 1 .or. &
              tertiary(j)  .eq. 2 .or. &
              other(j)     .eq. 4 .or. &
              scatterhit(j).eq.8         ) .and. &
             (xv(1,j).lt.99.0_fPrec .and. xv(2,j).lt.99.0_fPrec).and.&
!GRD HERE WE APPLY THE SAME KIND OF CUT THAN THE SIGSECUT PARAMETER
             ((((xv(1,j)*c1m3)**2 / (tbetax(ie)*myemitx0_collgap)) .ge. real(sigsecut2,fPrec)) .or. &
             (((xv(2,j)*c1m3)**2  / (tbetay(ie)*myemity0_collgap)) .ge. real(sigsecut2,fPrec)) .or. &
             (((xv(1,j)*c1m3)**2  / (tbetax(ie)*myemitx0_collgap)) + &
             ((xv(2,j)*c1m3)**2   / (tbetay(ie)*myemity0_collgap)) .ge. sigsecut3)) ) &
             then

            xj  = (xv(1,j)-torbx(ie))  /c1e3
            xpj = (yv(1,j)-torbxp(ie)) /c1e3
            yj  = (xv(2,j)-torby(ie))  /c1e3
            ypj = (yv(2,j)-torbyp(ie)) /c1e3

#ifdef HDF5
            if(h5_writeTracks2) then
              ! We write trajectories before and after element in this case.
              hdfpid  = ipart(j)
              hdfturn = iturn
              hdfs    = sampl(ie)-half*c_length
              hdfx    = (rcx0(j)*c1e3+torbx(ie)) - half*c_length*(rcxp0(j)*c1e3+torbxp(ie))
              hdfxp   = rcxp0(j)*c1e3+torbxp(ie)
              hdfy    = (rcy0(j)*c1e3+torby(ie)) - half*c_length*(rcyp0(j)*c1e3+torbyp(ie))
              hdfyp   = rcyp0(j)*c1e3+torbyp(ie)
              hdfdee  = (ejv(j)-myenom)/myenom
              hdftyp  = secondary(j)+tertiary(j)+other(j)+scatterhit(j)
              call h5tr2_writeLine(hdfpid,hdfturn,hdfs,hdfx,hdfxp,hdfy,hdfyp,hdfdee,hdftyp)

              hdfs  = sampl(ie)+half*c_length
              hdfx  = xv(1,j) + half*c_length*yv(1,j)
              hdfxp = yv(1,j)
              hdfy  = xv(2,j) + half*c_length*yv(2,j)
              hdfyp = yv(2,j)
              call h5tr2_writeLine(hdfpid,hdfturn,hdfs,hdfx,hdfxp,hdfy,hdfyp,hdfdee,hdftyp)
            else
#endif
              write(tracks2_unit,'(1x,i8,1x,i4,1x,f10.2,4(1x,e11.5),1x,e11.3,1x,i4)') &
                ipart(j),iturn,sampl(ie)-half*c_length,           &
                (rcx0(j)*c1e3+torbx(ie))-half*c_length*(rcxp0(j)*c1e3+torbxp(ie)), &
                rcxp0(j)*c1e3+torbxp(ie),                                          &
                (rcy0(j)*c1e3+torby(ie))-half*c_length*(rcyp0(j)*c1e3+torbyp(ie)), &
                rcyp0(j)*c1e3+torbyp(ie),                                          &
                (ejv(j)-myenom)/myenom,secondary(j)+tertiary(j)+other(j)+scatterhit(j)

              write(tracks2_unit,'(1x,i8,1x,i4,1x,f10.2,4(1x,e11.5),1x,e11.3,1x,i4)') &
                ipart(j),iturn,sampl(ie)+half*c_length,           &
                xv(1,j)+half*c_length*yv(1,j),yv(1,j),                             &
                xv(2,j)+half*c_length*yv(2,j),yv(2,j),(ejv(j)-myenom)/myenom,      &
                secondary(j)+tertiary(j)+other(j)+scatterhit(j)
#ifdef HDF5
            end if
#endif
          end if ! if((secondary(j).eq.1.or.tertiary(j).eq.2.or.other(j).eq.4) .and.(xv(1,j).lt.99.0_fPrec .and. xv(2,j).lt.99.0_fPrec) .and.
        end if !if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
      end if !if(dowritetracks) then

!++  Calculate impact observables, fill histograms, save collimator info, ...
      n_impact = n_impact + 1
      sum = sum + part_impact(j)
      sqsum = sqsum + part_impact(j)**2
      cn_impact(icoll) = cn_impact(icoll) + 1
      csum(icoll) = csum(icoll) + part_impact(j)
      csqsum(icoll) = csqsum(icoll) + part_impact(j)**2

!++  If the interacting particle was lost, add-up counters for absorption
!++  Note: a particle with x/y >= 99. never hits anything any more in
!++        the logic of this program. Be careful to always fulfill this!
      if(part_abs_pos(j).ne.0 .and. part_abs_turn(j).ne.0) then
        n_absorbed = n_absorbed + 1
        cn_absorbed(icoll) = cn_absorbed(icoll) + 1
        n_tot_absorbed = n_tot_absorbed + 1
        iturn_last_hit = part_hit_before_turn(j)
        iturn_absorbed = part_hit_turn(j)
        if(iturn_last_hit.eq.0) then
          iturn_last_hit = iturn_absorbed
          iturn_survive  = iturn_absorbed - iturn_last_hit
        end if
      end if

!++  End of check for hit this turn and element
    end if
  end do ! end do j = 1, napx

!++  Calculate statistical observables and save into files...
  if (n_impact.gt.0) then
    average = sum/n_impact

    if (sqsum/n_impact.ge.average**2) then
      sigma = sqrt(sqsum/n_impact - average**2)
    else
      sigma = zero
    end if
  else
    average = zero
    sigma   = zero
  end if

  if(cn_impact(icoll).gt.0) then
    caverage(icoll) = csum(icoll)/cn_impact(icoll)

    if((caverage(icoll)**2).gt.(csqsum(icoll)/cn_impact(icoll))) then
      csigma(icoll) = 0
    else
      csigma(icoll) = sqrt(csqsum(icoll)/cn_impact(icoll) - caverage(icoll)**2)
    end if
  end if

!-----------------------------------------------------------------
!++  For a  S E L E C T E D  collimator only consider particles that
!++  were scattered on this selected collimator at the first turn. All
!++  other particles are discarded.
!++  - This is switched on with the DO_SELECT flag in the input file.
!++  - Note that the part_select(j) flag defaults to 1 for all particles.

! should name_sel(1:11) extended to allow longer names as done for
! coll the coll_ellipse.dat file !!!!!!!!
  if(((db_name1(icoll).eq.name_sel(1:max_name_len)).or.&
      (db_name2(icoll).eq.name_sel(1:max_name_len))) .and. iturn.eq.1  ) then
    num_selhit = 0
    num_surhit = 0
    num_selabs = 0

    do j = 1, napx
      if( part_hit_pos (j).eq.ie .and. part_hit_turn(j).eq.iturn ) then

      num_selhit = num_selhit+1

      if(part_abs_pos(j) .eq.0 .and. part_abs_turn(j).eq.0) then
        num_surhit = num_surhit+1
      else
        num_selabs = num_selabs + 1
      end if

!++  If we want to select only partciles interacting at the specified
!++  collimator then remove all other particles and reset the number
!++  of the absorbed particles to the selected collimator.
      else if(do_select.and.firstrun) then
        part_select(j) = 0
        n_tot_absorbed = num_selabs
      end if
    end do

!++  Calculate average impact parameter and save distribution into file
!++  only for selected collimator
    n_impact = 0
    sum      = zero
    sqsum    = zero

    do j = 1, napx
      if( part_hit_pos (j).eq.ie .and. part_hit_turn(j).eq.iturn ) then
        if(part_impact(j).lt.-half) then
          write(lout,*) 'ERR>  Found invalid impact parameter!', part_impact(j)
          write(outlun,*) 'ERR>  Invalid impact parameter!', part_impact(j)
          call prror(-1)
        end if

        n_impact = n_impact + 1
        sum = sum + part_impact(j)
        sqsum = sqsum + part_impact(j)**2
        if(part_hit_pos (j).ne.0 .and. part_hit_turn(j).ne.0 .and.dowrite_impact ) then
          write(impact_unit,*) part_impact(j), part_indiv(j)
        end if
      end if
    end do

    if(n_impact.gt.0) then
      average = sum/n_impact
      if(sqsum/n_impact.ge.average**2) then
        sigma = sqrt(sqsum/n_impact - average**2)
      else
        sigma = zero
      end if
    end if

!++  Some information
    write(lout,*) 'INFO>  Selected collimator had N hits. N: ', num_selhit
    write(lout,*) 'INFO>  Number of impacts                : ', n_impact
    write(lout,*) 'INFO>  Number of escaped protons        : ', num_surhit
    write(lout,*) 'INFO>  Average impact parameter [m]     : ', average
    write(lout,*) 'INFO>  Sigma impact parameter [m]       : ', sigma

    if (dowrite_impact) then
      close(impact_unit)
    end if

!++  End of    S E L E C T E D   collimator
  end if

end subroutine collimate_end_collimator

!>
!! collimate_end_sample()
!! This routine is called from trauthin after each sample
!! has been tracked by thin6d
!<
subroutine collimate_end_sample(j)

  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond
  use crcoall
#ifdef ROOT
  use root_output
#endif

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

#ifdef HDF5
  type(h5_dataField), allocatable :: fldHdf(:)
  integer fmtHdf, setHdf
#endif

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)
!++  Save particle offsets to a file
  ! close(beta_beat_unit)
  close(survival_unit)

  if(dowrite_impact) close(impact_unit)

  if(dowritetracks) then
    if(cern) close(tracks2_unit)
#ifdef HDF5
    if(cern .and. h5_writeTracks2) call h5tr2_finalise
#endif
  end if

!------------------------------------------------------------------------
!++  Write the number of absorbed particles
  write(outlun,*) 'INFO>  Number of impacts             : ', n_tot_absorbed+nsurvive_end
  write(outlun,*) 'INFO>  Number of impacts at selected : ', num_selhit
  write(outlun,*) 'INFO>  Number of surviving particles : ', nsurvive_end
  write(outlun,*) 'INFO>  Number of absorbed particles  : ', n_tot_absorbed
  write(outlun,*)

  if(n_tot_absorbed.ne.0) then                                       !hr08
    write(outlun,*) ' INFO>  Eff_r @  8 sigma    [e-4] : ', (neff(5)/real(n_tot_absorbed,fPrec))/c1m4              !hr08
    write(outlun,*) ' INFO>  Eff_r @ 10 sigma    [e-4] : ', (neff(9)/real(n_tot_absorbed,fPrec))/c1m4              !hr08
    write(outlun,*) ' INFO>  Eff_r @ 10-20 sigma [e-4] : ', ((neff(9)-neff(19))/(dble(n_tot_absorbed)))/c1m4 !hr08
    write(outlun,*)
    write(outlun,*) neff(5)/dble(n_tot_absorbed), neff(9)/dble(n_tot_absorbed),(neff(9)-neff(19))/(dble(n_tot_absorbed)), ' !eff'
    write(outlun,*)
  else
    write(lout,*) 'NO PARTICLE ABSORBED'
  endif

  write(lout,*)
  write(lout,*) 'INFO>  Number of impacts             : ', n_tot_absorbed+nsurvive_end
  write(lout,*) 'INFO>  Number of impacts at selected : ', num_selhit
  write(lout,*) 'INFO>  Number of surviving particles : ', nsurvive_end
  write(lout,*) 'INFO>  Number of absorbed particles  : ', n_tot_absorbed
  write(lout,*)

  if(n_tot_absorbed.ne.0) then                                       !hr08
    write(lout,*) ' INFO>  Eff_r @  8 sigma    [e-4] : ', (neff(5)/dble(n_tot_absorbed))/c1m4            !hr08
    write(lout,*) ' INFO>  Eff_r @ 10 sigma    [e-4] : ', (neff(9)/dble(n_tot_absorbed))/c1m4            !hr08
    write(lout,*) ' INFO>  Eff_r @ 10-20 sigma [e-4] : ', ((neff(9)-neff(19))/dble(n_tot_absorbed))/c1m4 !hr08
    write(lout,*)
  else
     write(lout,*) 'NO PARTICLE ABSORBED'
  endif

! Write efficiency file
#ifdef HDF5
  if(h5_useForCOLL .and. n_tot_absorbed /= 0) then
    allocate(fldHdf(8))
    fldHdf(1) = h5_dataField(name="RAD_SIGMA",  type=h5_typeReal)
    fldHdf(2) = h5_dataField(name="NEFFX/NTOT", type=h5_typeReal)
    fldHdf(3) = h5_dataField(name="NEFFY/NTOT", type=h5_typeReal)
    fldHdf(4) = h5_dataField(name="NEFF/NTOT",  type=h5_typeReal)
    fldHdf(5) = h5_dataField(name="NEFFX",      type=h5_typeReal)
    fldHdf(6) = h5_dataField(name="NEFFY",      type=h5_typeReal)
    fldHdf(7) = h5_dataField(name="NEFF",       type=h5_typeReal)
    fldHdf(8) = h5_dataField(name="NTOT",       type=h5_typeInt)
    call h5_createFormat("collEfficiency", fldHdf, fmtHdf)
    call h5_createDataSet("efficiency", h5_collID, fmtHdf, setHdf, numeff)
    call h5_prepareWrite(setHdf, numeff)
    call h5_writeData(setHdf, 1, numeff, rsig(1:numeff))
    call h5_writeData(setHdf, 2, numeff, neffx(1:numeff)/dble(n_tot_absorbed))
    call h5_writeData(setHdf, 3, numeff, neffy(1:numeff)/dble(n_tot_absorbed))
    call h5_writeData(setHdf, 4, numeff, neff(1:numeff)/dble(n_tot_absorbed))
    call h5_writeData(setHdf, 5, numeff, neffx(1:numeff))
    call h5_writeData(setHdf, 6, numeff, neffy(1:numeff))
    call h5_writeData(setHdf, 7, numeff, neff(1:numeff))
    call h5_writeData(setHdf, 8, numeff, n_tot_absorbed)
    call h5_finaliseWrite(setHdf)
    deallocate(fldHdf)
  else
#endif
    call funit_requestUnit('efficiency.dat', efficiency_unit)
    open(unit=efficiency_unit, file='efficiency.dat') !was 1991
    if(n_tot_absorbed /= 0) then
      write(efficiency_unit,*) '# 1=rad_sigma 2=frac_x 3=frac_y 4=frac_r' ! This is not correct?
      do k=1,numeff
        write(efficiency_unit,'(7(1x,e15.7),1x,I5)') rsig(k), neffx(k)/dble(n_tot_absorbed),neffy(k)/dble(n_tot_absorbed), &
          neff(k)/dble(n_tot_absorbed), neffx(k), neffy(k), neff(k), n_tot_absorbed
      end do
    else
      write(lout,*) 'NO PARTICLE ABSORBED'
    end if
    close(efficiency_unit)
#ifdef HDF5
  end if
#endif

! Write efficiency vs dp/p file
#ifdef HDF5
  if(h5_useForCOLL .and. n_tot_absorbed /= 0) then
    allocate(fldHdf(5))
    fldHdf(1) = h5_dataField(name="DP/P",        type=h5_typeReal)
    fldHdf(2) = h5_dataField(name="NDPOP/TNABS", type=h5_typeReal)
    fldHdf(3) = h5_dataField(name="NDPOP",       type=h5_typeReal)
    fldHdf(4) = h5_dataField(name="TNABS",       type=h5_typeInt)
    fldHdf(5) = h5_dataField(name="NPART",       type=h5_typeInt)
    call h5_createFormat("collEfficiencyDPOP", fldHdf, fmtHdf)
    call h5_createDataSet("efficiency_dpop", h5_collID, fmtHdf, setHdf, numeffdpop)
    call h5_prepareWrite(setHdf, numeffdpop)
    call h5_writeData(setHdf, 1, numeffdpop, dpopbins(1:numeffdpop))
    call h5_writeData(setHdf, 2, numeffdpop, neffdpop(1:numeffdpop)/dble(n_tot_absorbed))
    call h5_writeData(setHdf, 3, numeffdpop, neffdpop(1:numeffdpop))
    call h5_writeData(setHdf, 4, numeffdpop, n_tot_absorbed)
    call h5_writeData(setHdf, 5, numeffdpop, npartdpop(1:numeffdpop))
    call h5_finaliseWrite(setHdf)
    deallocate(fldHdf)
  else
#endif
    call funit_requestUnit('efficiency_dpop.dat', efficiency_dpop_unit)
    open(unit=efficiency_dpop_unit, file='efficiency_dpop.dat') !was 1992
    if(n_tot_absorbed /= 0) then
      write(efficiency_dpop_unit,*) '# 1=dp/p 2=n_dpop/tot_nabs 3=n_dpop 4=tot_nabs 5=npart'
      do k=1,numeffdpop
        write(efficiency_dpop_unit,'(3(1x,e15.7),2(1x,I5))') dpopbins(k), neffdpop(k)/dble(n_tot_absorbed), neffdpop(k), &
            n_tot_absorbed, npartdpop(k)
      end do
    else
      write(lout,*) 'NO PARTICLE ABSORBED'
    end if
    close(efficiency_dpop_unit)
#ifdef HDF5
  end if
#endif

! Write 2D efficiency file (eff vs. A_r and dp/p)
#ifdef HDF5
  if(h5_useForCOLL .and. n_tot_absorbed /= 0) then
    allocate(fldHdf(5))
    fldHdf(1) = h5_dataField(name="RAD_SIGMA", type=h5_typeReal)
    fldHdf(2) = h5_dataField(name="DP/P",      type=h5_typeReal)
    fldHdf(3) = h5_dataField(name="N/TNABS",   type=h5_typeReal)
    fldHdf(4) = h5_dataField(name="N",         type=h5_typeReal)
    fldHdf(5) = h5_dataField(name="TNABS",     type=h5_typeInt)
    call h5_createFormat("collEfficiency2D", fldHdf, fmtHdf)
    call h5_createDataSet("efficiency_2d", h5_collID, fmtHdf, setHdf, numeffdpop)
    do i=1,numeff
      call h5_prepareWrite(setHdf, numeffdpop)
      call h5_writeData(setHdf, 1, numeffdpop, rsig(i))
      call h5_writeData(setHdf, 2, numeffdpop, dpopbins(1:numeffdpop))
      call h5_writeData(setHdf, 3, numeffdpop, neff2d(i,1:numeffdpop)/real(n_tot_absorbed,fPrec))
      call h5_writeData(setHdf, 4, numeffdpop, neff2d(i,1:numeffdpop))
      call h5_writeData(setHdf, 5, numeffdpop, n_tot_absorbed)
      call h5_finaliseWrite(setHdf)
    end do
    deallocate(fldHdf)
  else
#endif
    call funit_requestUnit('efficiency_2d.dat', efficiency_2d_unit)
    open(unit=efficiency_2d_unit, file='efficiency_2d.dat') !was 1993
    if(n_tot_absorbed /= 0) then
      write(efficiency_2d_unit,*) '# 1=rad_sigma 2=dp/p 3=n/tot_nabs 4=n 5=tot_nabs'
      do i=1,numeff
        do k=1,numeffdpop
          write(efficiency_2d_unit,'(4(1x,e15.7),1(1x,I5))') rsig(i), dpopbins(k),neff2d(i,k)/real(n_tot_absorbed,fPrec), &
                neff2d(i,k), n_tot_absorbed
        end do
      end do
    else
      write(lout,*) 'NO PARTICLE ABSORBED'
    end if
    close(efficiency_2d_unit)
#ifdef HDF5
  end if
#endif

! Write collimation summary file
#ifdef HDF5
  if(h5_useForCOLL) then
    allocate(fldHdf(7))
    fldHdf(1) = h5_dataField(name="ICOLL",    type=h5_typeInt)
    fldHdf(2) = h5_dataField(name="COLLNAME", type=h5_typeChar, size=max_name_len)
    fldHdf(3) = h5_dataField(name="NIMP",     type=h5_typeInt)
    fldHdf(4) = h5_dataField(name="NABS",     type=h5_typeInt)
    fldHdf(5) = h5_dataField(name="IMP_AV",   type=h5_typeReal)
    fldHdf(6) = h5_dataField(name="IMP_SIG",  type=h5_typeReal)
    fldHdf(7) = h5_dataField(name="LENGTH",   type=h5_typeReal)
    call h5_createFormat("collSummary", fldHdf, fmtHdf)
    call h5_createDataSet("coll_summary", h5_collID, fmtHdf, setHdf)
    ! There is a lot of overhead in writing line by line, but this is a small log file anyway.
    do i=1, db_ncoll
      if(db_length(i) > zero .and. coll_found(i)) then
        call h5_prepareWrite(setHdf, 1)
        call h5_writeData(setHdf, 1, 1, i)
        call h5_writeData(setHdf, 2, 1, db_name1(i))
        call h5_writeData(setHdf, 3, 1, cn_impact(i))
        call h5_writeData(setHdf, 4, 1, cn_absorbed(i))
        call h5_writeData(setHdf, 5, 1, caverage(i))
        call h5_writeData(setHdf, 6, 1, csigma(i))
        call h5_writeData(setHdf, 7, 1, db_length(i))
        call h5_finaliseWrite(setHdf)
      end if
    end do
    deallocate(fldHdf)
  else
#endif
    call funit_requestUnit('coll_summary.dat', coll_summary_unit)
    open(unit=coll_summary_unit, file='coll_summary.dat') !was 50
    write(coll_summary_unit,*) '# 1=icoll 2=collname 3=nimp 4=nabs 5=imp_av 6=imp_sig 7=length'
    do icoll = 1, db_ncoll
      if(db_length(icoll) > zero .and. coll_found(icoll)) then
        write(coll_summary_unit,'(i4,1x,a,2(1x,i5),2(1x,e15.7),3x,f4.1)') icoll, db_name1(icoll), cn_impact(icoll), &
          cn_absorbed(icoll), caverage(icoll), csigma(icoll),db_length(icoll)
      end if
    end do
    close(coll_summary_unit)
#ifdef HDF5
  end if
#endif

#ifdef ROOT
  if(root_flag .and. root_Collimation.eq.1) then
    do icoll = 1, db_ncoll
      if(db_length(icoll).gt.zero) then
        call CollimatorLossRootWrite(icoll, db_name1(icoll), len(db_name1(icoll)), cn_impact(icoll), cn_absorbed(icoll), &
          caverage(icoll), csigma(icoll), db_length(icoll))
      end if
    end do
  end if

  ! flush the root file
!  call SixTrackRootWrite()
#endif

end subroutine collimate_end_sample

!>
!! collimate_exit()
!! This routine is called once at the end of the simulation and
!! can be used to do any final postrocessing and/or file saving.
!<
subroutine collimate_exit()

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

  integer i,ix,j,jb,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom

  close(outlun)
  close(collgaps_unit)

  if(dowritetracks) then
    if(.not. cern) close(tracks2_unit)
#ifdef HDF5
    if(.not. cern .and. h5_writeTracks2) call h5tr2_finalise
#endif
    if(name_sel(1:3).eq.'COL') close(RHIClosses_unit)
  endif

  if(do_select) then
    close(coll_ellipse_unit)
  endif

  if(dowrite_impact) then
    close(all_impacts_unit)
    close(all_absorptions_unit)
    close(FLUKA_impacts_unit)
    close(FLUKA_impacts_all_unit)
    close(coll_scatter_unit)
    close(FirstImpacts_unit)
  endif

  call funit_requestUnit('amplitude.dat', amplitude_unit)
  call funit_requestUnit('amplitude2.dat', amplitude2_unit)
  call funit_requestUnit('betafunctions.dat', betafunctions_unit)
  open(unit=amplitude_unit, file='amplitude.dat') !was 56
  open(unit=amplitude2_unit, file='amplitude2.dat') !was 51
  open(unit=betafunctions_unit, file='betafunctions.dat') !was 57

  if(dowrite_amplitude) then
    write(amplitude_unit,*)                                             &
     &'# 1=ielem 2=name 3=s 4=AX_AV 5=AX_RMS 6=AY_AV 7=AY_RMS',         &
     &'8=alphax 9=alphay 10=betax 11=betay 12=orbitx',                  &
     &'13=orbity 14=tdispx 15=tdispy',                                  &
     &'16=xbob 17=ybob 18=xpbob 19=ypbob'

    do i=1,iu
       write(amplitude_unit,'(i4, (1x,a16), 17(1x,e20.13))')             &!hr08
      &i, ename(i), sampl(i),                                            &!hr08
      &sum_ax(i)/dble(max(nampl(i),1)),                                  &!hr08
      &sqrt(abs((sqsum_ax(i)/dble(max(nampl(i),1)))-                     &!hr08
      &(sum_ax(i)/dble(max(nampl(i),1)))**2)),                           &!hr08
      &sum_ay(i)/dble(max(nampl(i),1)),                                  &!hr08
      &sqrt(abs((sqsum_ay(i)/dble(max(nampl(i),1)))-                     &!hr08
      &(sum_ay(i)/dble(max(nampl(i),1)))**2)),                           &!hr08
      &talphax(i), talphay(i),                                           &!hr08
      &tbetax(i), tbetay(i), torbx(i), torby(i),                         &!hr08
      &tdispx(i), tdispy(i),                                             &!hr08
      &xbob(i),ybob(i),xpbob(i),ypbob(i)                                  !hr08
    end do

    write(amplitude2_unit,*)'# 1=ielem 2=name 3=s 4=ORBITX 5=orbity 6=tdispx 7=tdispy 8=xbob 9=ybob 10=xpbob 11=ypbob'

    do i=1,iu
      write(amplitude2_unit,'(i4, (1x,a16), 9(1x,e15.7))') i, ename(i), sampl(i), torbx(i), torby(i), tdispx(i), tdispy(i), &
            xbob(i), ybob(i), xpbob(i), ypbob(i)
    end do

    write(betafunctions_unit,*) '# 1=ielem 2=name       3=s             4=TBETAX(m)     5=TBETAY(m)     6=TORBX(mm)', &
                '    7=TORBY(mm) 8=TORBXP(mrad)   9=TORBYP(mrad)  10=TDISPX(m)  11=MUX()    12=MUY()'


    do i=1,iu
!     RB: added printout of closed orbit and angle
      write(betafunctions_unit,'(i5, (1x,a16), 10(1x,e15.7))') i, ename(i), sampl(i), tbetax(i), tbetay(i), torbx(i), torby(i), &
 &    torbxp(i), torbyp(i), tdispx(i), mux(i), muy(i)
    end do
  endif

  close(amplitude_unit)
  close(amplitude2_unit)
  close(betafunctions_unit)

!GRD
!      DO J=1,iu
!        DO I=1,numl
!        xaveragesumoverturns(j)  = xaverage(j,i)
!     &                             + xaverage(j,MAX((i-1),1))
!        yaveragesumoverturns(j)  = yaverage(j,i)
!     &                             + yaverage(j,MAX((i-1),1))
!        xpaveragesumoverturns(j) = xpaverage(j,i)
!     &                             + xpaverage(j,MAX((i-1),1))
!        ypaveragesumoverturns(j) = ypaverage(j,i)
!     &                             + ypaverage(j,MAX((i-1),1))
!        END DO
!        xclosedorbitcheck(j)=(xaveragesumoverturns(j)
!     &                        +xaverage(j,numl))/(2*numl)
!        yclosedorbitcheck(j)=(yaveragesumoverturns(j)
!     &                        +yaverage(j,numl))/(2*numl)
!        xpclosedorbitcheck(j)=(xpaveragesumoverturns(j)
!     &                        +xpaverage(j,numl))/(2*numl)
!        ypclosedorbitcheck(j)=(ypaveragesumoverturns(j)
!     &                        +ypaverage(j,numl))/(2*numl)
!      END DO
!
!      OPEN(unit=99, file='xchecking.dat')
!      WRITE(99,*) '# 1=s 2=x 3=xp 4=y 5=yp'
!      DO J=1,iu
!      WRITE(99,'(i, 5(1x,e15.7))')
!     &     j, SAMPL(j),
!     &     xclosedorbitcheck(j), xpclosedorbitcheck(j),
!     &     yclosedorbitcheck(j), ypclosedorbitcheck(j)
!      END DO
!      CLOSE(99)
!GRD
!GRD WE CAN ALSO MAKE AN ORBIT CHECKING
!GRD

  call funit_requestUnit('orbitchecking.dat', orbitchecking_unit)
  open(unit=orbitchecking_unit, file='orbitchecking.dat') !was 99
  write(orbitchecking_unit,*) '# 1=s 2=torbitx 3=torbity'

  do j=1,iu
    write(orbitchecking_unit,'(i5, 3(1x,e15.7))') j, sampl(j),torbx(j), torby(j)
  end do

  close(orbitchecking_unit)
  close(CollPositions_unit)

#ifdef G4COLLIMAT
  call g4_terminate()
#endif

end subroutine collimate_exit

!>
!! This routine is called at the start of each tracking turn
!<
subroutine collimate_start_turn(n)

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

  integer i,ix,j,jb,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen
  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom

  integer n

  iturn=n
  totals=zero !This keeps track of the s position of the current element, which is also done by cadcum
end subroutine collimate_start_turn

!>
!! This routine is called at the start of every element
!<
subroutine collimate_start_element(i)

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom
!+ca dbthin6d

  ie=i
!++  For absorbed particles set all coordinates to zero. Also
!++  include very large offsets, let's say above 100mm or
!++  100mrad.
  do j = 1, napx
    if( (part_abs_pos(j).ne.0 .and. part_abs_turn(j).ne.0) .or.&
 &  xv(1,j).gt.c1e2 .or. yv(1,j).gt.c1e2 .or. xv(2,j).gt.c1e2 .or. yv(2,j).gt.c1e2) then
      xv(1,j) = zero
      yv(1,j) = zero
      xv(2,j) = zero
      yv(2,j) = zero
      ejv(j)  = myenom
      sigmv(j)= zero
      part_abs_pos(j)=ie
      part_abs_turn(j)=iturn
      secondary(j) = 0
      tertiary(j)  = 0
      other(j)     = 0
      scatterhit(j)= 0
      nabs_type(j) = 0
    end if
  end do

!GRD SAVE COORDINATES OF PARTICLE 1 TO CHECK ORBIT
  if(firstrun) then
    xbob(ie)=xv(1,1)
    ybob(ie)=xv(2,1)
    xpbob(ie)=yv(1,1)
    ypbob(ie)=yv(2,1)
  end if

!++  Here comes sixtrack stuff
  if(ic(i).le.nblo) then
    do jb=1,mel(ic(i))
      myix=mtyp(ic(i),jb)
    end do
  else
    myix=ic(i)-nblo
  end if

!++  Make sure we go into collimation routine for any definition
!++  of collimator element, relying on element name instead.
  if (                                                          &
!GRD HERE ARE SOME CHANGES TO MAKE RHIC TRAKING AVAILABLE
!APRIL2005
     &(bez(myix)(1:3).eq.'TCP'.or.bez(myix)(1:3).eq.'tcp') .or.         &
     &(bez(myix)(1:3).eq.'TCS'.or.bez(myix)(1:3).eq.'tcs') .or.         &
!UPGRADE January 2005
     &(bez(myix)(1:3).eq.'TCL'.or.bez(myix)(1:3).eq.'tcl') .or.         &
     &(bez(myix)(1:3).eq.'TCT'.or.bez(myix)(1:3).eq.'tct') .or.         &
     &(bez(myix)(1:3).eq.'TCD'.or.bez(myix)(1:3).eq.'tcd') .or.         &
     &(bez(myix)(1:3).eq.'TDI'.or.bez(myix)(1:3).eq.'tdi') .or.         &
! UPGRADE MAI 2006 -> TOTEM
     &(bez(myix)(1:3).eq.'TCX'.or.bez(myix)(1:3).eq.'tcx') .or.         &
! TW 04/2008 adding TCRYO
     &(bez(myix)(1:3).eq.'TCR'.or.bez(myix)(1:3).eq.'tcr') .or.         &
!RHIC
     &(bez(myix)(1:3).eq.'COL'.or.bez(myix)(1:3).eq.'col') ) then

    myktrack = 1
  else
    myktrack = ktrack(i)
  endif

end subroutine collimate_start_element

!>
!! collimate_end_element()
!! This routine is called at the end of every element
!<
subroutine collimate_end_element

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom
!+ca dbthin6d

#ifdef HDF5
  integer hdfturn,hdfpid,hdftyp
  real(kind=fPrec) hdfx,hdfxp,hdfy,hdfyp,hdfdee,hdfs
#endif

  if(firstrun) then
    if(rselect.gt.0 .and. rselect.lt.65) then
      do j = 1, napx
        xj  = (xv(1,j)-torbx(ie)) /c1e3
        xpj = (yv(1,j)-torbxp(ie))/c1e3
        yj  = (xv(2,j)-torby(ie)) /c1e3
        ypj = (yv(2,j)-torbyp(ie))/c1e3
        pj  = ejv(j)/c1e3

        if(iturn.eq.1.and.j.eq.1) then
          sum_ax(ie) = zero
          sum_ay(ie) = zero
        endif

        if(tbetax(ie).gt.zero) then
          gammax = (one + talphax(ie)**2)/tbetax(ie)
          gammay = (one + talphay(ie)**2)/tbetay(ie)
        else
          gammax = (one + talphax(ie-1)**2)/tbetax(ie-1)
          gammay = (one + talphay(ie-1)**2)/tbetay(ie-1)
        endif

        if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
          if(tbetax(ie).gt.0.) then
            nspx = sqrt(abs( gammax*(xj)**2 + two*talphax(ie)*xj*xpj +   tbetax(ie)*xpj**2 )/myemitx0_collgap)
            nspy = sqrt(abs( gammay*(yj)**2 + two*talphay(ie)*yj*ypj +   tbetay(ie)*ypj**2 )/myemity0_collgap)
          else
            nspx = sqrt(abs( gammax*(xj)**2 + two*talphax(ie-1)*xj*xpj + tbetax(ie-1)*xpj**2 )/myemitx0_collgap)
            nspy = sqrt(abs( gammay*(yj)**2 + two*talphay(ie-1)*yj*ypj + tbetay(ie-1)*ypj**2 )/myemity0_collgap)
          end if

          sum_ax(ie)   = sum_ax(ie) + nspx
          sqsum_ax(ie) = sqsum_ax(ie) + nspx**2
          sum_ay(ie)   = sum_ay(ie) + nspy
          sqsum_ay(ie) = sqsum_ay(ie) + nspy**2
          nampl(ie)    = nampl(ie) + 1
        else
          nspx = zero
          nspy = zero
        end if

        sampl(ie) = totals
        ename(ie) = bez(myix)(1:max_name_len)
      end do
    end if
  end if

!GRD THIS LOOP MUST NOT BE WRITTEN INTO THE "IF(FIRSTRUN)" LOOP !!!!
  if (dowritetracks) then
    do j = 1, napx
      xj     = (xv(1,j)-torbx(ie)) /c1e3
      xpj    = (yv(1,j)-torbxp(ie))/c1e3
      yj     = (xv(2,j)-torby(ie)) /c1e3
      ypj    = (yv(2,j)-torbyp(ie))/c1e3

      arcdx = 2.5_fPrec
      arcbetax = c180e0

      if (xj.le.zero) then
        xdisp = xj + (pj-myenom)/myenom * arcdx* sqrt(tbetax(ie)/arcbetax)
      else
        xdisp = xj - (pj-myenom)/myenom * arcdx* sqrt(tbetax(ie)/arcbetax)
      end if

      xndisp = xj

      nspxd = sqrt(abs(gammax*xdisp**2 +  two*talphax(ie)*xdisp*xpj +  tbetax(ie)*xpj**2)/myemitx0_collgap)
      nspx  = sqrt(abs(gammax*xndisp**2 + two*talphax(ie)*xndisp*xpj + tbetax(ie)*xpj**2)/myemitx0_collgap)
      nspy  = sqrt(abs(gammay*yj**2 +     two*talphay(ie)*yj*ypj +     tbetay(ie)*ypj**2)/myemity0_collgap)

      if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then

!GRD HERE WE APPLY THE SAME KIND OF CUT THAN THE SIGSECUT PARAMETER
         if((secondary(j) .eq. 1 .or. &
             tertiary(j)  .eq. 2 .or. &
             other(j)     .eq. 4 .or. &
             scatterhit(j).eq. 8       ) .and. &
             (xv(1,j).lt.99.0_fPrec .and. xv(2,j).lt.99.0_fPrec) .and. &
             ((((xv(1,j)*c1m3)**2 / (tbetax(ie)*myemitx0_collgap)) .ge. real(sigsecut2,fPrec)).or. &
             (((xv(2,j)*c1m3)**2  / (tbetay(ie)*myemity0_collgap)) .ge. real(sigsecut2,fPrec)).or. &
             (((xv(1,j)*c1m3)**2  / (tbetax(ie)*myemitx0_collgap)) + &
             ((xv(2,j)*c1m3)**2  /  (tbetay(ie)*myemity0_collgap)) .ge. sigsecut3)) ) &
             then

          xj  = (xv(1,j)-torbx(ie)) /c1e3
          xpj = (yv(1,j)-torbxp(ie))/c1e3
          yj  = (xv(2,j)-torby(ie)) /c1e3
          ypj = (yv(2,j)-torbyp(ie))/c1e3
#ifdef HDF5
          if(h5_writeTracks2) then
            hdfpid=ipart(j)
            hdfturn=iturn
            hdfs=sampl(ie)
            hdfx=xv(1,j)
            hdfxp=yv(1,j)
            hdfy=xv(2,j)
            hdfyp=yv(2,j)
            hdfdee=(ejv(j)-myenom)/myenom
            hdftyp=secondary(j)+tertiary(j)+other(j)+scatterhit(j)
            call h5tr2_writeLine(hdfpid,hdfturn,hdfs,hdfx,hdfxp,hdfy,hdfyp,hdfdee,hdftyp)
          else
#endif
            write(tracks2_unit,'(1x,i8,1x,i4,1x,f10.2,4(1x,e11.5),1x,e11.3,1x,i4)') ipart(j), iturn, sampl(ie), &
              xv(1,j), yv(1,j), xv(2,j), yv(2,j), (ejv(j)-myenom)/myenom, secondary(j)+tertiary(j)+other(j)+scatterhit(j)
#ifdef HDF5
          end if
#endif
        end if
      end if
    end do
  end if !!JUNE2005 here I close the "if(dowritetracks)" outside of the firstrun flag

end subroutine collimate_end_element

!>
!! collimate_end_turn()
!! This routine is called at the end of every turn
!<
subroutine collimate_end_turn

  use parpro
  use mod_common
  use mod_commonmn
  use mod_commons
  use mod_commont
  use mod_commond
  use crcoall

#ifdef ROOT
  use root_output
#endif

  implicit none

  integer i,ix,j,jj,jx,kpz,kzz,napx0,nbeaux,nmz,nthinerr
  real(kind=fPrec) benkcc,cbxb,cbzb,cikveb,crkveb,crxb,crzb,r0,r000,r0a,r2b,rb,rho2b,rkb,tkb,xbb,xrb,zbb,zrb
  logical lopen

  dimension crkveb(npart),cikveb(npart),rho2b(npart),tkb(npart),r2b(npart),rb(npart),rkb(npart),&
  xrb(npart),zrb(npart),xbb(npart),zbb(npart),crxb(npart),crzb(npart),cbxb(npart),cbzb(npart),nbeaux(nbb)

!+ca dbtrthin
!+ca database
!+ca dbcommon
!+ca dblinopt
!+ca dbpencil
!+ca info
!+ca dbcolcom
!+ca dbthin6d

#ifdef HDF5
  ! For tracks2
  integer hdfturn,hdfpid,hdftyp
  real(kind=fPrec) hdfx,hdfxp,hdfy,hdfyp,hdfdee,hdfs
  ! For other output
  type(h5_dataField), allocatable :: fldHdf(:)
  integer fmtHdf, setHdf
#endif
  integer n
!__________________________________________________________________
!++  Now do analysis at selected elements...

!++  Save twiss functions of present element
  ax0  = talphax(ie)
  bx0  = tbetax(ie)
  mux0 = mux(ie)
  ay0  = talphay(ie)
  by0  = tbetay(ie)
  muy0 = muy(ie)

!GRD GET THE COORDINATES OF THE PARTICLES AT THE IEth ELEMENT:
  do j = 1,napx
    xgrd(j)  = xv(1,j)
    xpgrd(j) = yv(1,j)
    ygrd(j)  = xv(2,j)
    ypgrd(j) = yv(2,j)

    xineff(j)  = xv(1,j) - torbx (ie)
    xpineff(j) = yv(1,j) - torbxp(ie)
    yineff(j)  = xv(2,j) - torby (ie)
    ypineff(j) = yv(2,j) - torbyp(ie)

    pgrd(j)  = ejv(j)
    ejfvgrd(j) = ejfv(j)
    sigmvgrd(j) = sigmv(j)
    rvvgrd(j) = rvv(j)
    dpsvgrd(j) = dpsv(j)
    oidpsvgrd(j) = oidpsv(j)
    dpsv1grd(j) = dpsv1(j)

!GRD IMPORTANT: ALL PARTICLES ABSORBED ARE CONSIDERED TO BE LOST,
!GRD SO WE GIVE THEM A LARGE OFFSET
    if(part_abs_pos(j).ne.0 .and. part_abs_turn(j).ne.0) then
      xgrd(j) = 99.5_fPrec
      ygrd(j) = 99.5_fPrec
    end if
  end do

!++  For LAST ELEMENT in the ring calculate the number of surviving
!++  particles and save into file versus turn number
  if(ie.eq.iu) then
    nsurvive = 0

    do j = 1, napx
      if (xgrd(j).lt.99.0_fPrec .and. ygrd(j).lt.99.0_fPrec) then
        nsurvive = nsurvive + 1
      end if
    end do

#ifdef HDF5
    if(h5_useForCOLL) then
      call h5_prepareWrite(coll_hdf5_survival, 1)
      call h5_writeData(coll_hdf5_survival, 1, 1, iturn)
      call h5_writeData(coll_hdf5_survival, 2, 1, nsurvive)
      call h5_finaliseWrite(coll_hdf5_survival)
    else
#endif
      write(survival_unit,'(2i7)') iturn, nsurvive
#ifdef HDF5
    end if
#endif

#ifdef ROOT
    if(root_flag .and. root_Collimation.eq.1) then
      call SurvivalRootWrite(iturn, nsurvive)
    end if
#endif

    if (iturn.eq.numl) then
      nsurvive_end = nsurvive_end + nsurvive
    end if
  end if

!=======================================================================
!++  Do collimation analysis at element 20 ("zero" turn) or LAST
!++  ring element.

!++  If selecting, look at number of scattered particles at selected
!++  collimator. For the "zero" turn consider the information at element
!++  20 (before collimation), otherwise take information at last ring
!++  element.
  if (do_coll .and. (  (iturn.eq.1 .and. ie.eq.20) .or. (ie.eq.iu) ) ) then

!++  Calculate gammas
!------------------------------------------------------------------------
    gammax = (1 + talphax(ie)**2)/tbetax(ie)
    gammay = (1 + talphay(ie)**2)/tbetay(ie)

!________________________________________________________________________
!++  Loop over all particles.
    do j = 1, napx
!
!------------------------------------------------------------------------
!++  Save initial distribution of particles that were scattered on
!++  the first turn at the selected primary collimator
!
!            IF (DOWRITE_DIST .AND. DO_SELECT .AND. ITURN.EQ.1 .AND.
!     &          PART_SELECT(j).EQ.1) THEN
!              WRITE(987,'(4(1X,E15.7))') X00(J), XP00(J),
!     &                                        Y00(J), YP00(J)
!            ENDIF
!------------------------------------------------------------------------
!++  Do the binning in amplitude, only considering particles that were
!++  not absorbed before.

      if (xgrd(j).lt.99.0_fPrec .and. ygrd(j) .lt.99.0_fPrec .and. (part_select(j).eq.1 .or. ie.eq.20)) then

!++  Normalized amplitudes are calculated

!++  Allow to apply some dispersive offset. Take arc dispersion (2m) and
!++  normalize with arc beta_x function (180m).
        arcdx    = 2.5_fPrec
        arcbetax = c180e0
        xdisp = abs(xgrd(j)*c1m3) + abs((pgrd(j)-myenom)/myenom)*arcdx * sqrt(tbetax(ie)/arcbetax)
        nspx = sqrt(abs(gammax*xdisp**2 +two*talphax(ie)*xdisp*(xpgrd(j)*c1m3)+tbetax(ie)*(xpgrd(j)*c1m3)**2 )/myemitx0_collgap)
        nspy = sqrt(abs(gammay*(ygrd(j)*c1m3)**2 + two*talphay(ie)*(ygrd(j)*c1m3*ypgrd(j)*c1m3)+ tbetay(ie)*(ypgrd(j)*c1m3)**2 )&
   &           /myemity0_collgap)

!++  Populate the efficiency arrays at the end of each turn...
! Modified by M.Fiascaris, July 2016
        if(ie.eq.iu) then
          do ieff = 1, numeff
            if(counted_r(j,ieff).eq.0 .and. sqrt( &
            &((xineff(j)*c1m3)**2 + (talphax(ie)*xineff(j)*c1m3 + tbetax(ie)*xpineff(j)*c1m3)**2)/(tbetax(ie)*myemitx0_collgap)+&
            &((yineff(j)*c1m3)**2 + (talphay(ie)*yineff(j)*c1m3 + tbetay(ie)*ypineff(j)*c1m3)**2)/(tbetay(ie)*myemity0_collgap))&
            &.ge.rsig(ieff)) then
              neff(ieff) = neff(ieff)+one
              counted_r(j,ieff)=1
            end if

!++ 2D eff
            do ieffdpop = 1, numeffdpop
              if(counted2d(j,ieff,ieffdpop).eq.0 .and.abs((ejv(j)-myenom)/myenom).ge.dpopbins(ieffdpop)) then
                neff2d(ieff,ieffdpop) = neff2d(ieff,ieffdpop)+one
                counted2d(j,ieff,ieffdpop)=1
              end if
            end do

            if(counted_x(j,ieff).eq.0 .and.sqrt(((xineff(j)*c1m3)**2 + &
            &(talphax(ie)*xineff(j)*c1m3 + tbetax(ie)*xpineff(j)*c1m3)**2)/(tbetax(ie)*myemitx0_collgap)).ge.rsig(ieff)) then
              neffx(ieff) = neffx(ieff) + one
              counted_x(j,ieff)=1
            end if

            if(counted_y(j,ieff).eq.0 .and. &
            &sqrt(((yineff(j)*c1m3)**2 + (talphay(ie)*yineff(j)*c1m3 + tbetay(ie)*ypineff(j)*c1m3)**2)/ &
            &tbetay(ie)*myemity0_collgap).ge.rsig(ieff)) then
              neffy(ieff) = neffy(ieff) + one
              counted_y(j,ieff)=1
            end if
          end do !do ieff = 1, numeff

          do ieffdpop = 1, numeffdpop
            if(counteddpop(j,ieffdpop).eq.0) then
              dpopmin = zero
              mydpop = abs((ejv(j)-myenom)/myenom)
              if(ieffdpop.gt.1) dpopmin = dpopbins(ieffdpop-1)

              dpopmax = dpopbins(ieffdpop)
              if(mydpop.ge.dpopmin .and. mydpop.lt.mydpop) then
                npartdpop(ieffdpop)=npartdpop(ieffdpop)+1
              end if
            end if

            if(counteddpop(j,ieffdpop).eq.0 .and.abs((ejv(j)-myenom)/myenom).ge.dpopbins(ieffdpop)) then
              neffdpop(ieffdpop) = neffdpop(ieffdpop)+one
              counteddpop(j,ieffdpop)=1
            end if
          end do !do ieffdpop = 1, numeffdpop
        end if !if(ie.eq.iu) then

!++  Do an emittance drift
        driftx = driftsx*sqrt(tbetax(ie)*myemitx0_collgap)
        drifty = driftsy*sqrt(tbetay(ie)*myemity0_collgap)

        if(ie.eq.iu) then
          dnormx = driftx / sqrt(tbetax(ie)*myemitx0_collgap)
          dnormy = drifty / sqrt(tbetay(ie)*myemity0_collgap)
          xnorm  = (xgrd(j)*c1m3) / sqrt(tbetax(ie)*myemitx0_collgap)
          xpnorm = (talphax(ie)*(xgrd(j)*c1m3)+ tbetax(ie)*(xpgrd(j)*c1m3)) / sqrt(tbetax(ie)*myemitx0_collgap)
          xangle = atan2_mb(xnorm,xpnorm)
          xnorm  = xnorm  + dnormx*sin_mb(xangle)
          xpnorm = xpnorm + dnormx*cos_mb(xangle)
          xgrd(j)  = c1e3 * (xnorm * sqrt(tbetax(ie)*myemitx0_collgap))
          xpgrd(j) = c1e3 * ((xpnorm*sqrt(tbetax(ie)*myemitx0_collgap)-talphax(ie)*xgrd(j)*c1m3)/tbetax(ie))

          ynorm  = (ygrd(j)*c1m3)/ sqrt(tbetay(ie)*myemity0_collgap)
          ypnorm = (talphay(ie)*(ygrd(j)*c1m3)+tbetay(ie)*(ypgrd(j)*c1m3)) / sqrt(tbetay(ie)*myemity0_collgap)
          yangle = atan2_mb(ynorm,ypnorm)
          ynorm  = ynorm  + dnormy*sin_mb(yangle)
          ypnorm = ypnorm + dnormy*cos_mb(yangle)
          ygrd(j)  = c1e3 * (ynorm * sqrt(tbetay(ie)*myemity0_collgap))
          ypgrd(j) = c1e3 * ((ypnorm*sqrt(tbetay(ie)*myemity0_collgap)-talphay(ie)*ygrd(j)*c1m3)/tbetay(ie))
        end if

!------------------------------------------------------------------------
!++  End of check for selection flag and absorption
      end if
!++  End of do loop over particles
    end do
!_________________________________________________________________
!++  End of collimation efficiency analysis for selected particles
  end if

!------------------------------------------------------------------
!++  For LAST ELEMENT in the ring compact the arrays by moving all
!++  lost particles to the end of the array.
  if(ie.eq.iu) then
    imov = 0
    do j = 1, napx
      if(xgrd(j).lt.99.0_fPrec .and. ygrd(j).lt.99.0_fPrec) then
        imov = imov + 1
        xgrd(imov)           = xgrd(j)
        ygrd(imov)           = ygrd(j)
        xpgrd(imov)          = xpgrd(j)
        ypgrd(imov)          = ypgrd(j)
        pgrd(imov)           = pgrd(j)
        ejfvgrd(imov)        = ejfvgrd(j)
        sigmvgrd(imov)       = sigmvgrd(j)
        rvvgrd(imov)         = rvvgrd(j)
        dpsvgrd(imov)        = dpsvgrd(j)
        oidpsvgrd(imov)      = oidpsvgrd(j)
        dpsv1grd(imov)       = dpsv1grd(j)
        part_hit_pos(imov)   = part_hit_pos(j)
        part_hit_turn(imov)  = part_hit_turn(j)
        part_abs_pos(imov)   = part_abs_pos(j)
        part_abs_turn(imov)  = part_abs_turn(j)
        part_select(imov)    = part_select(j)
        part_impact(imov)    = part_impact(j)
        part_indiv(imov)     = part_indiv(j)
        part_linteract(imov) = part_linteract(j)
        part_hit_before_pos(imov)  = part_hit_before_pos(j)
        part_hit_before_turn(imov) = part_hit_before_turn(j)
        secondary(imov) = secondary(j)
        tertiary(imov) = tertiary(j)
        other(imov) = other(j)
        scatterhit(imov) = scatterhit(j)
        nabs_type(imov) = nabs_type(j)
!GRD HERE WE ADD A MARKER FOR THE PARTICLE FORMER NAME
        ipart(imov) = ipart(j)
        flukaname(imov) = flukaname(j)
!KNS: Also compact nlostp (used for standard LOST calculations + output)
        nlostp(imov) = nlostp(j)
        do ieff = 1, numeff
          counted_r(imov,ieff) = counted_r(j,ieff)
          counted_x(imov,ieff) = counted_x(j,ieff)
          counted_y(imov,ieff) = counted_y(j,ieff)
        end do
      end if
    end do
     write(lout,*) 'INFO>  Compacted the particle distributions: ', napx, ' -->  ', imov, ", turn =",iturn
     flush(lout)
    napx = imov
  endif

  ! Write final distribution
  if(dowrite_dist .and. ie == iu .and. iturn == numl) then
#ifdef HDF5
    if(h5_useForCOLL) then
      allocate(fldHdf(6))
      fldHdf(1) = h5_dataField(name="X",  type=h5_typeReal)
      fldHdf(2) = h5_dataField(name="XP", type=h5_typeReal)
      fldHdf(3) = h5_dataField(name="Y",  type=h5_typeReal)
      fldHdf(4) = h5_dataField(name="YP", type=h5_typeReal)
      fldHdf(5) = h5_dataField(name="Z",  type=h5_typeReal)
      fldHdf(6) = h5_dataField(name="E",  type=h5_typeReal)
      call h5_createFormat("collDistN", fldHdf, fmtHdf)
      call h5_createDataSet("distn", h5_collID, fmtHdf, setHdf, napx)
      call h5_prepareWrite(setHdf, napx)
      call h5_writeData(setHdf, 1, napx, (xgrd(1:napx) -torbx(1)) /c1e3)
      call h5_writeData(setHdf, 2, napx, (xpgrd(1:napx)-torbxp(1))/c1e3)
      call h5_writeData(setHdf, 3, napx, (ygrd(1:napx) -torby(1)) /c1e3)
      call h5_writeData(setHdf, 4, napx, (ypgrd(1:napx)-torbyp(1))/c1e3)
      call h5_writeData(setHdf, 5, napx, sigmvgrd(1:napx))
      call h5_writeData(setHdf, 6, napx, ejfvgrd(1:napx))
      call h5_finaliseWrite(setHdf)
      deallocate(fldHdf)
    else
#endif
      call funit_requestUnit('distn.dat', distn_unit)
      open(unit=distn_unit, file='distn.dat') !was 9998
      write(distn_unit,*) '# 1=x 2=xp 3=y 4=yp 5=z 6 =E'
      do j = 1, napx
        write(distn_unit,'(6(1X,E23.15))') (xgrd(j)-torbx(1))/c1e3, (xpgrd(j)-torbxp(1))/c1e3, (ygrd(j)-torby(1))/c1e3, &
          (ypgrd(j)-torbyp(1))/c1e3, sigmvgrd(j), ejfvgrd(j)
      end do
      close(distn_unit)
#ifdef HDF5
    end if
#endif
  end if

!GRD NOW ONE HAS TO COPY BACK THE NEW DISTRIBUTION TO ITS "ORIGINAL NAME"
!GRD AT THE END OF EACH TURN
  if(ie.eq.iu) then
    do j = 1,napx
      xv(1,j) = xgrd(j)
      yv(1,j) = xpgrd(j)
      xv(2,j) = ygrd(j)
      yv(2,j) = ypgrd(j)
      ejv(j)  = pgrd(j)
      ejfv(j)   = ejfvgrd(j)
      sigmv(j)  = sigmvgrd(j)
      rvv(j)    = rvvgrd(j)
      dpsv(j)   = dpsvgrd(j)
      oidpsv(j) = oidpsvgrd(j)
      dpsv1(j)  = dpsv1grd(j)
    end do
  end if

  if(firstrun) then
    if(rselect.gt.0 .and. rselect.lt.65) then
      do j = 1, napx
        xj  = (xv(1,j)-torbx(ie)) /c1e3
        xpj = (yv(1,j)-torbxp(ie))/c1e3
        yj  = (xv(2,j)-torby(ie)) /c1e3
        ypj = (yv(2,j)-torbyp(ie))/c1e3
        pj  = ejv(j)/c1e3

        if(iturn.eq.1.and.j.eq.1) then
          sum_ax(ie)=zero
          sum_ay(ie)=zero
        end if

        if(tbetax(ie).gt.0.) then
          gammax = (one + talphax(ie)**2)/tbetax(ie)
          gammay = (one + talphay(ie)**2)/tbetay(ie)
        else
          gammax = (one + talphax(ie-1)**2)/tbetax(ie-1)
          gammay = (one + talphay(ie-1)**2)/tbetay(ie-1)
        end if

        if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
          if(tbetax(ie).gt.0.) then
            nspx = sqrt(abs( gammax*(xj)**2 + two*talphax(ie)*xj*xpj + tbetax(ie)*xpj**2 )/myemitx0_collgap)
            nspy = sqrt(abs( gammay*(yj)**2 + two*talphay(ie)*yj*ypj + tbetay(ie)*ypj**2 )/myemity0_collgap)
          else
            nspx = sqrt(abs( gammax*(xj)**2 + two*talphax(ie-1)*xj*xpj +tbetax(ie-1)*xpj**2 )/myemitx0_collgap)
            nspy = sqrt(abs( gammay*(yj)**2 + two*talphay(ie-1)*yj*ypj +tbetay(ie-1)*ypj**2 )/myemity0_collgap)
          end if

          sum_ax(ie)   = sum_ax(ie) + nspx
          sqsum_ax(ie) = sqsum_ax(ie) + nspx**2
          sum_ay(ie)   = sum_ay(ie) + nspy
          sqsum_ay(ie) = sqsum_ay(ie) + nspy**2
          nampl(ie)    = nampl(ie) + 1
          sampl(ie)    = totals
          ename(ie)    = bez(myix)(1:max_name_len)
        else
          nspx = zero
          nspy = zero
        end if !if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
      end do !do j = 1, napx
    end if !if(rselect.gt.0 .and. rselect.lt.65) then
  end if !if(firstrun) then

!GRD THIS LOOP MUST NOT BE WRITTEN INTO THE "IF(FIRSTRUN)" LOOP !!!!
  if(dowritetracks) then
    do j = 1, napx
      xj    = (xv(1,j)-torbx(ie))/c1e3
      xpj   = (yv(1,j)-torbxp(ie))/c1e3
      yj    = (xv(2,j)-torby(ie))/c1e3
      ypj   = (yv(2,j)-torbyp(ie))/c1e3
      arcdx = 2.5_fPrec
      arcbetax = c180e0

      if(xj.le.0.) then
        xdisp = xj + (pj-myenom)/myenom * arcdx * sqrt(tbetax(ie)/arcbetax)
      else
        xdisp = xj - (pj-myenom)/myenom * arcdx * sqrt(tbetax(ie)/arcbetax)
      end if

      xndisp = xj
      nspxd  = sqrt(abs(gammax*xdisp**2  + two*talphax(ie)*xdisp*xpj  + tbetax(ie)*xpj**2)/myemitx0_collgap)
      nspx   = sqrt(abs(gammax*xndisp**2 + two*talphax(ie)*xndisp*xpj + tbetax(ie)*xpj**2)/myemitx0_collgap)
      nspy   = sqrt(abs( gammay*yj**2    + two*talphay(ie)*yj*ypj     + tbetay(ie)*ypj**2)/myemity0_collgap)

      if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
!GRD HERE WE APPLY THE SAME KIND OF CUT THAN THE SIGSECUT PARAMETER
        if((secondary(j) .eq. 1 .or. &
            tertiary(j)  .eq. 2 .or. &
            other(j)     .eq. 4 .or. &
            scatterhit(j).eq. 8        ) .and. &
            (xv(1,j).lt.99.0_fPrec .and. xv(2,j).lt.99.0_fPrec) .and. &
            ((((xv(1,j)*c1m3)**2 / (tbetax(ie)*myemitx0_collgap)) .ge. real(sigsecut2,fPrec)).or. &
            (((xv(2,j)*c1m3)**2  / (tbetay(ie)*myemity0_collgap)) .ge. real(sigsecut2,fPrec)).or. &
            (((xv(1,j)*c1m3)**2  / (tbetax(ie)*myemitx0_collgap)) + &
            ((xv(2,j)*c1m3)**2  / (tbetay(ie)*myemity0_collgap)) .ge. sigsecut3)) ) &
            then

          xj     = (xv(1,j)-torbx(ie))/c1e3
          xpj    = (yv(1,j)-torbxp(ie))/c1e3
          yj     = (xv(2,j)-torby(ie))/c1e3
          ypj    = (yv(2,j)-torbyp(ie))/c1e3
#ifdef HDF5
          if(h5_writeTracks2) then
            hdfpid=ipart(j)
            hdfturn=iturn
            hdfs=sampl(ie)
            hdfx=xv(1,j)
            hdfxp=yv(1,j)
            hdfy=xv(2,j)
            hdfyp=yv(2,j)
            hdfdee=(ejv(j)-myenom)/myenom
            hdftyp=secondary(j)+tertiary(j)+other(j)+scatterhit(j)
            call h5tr2_writeLine(hdfpid,hdfturn,hdfs,hdfx,hdfxp,hdfy,hdfyp,hdfdee,hdftyp)
          else
#endif
            write(tracks2_unit,'(1x,i8,1x,i4,1x,f10.2,4(1x,e11.5),1x,e11.3,1x,i4)') ipart(j),iturn,sampl(ie), &
              xv(1,j),yv(1,j),xv(2,j),yv(2,j),(ejv(j)-myenom)/myenom,secondary(j)+tertiary(j)+other(j)+scatterhit(j)
#ifdef HDF5
          end if
#endif
        end if !if ((secondary(j).eq.1.or.tertiary(j).eq.2.or.other(j).eq.4.or.scatterhit(j).eq.8
      end if !if(part_abs_pos(j).eq.0 .and. part_abs_turn(j).eq.0) then
    end do ! do j = 1, napx
  end if !if(dowritetracks) then
!=======================================================================
end subroutine collimate_end_turn

!>
!! "Merlin" scattering collimation configuration
!! This routine pre-calcuates some varibles for
!! the nuclear properties
!<
subroutine collimate_init_merlin()

  implicit none

  integer i
!+ca interac

! compute the electron densnity and plasma energy for each material
  do i=1, nmat
    edens(i) = CalcElectronDensity(zatom(i),rho(i),anuc(i))
    pleng(i) = CalcPlasmaEnergy(edens(i))
  end do

end subroutine collimate_init_merlin

!>
!! K2 scattering collimation configuration
!<
subroutine collimate_init_k2()
!nothing currently
end subroutine collimate_init_k2

!>
!! subroutine collimate2(c_material, c_length, c_rotation,           &
!!-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----
!!----                                                                    -----
!!-----  NEW ROUTINES PROVIDED FOR THE COLLIMATION STUDIES VIA SIXTRACK   -----
!!-----                                                                   -----
!!-----          G. ROBERT-DEMOLAIZE, November 1st, 2004                  -----
!!-----                                                                   -----
!!-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----
!!++  Based on routines by JBJ. Changed by RA 2001.
!!GRD
!!GRD MODIFIED VERSION FOR COLLIMATION SYSTEM: G. ROBERT-DEMOLAIZE
!!GRD
!!
!!++  - Deleted all HBOOK stuff.
!!++  - Deleted optics routine and all parser routines.
!!++  - Replaced RANMAR call by RANLUX call
!!++  - Included RANLUX code from CERNLIB into source
!!++  - Changed dimensions from CGen(100,nmat) to CGen(200,nmat)
!!++  - Replaced FUNPRE with FUNLXP
!!++  - Replaced FUNRAN with FUNLUX
!!++  - Included all CERNLIB code into source: RANLUX, FUNLXP, FUNLUX,
!!++                                         FUNPCT, FUNLZ, RADAPT,
!!++                                           RGS56P
!!++    with additional entries:             RLUXIN, RLUXUT, RLUXAT,
!!++                                           RLUXGO
!!++
!!++  - Changed program so that Nev is total number of particles
!!++    (scattered and not-scattered)
!!++  - Added debug comments
!!++  - Put real dp/dx
!<
subroutine collimate2(c_material, c_length, c_rotation,           &
     &c_aperture, c_offset, c_tilt,x_in, xp_in, y_in,yp_in,p_in, s_in,  &
     &     np, enom,                                                    &
     &     lhit_pos, lhit_turn,                                         &
     &     part_abs_pos_local, part_abs_turn_local,                     &
     &     impact, indiv, lint, onesided,name,                          &
     &     flagsec, j_slices, nabs_type)

  use crcoall
  use parpro
  use mod_common, only : iexact
  implicit none

! BLOCK DBCOLLIM
! This block is common to collimaterhic and collimate2
! It is NOT compatible with block DBCOMMON, as some variable names overlap...


  logical onesided,hit
! integer nprim,filel,mat,nev,j,nabs,nhit,np,icoll,nabs_tmp
  integer nprim,filel,j,nabs,nhit,np,nabs_tmp

  integer :: lhit_pos(npart) !(npart)
  integer :: lhit_turn(npart) !(npart)
  integer :: part_abs_pos_local(npart) !(npart)
  integer :: part_abs_turn_local(npart) !(npart)
  integer :: name(npart) !(npart)
  integer :: nabs_type(npart) !(npart)
!MAY2005

  real(kind=fPrec) :: x_in(npart) !(npart)
  real(kind=fPrec) :: xp_in(npart) !(npart)
  real(kind=fPrec) :: y_in(npart) !(npart)
  real(kind=fPrec) :: yp_in(npart) !(npart)
  real(kind=fPrec) :: p_in(npart) !(npart)
  real(kind=fPrec) :: s_in(npart) !(npart)
  real(kind=fPrec) :: indiv(npart) !(npart)
  real(kind=fPrec) :: lint(npart) !(npart)
  real(kind=fPrec) :: impact(npart) !(npart)
  real(kind=fPrec) keeps,fracab,sigx,sigz,norma,xpmu,drift_length,mirror,tiltangle

  real(kind=fPrec) c_length    !length in m
  real(kind=fPrec) c_rotation  !rotation angle vs vertical in radian
  real(kind=fPrec) c_aperture  !aperture in m
  real(kind=fPrec) c_offset    !offset in m
  real(kind=fPrec) c_tilt(2)   !tilt in radian
  character(len=4) c_material  !material

  character(nc) filen,tit

  real(kind=fPrec) xlow,xhigh,xplow,xphigh,dx,dxp
  real(kind=fPrec) x00,z00,p,sp,s,enom

  data dx,dxp/.5e-4,20.e-4/                                        !hr09

!AUGUST2006 Added ran_gauss for generation of pencil/     ------- TW
!           sheet beam distribution  (smear in x and y)
!
!+ca dbcollim

  real(kind=fPrec) x_flk,xp_flk,y_flk,yp_flk,zpj

  real(kind=fPrec) s_impact
  integer flagsec(npart)

!     SR, 18-08-2005: add temporary variable to write in FirstImpacts
!     the initial distribution of the impacting particles in the
!     collimator frame.
  real(kind=fPrec) xinn,xpinn,yinn,ypinn

!     SR, 29-08-2005: add the slice number to calculate the impact
!     location within the collimator.
!     j_slices = 1 for the a non sliced collimator!
  integer j_slices

  save
!      write(lout,*) 'In col2 ', c_material, c_length, c_aperture,       &
!     &c_offset, c_tilt, x_in, xp_in, y_in,p_in, np, enom
!=======================================================================
! Be=1 Al=2 Cu=3 W=4 Pb=5
! LHC uses:    Al, 0.2 m
!              Cu, 1.0 m

  if(c_material.eq.'BE') then
    mat = 1
  else if(c_material.eq.'AL') then
    mat = 2
  else if(c_material.eq.'CU') then
    mat = 3
  else if(c_material.eq.'W') then
    mat = 4
  else if(c_material.eq.'PB') then
    mat = 5
  else if(c_material.eq.'C') then
    mat = 6
  else if(c_material.eq.'C2') then
    mat = 7
  else if(c_material.eq.'MoGR') then
    mat = 8
  else if(c_material.eq.'CuCD') then
    mat = 9
  else if(c_material.eq.'Mo') then
    mat = 10
  else if(c_material.eq.'Glid') then
    mat = 11
  else if(c_material.eq.'Iner') then
    mat = 12
!02/2008 TW added vacuum and black absorber (was missing)
  else if(c_material.eq.'VA') then
    mat = nmat-1
  else if(c_material.eq.'BL') then
    mat = nmat
  else
    write(lout,*)
    write(lout,*) 'ERR>  In subroutine collimate2:'
    write(lout,*) 'ERR>  Material "', c_material, '" not found.'
    write(lout,*) 'ERR>  Check your CollDB! Stopping now.'
    call prror(-1)
  end if

  length  = c_length
  nev = np
  p0  = enom

!++  Initialize scattering processes
  call scatin(p0)

! EVENT LOOP,  initial distribution is here a flat distribution with
! xmin=x-, xmax=x+, etc. from the input file

  nhit    = 0
  fracab  = zero
  mirror  = one

!==> SLICE here

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  do j = 1, nev
! SR-GRD (04-08-2005):
!   Don't do scattering process for particles already absorbed
    if ( part_abs_pos_local(j) .ne. 0 .and. part_abs_turn_local(j) .ne. 0) goto 777

    impact(j) = -one
    lint(j)   = -one
    indiv(j)  = -one

    x   = x_in(j)
    xp  = xp_in(j)
    z   = y_in(j)
    zp  = yp_in(j)
    p   = p_in(j)
    sp   = zero
    dpop = (p - p0)/p0
    x_flk  = zero
    y_flk  = zero
    xp_flk = zero
    yp_flk = zero

!++  Transform particle coordinates to get into collimator coordinate
!++  system
!
!++  First check whether particle was lost before
!        if (x.lt.99d-3 .and. z.lt.99d-3) then
!++  First do rotation into collimator frame
    x  = x_in(j) *cos_mb(c_rotation)+sin_mb(c_rotation)*y_in(j)
    z  = y_in(j) *cos_mb(c_rotation)-sin_mb(c_rotation)*x_in(j)
    xp = xp_in(j)*cos_mb(c_rotation)+sin_mb(c_rotation)*yp_in(j)
    zp = yp_in(j)*cos_mb(c_rotation)-sin_mb(c_rotation)*xp_in(j)
!
!++  For one-sided collimators consider only positive X. For negative
!++  X jump to the next particle


! RB: adding exception from goto if it's
    if ((onesided .and. x.lt.zero).and. ((icoll.ne.ipencil) .or. (iturn.ne.1))) goto 777

!++  Now mirror at the horizontal axis for negative X offset
    if(x.lt.zero) then                                             !hr09
      mirror = -one
      tiltangle = -one*c_tilt(2)
    end if

    if(x.ge.zero) then                                             !hr09
      mirror = one
      tiltangle = c_tilt(1)
    end if

    x  = mirror * x
    xp = mirror * xp
!
!          if (j.eq.1) then
!             write(*,*) 'INFOtilt',
!     &            icoll, j_slices, c_tilt(1), c_tilt(2),
!     &            mirror, tiltangle, c_offset, c_aperture/2
!          endif
!
!++  Shift with opening and offset
!
    x  = (x - c_aperture/two) - mirror*c_offset                    !hr09
!
!++  Include collimator tilt
!
    if(tiltangle.gt.zero) then                                    !hr09
      xp = xp - tiltangle
    end if

    if(tiltangle.lt.zero) then
      x  = x + sin_mb(tiltangle) * c_length
      xp = xp - tiltangle
    end if

!++  For selected collimator, first turn reset particle distribution
!++  to simple pencil beam
!
! -- TW why did I set this to 0, seems to be needed for getting
!       right amplitude => no "tilt" of jaw for the first turn !!!!
!          c_tilt(1) = 0d0
!          c_tilt(2) = 0d0

    nprim = 3

    if(( (icoll.eq.ipencil .and. iturn.eq.1) .or. (iturn.eq.1.and. ipencil.eq.999 .and. icoll.le.nprim .and. &
 &    (j.ge.(icoll-1)*nev/nprim) .and. (j.le.(icoll)*nev/nprim))).and.(pencil_distr.ne.3)) then
! RB addition : don't go in this if-statement if pencil_distr=3. This distribution is generated in main loop instead

! -- TW why did I set this to 0, seems to be needed for getting
!       right amplitude => no "tilt" of jaw for the first turn !!!!
      c_tilt(1) = zero
      c_tilt(2) = zero

!AUGUST2006: Standard pencil beam as implemented by GRD ------- TW
      if(pencil_rmsx.eq.zero .and. pencil_rmsy.eq.zero) then     !hr09
        x  = pencil_dx(icoll)
        xp = zero
        z  = zero
        zp = zero
      end if

!AUGUST2006: Rectangular (pencil-beam) sheet-beam with  ------ TW
!            pencil_offset is the rectangulars center
!            pencil_rmsx defines spread of impact parameter
!            pencil_rmsy defines spread parallel to jaw surface

      if(pencil_distr.eq.0 .and.(pencil_rmsx.ne.0..or.pencil_rmsy.ne.0.)) then
! how to assure that all generated particles are on the jaw ?!
        x  = pencil_dx(icoll)+pencil_rmsx*(real(rndm4(),fPrec)-half)
        xp = zero
        z  = pencil_rmsy*(real(rndm4(),fPrec)-half)
        zp = zero
      end if

!AUGUST2006: Gaussian (pencil-beam) sheet-beam with ------- TW
!            pencil_offset is the mean  gaussian distribution
!            pencil_rmsx defines spread of impact parameter
!            pencil_rmsy defines spread parallel to jaw surface

      if(pencil_distr.eq.1 .and.(pencil_rmsx.ne.zero.or.pencil_rmsy.ne.zero )) then
        x  = pencil_dx(icoll) + pencil_rmsx*ran_gauss(two)
! all generated particles are on the jaw now
        x  = sqrt(x**2)
        xp = zero
        z  = pencil_rmsy*ran_gauss(two)
        zp = zero
      end if

!AUGUST2006: Gaussian (pencil-beam) sheet-beam with ------- TW
!            pencil_offset is the mean  gaussian distribution
!            pencil_rmsx defines spread of impact parameter
!                        here pencil_rmsx is not gaussian!!!
!            pencil_rmsy defines spread parallel to jaw surface

      if(pencil_distr.eq.2 .and.(pencil_rmsx.ne.zero.or.pencil_rmsy.ne.zero )) then   !hr09
        x  = pencil_dx(icoll) + pencil_rmsx*(real(rndm4(),fPrec)-half)                  !hr09
! all generated particles are on the jaw now
        x  = sqrt(x**2)
        xp = zero
        z  = pencil_rmsy*ran_gauss(two)
        zp = zero
      end if

!JULY2007: Selection of pos./neg. jaw  implemented by GRD ---- TW

! ensure that for onesided only particles on pos. jaw are created
      if(onesided) then
        mirror = one
      else
!     if(rndm4().lt.0.5) mirror = -1d0
!     if(rndm4().ge.0.5) mirror = 1d0  => using two different random
        if(rndm4().lt.half) then
          mirror = -one
        else
          mirror = one
        end if
      end if

! -- TW SEP07 if c_tilt is set to zero before entering pencil beam
!             section the assigning of the tilt will result in
!             assigning zeros
      if(mirror.lt.zero) then                                     !hr09
!!     tiltangle = -one*c_tilt(2)
        tiltangle = c_tilt(2)
      else
        tiltangle = c_tilt(1)
      end if
!!!!--- commented this out since particle is tilted after leaving
!!!!--- collimator -> remove this  code fragment in final verion
!!             x  = mirror * x
!!             xp = mirror * xp


!++  Include collimator tilt
! this is propably not correct
!
!             xp =  (xp_pencil0*cos_mb(c_rotation)+                         &
!     &            sin_mb(c_rotation)*yp_pencil0)
!             if (tiltangle.gt.0.) then
!                xp = xp - tiltangle
!!             endif
!!             elseif (tiltangle.lt.0.) then
!             else
!               x  = x + sin_mb(tiltangle) * c_length
!               xp = xp - tiltangle
!             endif
!
      write(pencilbeam_distr_unit,'(f10.8,(2x,f10.8),(2x,f10.8),(2x,f10.8),(2x,f10.8))') x, xp, z, zp, tiltangle

    end if !if(( (icoll.eq.ipencil .and. iturn.eq.1) .or. (itu

!          if(rndm4().lt.0.5) mirror = -abs(mirror)
!          if(rndm4().ge.0.5) mirror = abs(mirror)
!        endif
!
!     SR, 18-08-2005: after finishing the coordinate transformation,
!     or the coordinate manipulations in case of pencil beams,
!     write down the initial coordinates of the impacting particles
    xinn  = x
    xpinn = xp
    yinn  = z
    ypinn = zp
!
!++  Possibility to slice here (RA,SR: 29-08-2005)
!
!++  particle passing above the jaw are discarded => take new event
!++  entering by the face, shorten the length (zlm) and keep track of
!++  entrance longitudinal coordinate (keeps) for histograms
!
!++  The definition is that the collimator jaw is at x>=0.
!
!++  1) Check whether particle hits the collimator
    hit   = .false.
    s     = zero                                                !hr09
    keeps = zero                                                !hr09
    zlm   = -one * length

    if(x.ge.zero) then                                            !hr09

!++  Particle hits collimator and we assume interaction length ZLM equal
!++  to collimator length (what if it would leave collimator after
!++  small length due to angle???)
      zlm = length
      impact(j) = x
      indiv(j) = xp
    else if(xp.le.zero) then                                      !hr09

!++  Particle does not hit collimator. Interaction length ZLM is zero.
      zlm = zero
    else
!
!++  Calculate s-coordinate of interaction point
      s = (-one*x) / xp
      if(s.le.0) then
        write(lout,*) 'S.LE.0 -> This should not happen'
        call prror(-1)
      end if

      if(s .lt. length) then
        zlm = length - s
        impact(j) = zero
        indiv(j) = xp
      else
        zlm = zero
      end if
    end if !if(x.ge.0.d0) then

!++  First do the drift part
! DRIFT PART
    drift_length = length - zlm
    if(drift_length.gt.zero) then                                 !hr09
      if(iexact.eq.0) then
        x  = x + xp* drift_length
        z  = z + zp * drift_length
        sp = sp + drift_length
      else
        zpj = sqrt(one-xp**2-zp**2)
        x = x + drift_length*(xp/zpj)
        z = z + drift_length*(zp/zpj)
        sp = sp + drift_length
      end if
    end if
!
!++  Now do the scattering part
!
    if (zlm.gt.zero) then
!JUNE2005
      s_impact = sp
!JUNE2005
      nhit = nhit + 1
!            WRITE(*,*) J,X,XP,Z,ZP,SP,DPOP
!     RB: add new input arguments to jaw icoll,iturn,ipart for writeout
      call jaw(s, nabs, icoll,iturn,name(j),dowrite_impact)

      nabs_type(j) = nabs
!JUNE2005
!JUNE2005 SR+GRD: CREATE A FILE TO CHECK THE VALUES OF IMPACT PARAMETERS
!JUNE2005
!     SR, 29-08-2005: Add to the longitudinal coordinates the position
!     of the slice beginning

      if(dowrite_impact) then
        if(flagsec(j).eq.0) then
#ifdef HDF5
          if(h5_useForCOLL) then
            call h5_prepareWrite(coll_hdf5_fstImpacts, 1)
            call h5_writeData(coll_hdf5_fstImpacts, 1,  1, name(j))
            call h5_writeData(coll_hdf5_fstImpacts, 2,  1, iturn)
            call h5_writeData(coll_hdf5_fstImpacts, 3,  1, icoll)
            call h5_writeData(coll_hdf5_fstImpacts, 4,  1, nabs)
            call h5_writeData(coll_hdf5_fstImpacts, 5,  1, s_impact + (real(j_slices,fPrec)-one) * c_length)
            call h5_writeData(coll_hdf5_fstImpacts, 6,  1, s+sp + (real(j_slices,fPrec)-one) * c_length)
            call h5_writeData(coll_hdf5_fstImpacts, 7,  1, xinn)
            call h5_writeData(coll_hdf5_fstImpacts, 8,  1, xpinn)
            call h5_writeData(coll_hdf5_fstImpacts, 9,  1, yinn)
            call h5_writeData(coll_hdf5_fstImpacts, 10, 1, ypinn)
            call h5_writeData(coll_hdf5_fstImpacts, 11, 1, x)
            call h5_writeData(coll_hdf5_fstImpacts, 12, 1, xp)
            call h5_writeData(coll_hdf5_fstImpacts, 13, 1, z)
            call h5_writeData(coll_hdf5_fstImpacts, 14, 1, zp)
            call h5_finaliseWrite(coll_hdf5_fstImpacts)
          else
#endif
            write(FirstImpacts_unit,'(i5,1x,i7,1x,i2,1x,i1,2(1x,f5.3),8(1x,e17.9))') &
                name(j),iturn,icoll,nabs,                               &
                s_impact + (real(j_slices,fPrec)-one) * c_length,       &
                s+sp + (real(j_slices,fPrec)-one) * c_length,           &
                xinn,xpinn,yinn,ypinn,                                  &
                x,xp,z,zp
#ifdef HDF5
          end if
#endif
        end if
      end if
!!     SR, 18-08-2005: add also the initial coordinates of the
!!                     impacting particles!
!            if(flagsec(j).eq.0) then
!              write(333,'(i5,1x,i7,1x,i2,1x,i1,2(1x,f5.3),8(1x,e17.9))')&
!     +              name(j),iturn,icoll,nabs,s_impact,s+sp,
!     +              xinn,xpinn,yinn,ypinn,
!     +              x,xp,z,zp
!            endif
!     !Old format...
!            if(flagsec(j).eq.0) then
!              write(333,'(i5,1x,i4,1x,i2,1x,i1,2(1x,f5.3),2(1x,e16.7))')
!     &name(j),iturn,icoll,nabs,s_impact,s+sp,impact(j),x
!            endif
!JUNE2005

      lhit_pos(j)  = ie
      lhit_turn(j) = iturn

!-- September2006  TW added from Ralphs code
!--------------------------------------------------------------
!++ Change tilt for pencil beam impact
!
!            if ( (icoll.eq.ipencil                                      &
!     &           .and. iturn.eq.1)   .or.                               &
!     &           (iturn.eq.1 .and. ipencil.eq.999 .and.                 &
!     &                             icoll.le.nprim .and.                 &
!     &            (j.ge.(icoll-1)*nev/nprim) .and.                      &
!     &            (j.le.(icoll)*nev/nprim)                              &
!     &           )  ) then
!
!               if (.not. changed_tilt1(icoll) .and. mirror.gt.0.) then
! ----- Maybe a warning would be nice that c_tilt is overwritten !!!!!
! changed xp_pencil0(icoll) to xp_pencil0 due to definition mismatch
! this has to be solved if necassary and understood
!                 c_tilt(1) = xp_pencil0(icoll)*cos_mb(c_rotation)+         &
!     &                       sin_mb(c_rotation)*yp_pencil0(icoll)
!                 c_tilt(1) = xp_pencil0*cos_mb(c_rotation)+                &
!     &                       sin_mb(c_rotation)*yp_pencil0
!                 write(*,*) "INFO> Changed tilt1  ICOLL  to  ANGLE  ",  &
!     &                   icoll, c_tilt(1), j
!                 changed_tilt1(icoll) = .true.
!               elseif (.not. changed_tilt2(icoll)                       &
!     &                                   .and. mirror.lt.0.) then
! changed xp_pencil0(icoll) to xp_pencil0 due to definition mismatch
! this has to be solved if necassary and understood
!                 c_tilt(2) = -1.*(xp_pencil0(icoll)*cos_mb(c_rotation)+    &
!     &                       sin_mb(c_rotation)*yp_pencil0(icoll))
!                 c_tilt(2) = -1.*(xp_pencil0*cos_mb(c_rotation)+           &
!     &                       sin_mb(c_rotation)*yp_pencil0)
!                 write(*,*) "INFO> Changed tilt2  ICOLL  to  ANGLE  ",  &
!     &                   icoll, c_tilt(2), j
!                 changed_tilt2(icoll) = .true.
!               endif
!            endif
!
!----------------------------------------------------------------
!-- September 2006
!
!++  If particle is absorbed then set x and y to 99.99 mm
!     SR: before assigning new (x,y) for nabs=1, write the
!     inelastic impact file .

!     RB: writeout should be done for both inelastic and single diffractive. doing all transformations in x_flk and making the set to 99.99 mm conditional for nabs=1
!!! /* start RB fix */

! transform back to lab system for writeout.
! keep x,y,xp,yp unchanged for continued tracking, store lab system variables in x_flk etc

      x_flk = xInt
      xp_flk = xpInt

      if(tiltangle.gt.zero) then
        x_flk  = x_flk  + tiltangle*(sInt+sp)
        xp_flk = xp_flk + tiltangle
      else if(tiltangle.lt.zero) then
        xp_flk = xp_flk + tiltangle
        x_flk  = x_flk - sin_mb(tiltangle) * ( length -(sInt+sp) )
      end if

      x_flk  = (x_flk + c_aperture/two) + mirror*c_offset
      x_flk  = mirror * x_flk
      xp_flk = mirror * xp_flk
      y_flk  = yInt   * cos_mb(-one*c_rotation) - x_flk  * sin_mb(-one*c_rotation)
      yp_flk = ypInt  * cos_mb(-one*c_rotation) - xp_flk * sin_mb(-one*c_rotation)
      x_flk  = x_flk  * cos_mb(-one*c_rotation) + yInt   * sin_mb(-one*c_rotation)
      xp_flk = xp_flk * cos_mb(-one*c_rotation) + ypInt  * sin_mb(-one*c_rotation)

! write out all impacts to all_impacts.dat
      if(dowrite_impact) then
        write(FLUKA_impacts_all_unit,'(i4,(1x,f6.3),(1x,f8.6),4(1x,e19.10),i2,2(1x,i7))') &
     &              icoll,c_rotation,                                   &
     &              sInt + sp + (real(j_slices,fPrec)-one) * c_length,  &
     &              x_flk*c1e3, xp_flk*c1e3, y_flk*c1e3, yp_flk*c1e3,   &
     &              nabs,name(j),iturn
      end if

! standard FLUKA_impacts writeout of inelastic and single diffractive
      if((nabs.eq.1).OR.(nabs.eq.4)) then

!     SR, 29-08-2005: Include the slice numer!
        if(dowrite_impact) then
          write(FLUKA_impacts_unit,'(i4,(1x,f6.3),(1x,f8.6),4(1x,e19.10),i2,2(1x,i7))') &
     &icoll,c_rotation,                                                 &
     &sInt + sp + (real(j_slices,fPrec)-one) * c_length,                &!hr09
     &x_flk*c1e3, xp_flk*c1e3, y_flk*c1e3, yp_flk*c1e3,                 &
     &nabs,name(j),iturn
        end if
!
!     Finally, the actual coordinate change to 99 mm
        if(nabs.eq.1) then
          fracab = fracab + 1
          x = 99.99e-3_fPrec
          z = 99.99e-3_fPrec
          part_abs_pos_local(j) = ie
          part_abs_turn_local(j) = iturn
          lint(j) = zlm
        end if
      end if !if((nabs.eq.1).OR.(nabs.eq.4)) then
    end if !if (zlm.gt.0.) then
!!! /* end RB fix */

!++  Do the rest drift, if particle left collimator early
!  DRIFT PART
    if(nabs.ne.1 .and. zlm.gt.zero) then
      drift_length = (length-(s+sp))
      if(drift_length.gt.c1m15) then
        if(iexact.eq.0) then
          x  = x + xp * drift_length
          z  = z + zp * drift_length
          sp = sp + drift_length
        else
          zpj = sqrt(one-xp**2-zp**2)
          x = x + drift_length*(xp/zpj)
          z = z + drift_length*(zp/zpj)
          sp = sp + drift_length
        end if
      end if
      lint(j) = zlm - drift_length
    end if

!++  Transform back to particle coordinates with opening and offset
    if(x.lt.99.0d-3) then

!++  Include collimator tilt
      if(tiltangle.gt.zero) then                                 !hr09
        x  = x  + tiltangle*c_length
        xp = xp + tiltangle
      else if(tiltangle.lt.zero) then                             !hr09
        x  = x + tiltangle*c_length
        xp = xp + tiltangle
        x  = x - sin_mb(tiltangle) * c_length
      end if

!++  Transform back to particle coordinates with opening and offset
      z00 = z
      x00 = x + mirror*c_offset
      x = (x + c_aperture/two) + mirror*c_offset                   !hr09

!++  Now mirror at the horizontal axis for negative X offset
      x  = mirror * x
      xp = mirror * xp

!++  Last do rotation into collimator frame
      x_in(j)  = x  *cos_mb(-one*c_rotation) + z  *sin_mb(-one*c_rotation)
      y_in(j)  = z  *cos_mb(-one*c_rotation) - x  *sin_mb(-one*c_rotation)
      xp_in(j) = xp *cos_mb(-one*c_rotation) + zp *sin_mb(-one*c_rotation)
      yp_in(j) = zp *cos_mb(-one*c_rotation) - xp *sin_mb(-one*c_rotation)

      if(( (icoll.eq.ipencil.and. iturn.eq.1).or. &
  &        (iturn.eq.1 .and.ipencil.eq.999 .and.icoll.le.nprim .and.(j.ge.(icoll-1)*nev/nprim) .and.(j.le.(icoll)*nev/nprim)))&
  &             .and.(pencil_distr.ne.3)) then    ! RB: adding condition that this shouldn't be done if pencil_distr=3

        x00  = mirror * x00
        x_in(j)  = x00  *cos_mb(-one*c_rotation) + z00  *sin_mb(-one*c_rotation)
        y_in(j)  = z00  *cos_mb(-one*c_rotation) - x00  *sin_mb(-one*c_rotation)

        xp_in(j) = xp_in(j) + mirror*xp_pencil0
        yp_in(j) = yp_in(j) + mirror*yp_pencil0
        x_in(j)  = x_in(j)  + mirror*x_pencil(icoll)
        y_in(j)  = y_in(j)  + mirror*y_pencil(icoll)
      end if

      p_in(j) = (one + dpop) * p0
!     SR, 30-08-2005: add the initial position of the slice
      s_in(j) = sp + (real(j_slices,fPrec)-one) * c_length               !hr09

    else
      x_in(j) = x
      y_in(j) = z
    end if !if(x.lt.99.0d-3) then

! output for comparing the particle in accelerator frame
!
!c$$$          if(dowrite_impact) then
!c$$$             write(9996,'(i5,1x,i7,1x,i2,1x,i1,2(1x,f5.3),8(1x,e17.9))')  &
!c$$$     &            name(j),iturn,icoll,nabs,                             &
!c$$$     &            s_in(j),                                              &
!c$$$     &            s+sp + (dble(j_slices)-1d0) * c_length,               &!hr09
!c$$$     &            x_in(j),xp_in(j),y_in(j),yp_in(j),                    &
!c$$$     &            x,xp,z,zp
!c$$$          endif
!
!++  End of check for particles not being lost before
!
!        endif
!
!        IF (X.GT.99.00) WRITE(*,*) 'After : ', X, X_IN(J)
!
!++  End of loop over all particles
!
 777  continue
  end do
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!
!      WRITE(*,*) 'Number of particles:            ', Nev
!      WRITE(*,*) 'Number of particle hits:        ', Nhit
!      WRITE(*,*) 'Number of absorped particles:   ', fracab
!      WRITE(*,*) 'Number of escaped particles:    ', Nhit-fracab
!      WRITE(*,*) 'Fraction of absorped particles: ', 100.*fracab/Nhit
!
end subroutine collimate2

!>
!! collimaterhic()
!! ???
!<
subroutine collimaterhic(c_material, c_length, c_rotation,        &
     &     c_aperture, n_aperture,                                      &
     &     c_offset, c_tilt,                                            &
     &     x_in, xp_in, y_in,                                           &
     &     yp_in, p_in, s_in, np, enom,                                 &
     &     lhit_pos,lhit_turn,                                          &
     &     part_abs_pos_local, part_abs_turn_local,                     &
     &     impact, indiv, lint, onesided,                               &
     &     name)
!
!++  Based on routines by JBJ. Changed by RA 2001.
!
!++  - Deleted all HBOOK stuff.
!++  - Deleted optics routine and all parser routines.
!++  - Replaced RANMAR call by RANLUX call
!++  - Included RANLUX code from CERNLIB into source
!++  - Changed dimensions from CGen(100,nmat) to CGen(200,nmat)
!++  - Replaced FUNPRE with FUNLXP
!++  - Replaced FUNRAN with FUNLUX
!++  - Included all CERNLIB code into source: RANLUX, FUNLXP, FUNLUX,
!++                                         FUNPCT, FUNLZ, RADAPT,
!++                                           RGS56P
!++    with additional entries:             RLUXIN, RLUXUT, RLUXAT,
!++                                           RLUXGO
!++
!++  - Changed program so that Nev is total number of particles
!++    (scattered and not-scattered)
!++  - Added debug comments
!++  - Put real dp/dx
!

      use crcoall
      use parpro
      implicit none


      real(kind=fPrec) sx, sz
!
! BLOCK DBCOLLIM
! This block is common to collimaterhic and collimate2
! It is NOT compatible with block DBCOMMON, as some variable names overlap...


  logical onesided,hit
! integer nprim,filel,mat,nev,j,nabs,nhit,np,icoll,nabs_tmp
  integer nprim,filel,j,nabs,nhit,np,nabs_tmp

  integer :: lhit_pos(npart) !(npart)
  integer :: lhit_turn(npart) !(npart)
  integer :: part_abs_pos_local(npart) !(npart)
  integer :: part_abs_turn_local(npart) !(npart)
  integer :: name(npart) !(npart)
  integer :: nabs_type(npart) !(npart)
!MAY2005

  real(kind=fPrec) :: x_in(npart) !(npart)
  real(kind=fPrec) :: xp_in(npart) !(npart)
  real(kind=fPrec) :: y_in(npart) !(npart)
  real(kind=fPrec) :: yp_in(npart) !(npart)
  real(kind=fPrec) :: p_in(npart) !(npart)
  real(kind=fPrec) :: s_in(npart) !(npart)
  real(kind=fPrec) :: indiv(npart) !(npart)
  real(kind=fPrec) :: lint(npart) !(npart)
  real(kind=fPrec) :: impact(npart) !(npart)
  real(kind=fPrec) keeps,fracab,sigx,sigz,norma,xpmu,drift_length,mirror,tiltangle

  real(kind=fPrec) c_length    !length in m
  real(kind=fPrec) c_rotation  !rotation angle vs vertical in radian
  real(kind=fPrec) c_aperture  !aperture in m
  real(kind=fPrec) c_offset    !offset in m
  real(kind=fPrec) c_tilt(2)   !tilt in radian
  character(len=4) c_material  !material

  character(nc) filen,tit

  real(kind=fPrec) xlow,xhigh,xplow,xphigh,dx,dxp
  real(kind=fPrec) x00,z00,p,sp,s,enom

  data dx,dxp/.5e-4,20.e-4/                                        !hr09

!AUGUST2006 Added ran_gauss for generation of pencil/     ------- TW
!           sheet beam distribution  (smear in x and y)
!
!+ca dbcollim

      real(kind=fPrec) x_flk,xp_flk,y_flk,yp_flk
!JUNE2005
      real(kind=fPrec) n_aperture  !aperture in m for the vertical plane
!JUNE2005
!DEBUG
      integer event
!DEBUG
      save
!=======================================================================
! Be=1 Al=2 Cu=3 W=4 Pb=5
!
! LHC uses:    Al, 0.2 m
!              Cu, 1.0 m
!
      if (c_material.eq.'BE') then
         mat = 1
      elseif (c_material.eq.'AL') then
         mat = 2
      elseif (c_material.eq.'CU') then
         mat = 3
      elseif (c_material.eq.'W') then
         mat = 4
      elseif (c_material.eq.'PB') then
         mat = 5
      elseif (c_material.eq.'C') then
         mat = 6
      elseif (c_material.eq.'C2') then
         mat = 7
      elseif (c_material.eq.'MoGR') then
         mat = 8
      elseif (c_material.eq.'CuCD') then
         mat = 9
      elseif (c_material.eq.'Mo') then
         mat = 10
      elseif (c_material.eq.'Glid') then
         mat = 11
      elseif (c_material.eq.'Iner') then
         mat = 12
      else
         write(lout,*) 'ERR>  Material not found. STOP', c_material
         call prror(-1)
      endif
!
        length  = c_length
        nev = np
        p0  = enom
!
!++  Initialize scattering processes
!
      call scatin(p0)

! EVENT LOOP,  initial distribution is here a flat distribution with
! xmin=x-, xmax=x+, etc. from the input file
!
      nhit    = 0
      fracab  = zero                                                     !hr09
      mirror  = one                                                      !hr09
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      do j = 1, nev
!
        impact(j) = -one                                                !hr09
        lint(j)   = -one                                                !hr09
        indiv(j)  = -one                                                !hr09
!
        x   = x_in(j)
        xp  = xp_in(j)
        z   = y_in(j)
        zp  = yp_in(j)
        p   = p_in(j)
!        sp  = s_in(J)
        sp   = zero
        dpop = (p - p0)/p0
!
!++  Transform particle coordinates to get into collimator coordinate
!++  system
!
!++  First check whether particle was lost before
!
!        if (x.lt.99.0*1e-3 .and. z.lt.99.0*1e-3) then
        if (x.lt.99.0_fPrec*c1m3 .and. z.lt.99.0_fPrec*c1m3) then
!
!++  First do rotation into collimator frame
!
!JUNE2005
!JUNE2005 CHANGE TO MAKE THE RHIC TREATMENT EASIER...
!JUNE2005
!+if crlibm
!          x  = x_in(j)*cos_mb(c_rotation) +sin_mb(c_rotation)*y_in(j)
!+ei
!+if .not.crlibm
!          x  = x_in(j)*cos_mb(c_rotation) +sin_mb(c_rotation)*y_in(j)
!+ei
!+if crlibm
!          z  = y_in(j)*cos_mb(c_rotation) -sin_mb(c_rotation)*x_in(j)
!+ei
!+if .not.crlibm
!          z  = y_in(j)*cos_mb(c_rotation) -sin_mb(c_rotation)*x_in(j)
!+ei
!+if crlibm
!          xp = xp_in(j)*cos_mb(c_rotation)+sin_mb(c_rotation)*yp_in(j)
!+ei
!+if .not.crlibm
!          xp = xp_in(j)*cos_mb(c_rotation)+sin_mb(c_rotation)*yp_in(j)
!+ei
!+if crlibm
!          zp = yp_in(j)*cos_mb(c_rotation)-sin_mb(c_rotation)*xp_in(j)
!+ei
!+if .not.crlibm
!          zp = yp_in(j)*cos_mb(c_rotation)-sin_mb(c_rotation)*xp_in(j)
!+ei
          x  = -one*x_in(j)
          z  = -one*y_in(j)
          xp = -one*xp_in(j)
          zp = -one*yp_in(j)
!JUNE2005
!
!++  For one-sided collimators consider only positive X. For negative
!++  X jump to the next particle
!
!GRD          IF (ONESIDED .AND. X.LT.0) GOTO 777
!JUNE2005          if (onesided .and. x.lt.0d0 .or. z.gt.0d0) goto 777
          if (onesided .and. (x.lt.zero .and. z.gt. zero)) goto 777
!
!++  Now mirror at the horizontal axis for negative X offset
!
!GRD
!GRD THIS WE HAVE TO COMMENT OUT IN CASE OF RHIC BECAUSE THERE ARE
!GRD ONLY ONE-SIDED COLLIMATORS
!GRD
!          IF (X.LT.0) THEN
!            MIRROR = -1.
!            tiltangle = -1.*C_TILT(2)
!          ELSE
!            MIRROR = 1.
            tiltangle = c_tilt(1)
!          ENDIF
!          X  = MIRROR * X
!          XP = MIRROR * XP
!GRD
!
!++  Shift with opening and offset
!
          x  = (x - c_aperture/two) - mirror*c_offset                    !hr09
!GRD
!GRD SPECIAL FEATURE TO TAKE INTO ACCOUNT THE PARTICULAR SHAPE OF RHIC PRIMARY COLLIMATORS
!GRD
!JUNE2005  HERE WE ADD THE ABILITY TO HAVE 2 DIFFERENT OPENINGS FOR THE TWO PLANES
!JUNE2005  OF THE PRIMARY COLLIMATOR OF RHIC
!JUNE2005
!          z  = z + c_aperture/2 + mirror*c_offset
          z  = (z + n_aperture/two) + mirror*c_offset                    !hr09
!JUNE2005
!          if(iturn.eq.1)                                                &
!     &write(*,*) 'check ',x,xp,z,zp,c_aperture,n_aperture
!JUNE2005
!
!++  Include collimator tilt
!
          if (tiltangle.gt.zero) then
            xp = xp - tiltangle
          elseif (tiltangle.lt.zero) then
            x  = x + sin_mb(tiltangle) * c_length
            xp = xp - tiltangle
          endif
!
!++  For selected collimator, first turn reset particle distribution
!++  to simple pencil beam
!
            nprim = 3
            if ( (icoll.eq.ipencil                                      &
     &.and. iturn.eq.1) .or.                                            &
     &(iturn.eq.1 .and. ipencil.eq.999 .and.                            &
     &icoll.le.nprim .and.                                              &
     &(j.ge.(icoll-1)*nev/nprim) .and.                                  &
     &(j.le.(icoll)*nev/nprim)                                          &
     &)  ) then
              x    = pencil_dx(icoll)
              xp   = zero                                                !hr09
              z    = zero                                                !hr09
              zp   = zero                                                !hr09
              dpop = zero                                                !hr09
              if(rndm4().lt.half) mirror = -one*abs(mirror)               !hr09
              if(rndm4().ge.half) mirror = abs(mirror)
            endif
!
!++  particle passing above the jaw are discarded => take new event
!++  entering by the face, shorten the length (zlm) and keep track of
!++  entrance longitudinal coordinate (keeps) for histograms
!
!++  The definition is that the collimator jaw is at x>=0.
!
!++  1) Check whether particle hits the collimator
!
          hit     =  .false.
          s       =  zero                                                !hr09
          keeps   =  zero                                                !hr09
          zlm     =  -one * length
!
!GRD
!JUNE2005          if (x.ge.0d0 .and. z.le.0d0) then
          if (x.ge.zero .and. z.le.zero) then
             goto 10
!
!++  Particle hits collimator and we assume interaction length ZLM equal
!++  to collimator length (what if it would leave collimator after
!++  small length due to angle???)
!
!JUNE2005
!            zlm = length
!            impact(j) = max(x,(-one*z))
!            if(impact(j).eq.x) then
!               indiv(j) = xp
!            else
!               indiv(j) = zp
!            endif
!          endif
!JUNE2005
!GRD
!JUNE2005          if(x.lt.0d0.and.z.gt.0d0.and.xp.le.0d0.and.zp.ge.0d0) then
          elseif(x.lt.zero.and.z.gt.zero.and.xp.le.zero.and.zp.ge.zero) then
             goto 20
!GRD
!JUNE2005          if(x.lt.0d0.and.z.gt.0d0.and.xp.le.0d0.and.zp.ge.0d0) then
!
!++  Particle does not hit collimator. Interaction length ZLM is zero.
!
!JUNE2005            zlm = 0.
!JUNE2005          endif
!GRD
!JUNE2005          if (x.lt.0d0.and.z.gt.0d0.and.xp.gt.0d0.and.zp.ge.0d0) then
!JUNE2005
!            zlm = 0.
!          endif
!JUNE2005
!
!JUNE2005
!JUNE2005 THAT WAS PIECE OF CAKE; NOW COMES THE TRICKY PART...
!JUNE2005
!JUNE2005 THE IDEA WOULD BE TO FIRST LIST ALL THE IMPACT
!JUNE2005 POSSIBILITIES, THEN SEND VIA GOTO TO THE CORRECT
!JUNE2005 TREATMENT
!JUNE2005
          elseif((x.lt.zero).and.(z.le.zero)) then
             goto 100
          elseif((x.ge.zero).and.(z.gt.zero)) then
             goto 200
          elseif((x.lt.zero).and.(xp.gt.zero)) then
             goto 300
          elseif((z.gt.zero).and.(zp.lt.zero)) then
             goto 400
          endif
!GRD
 10         continue
            event = 10
            zlm = length
            impact(j) = max(x,(-one*z))
            if(impact(j).eq.x) then
               indiv(j) = xp
            else
               indiv(j) = zp
            endif
            goto 999
!GRD
 20         continue
            event = 20
            zlm = zero                                                   !hr09
            goto 999
!GRD
 100        continue
            event = 100
            zlm = length
            impact(j) = -one*z
            indiv(j) = zp
            goto 999
!GRD
 200        continue
            event = 200
            zlm = length
            impact(j) = x
            indiv(j) = xp
            goto 999
!GRD
!JUNE2005
!JUNE2005 HERE ONE HAS FIRST TO CHECK IF THERE'S NOT A HIT IN THE
!JUNE2005 OTHER PLANE AT THE SAME TIME
!JUNE2005
 300        continue
            event = 300
            if(z.gt.zero.and.zp.lt.zero) goto 500
!
!++  Calculate s-coordinate of interaction point
!
            s = (-one*x) / xp
            if (s.le.zero) then
              write(lout,*) 'S.LE.0 -> This should not happen (1)'
              call prror(-1)
            endif
!
            if (s .lt. length) then
              zlm = length - s
              impact(j) = zero                                           !hr09
              indiv(j) = xp
            else
              zlm = zero                                                 !hr09
            endif
            goto 999
!GRD
 400        continue
            event = 400
!JUNE2005          if (x.lt.0d0.and.z.gt.0d0.and.xp.le.0d0.and.zp.lt.0d0) then
!
!++  Calculate s-coordinate of interaction point
!
            s = (-one*z) / zp
            if (s.le.zero) then
              write(lout,*) 'S.LE.0 -> This should not happen (2)'
              call prror(-1)
            endif
!
            if (s .lt. length) then
              zlm = length - s
              impact(j) = zero                                           !hr09
              indiv(j) = zp
            else
              zlm = zero                                                 !hr09
            endif
!JUNE2005          endif
!GRD
            goto 999
!GRD
!GRD
!JUNE2005          if (x.lt.0d0.and.z.gt.0d0.and.xp.gt.0d0.and.zp.lt.0d0) then
 500        continue
            event = 500
!
!++  Calculate s-coordinate of interaction point
!
            sx = (-one*x) / xp
            sz = (-one*z) / zp
!
            if(sx.lt.sz) s=sx
            if(sx.ge.sz) s=sz
!
            if (s.le.zero) then
              write(lout,*) 'S.LE.0 -> This should not happen (3)'
              call prror(-1)
            endif
!
            if (s .lt. length) then
              zlm = length - s
              impact(j) = zero                                           !hr09
              if(s.eq.sx) then
                indiv(j) = xp
              else
                indiv(j) = zp
              endif
            else
              zlm = zero                                                 !hr09
            endif
!
!JUNE2005          endif
!GRD
!GRD
 999      continue
!JUNE2005
!          write(*,*) 'event ',event,x,xp,z,zp
!          if(impact(j).lt.0d0) then
!             if(impact(j).ne.-1d0)                                      &
!     &write(*,*) 'argh! ',impact(j),x,xp,z,zp,s,event
!          endif
!          if(impact(j).ge.0d0) then
!      write(*,*) 'impact! ',impact(j),x,xp,z,zp,s,event
!          endif
!JUNE2005
!
!++  First do the drift part
!
          drift_length = length - zlm
          if (drift_length.gt.zero) then                                 !hr09
            x  = x + xp* drift_length
            z  = z + zp * drift_length
            sp = sp + drift_length
          endif
!
!++  Now do the scattering part
!
          if (zlm.gt.zero) then                                          !hr09
            nhit = nhit + 1
!            WRITE(*,*) J,X,XP,Z,ZP,SP,DPOP
!DEBUG
!            write(*,*) 'abs?',s,zlm
!DEBUG
!JUNE2005
!JUNE2005 IN ORDER TO HAVE A PROPER TREATMENT IN THE CASE OF THE VERTICAL
!JUNE2005 PLANE, CHANGE AGAIN THE FRAME FOR THE SCATTERING SUBROUTINES...
!JUNE2005
            if(event.eq.100.or.event.eq.400) then
!GRD first go back into normal frame...
               x = (x + c_aperture/two) + mirror*c_offset                !hr09
               z = (z - n_aperture/two) - mirror*c_offset                !hr09
               x  = -one*x
               xp = -one*xp
               z  = -one*z
               zp = -one*zp
!GRD ...then do as for a vertical collimator
               x  = z
               xp = zp
               z  = -one*x
               zp = -one*x
               x  = (x - n_aperture/two) - mirror*c_offset               !hr09
               z  = (z + c_aperture/two) + mirror*c_offset               !hr09
            endif
!JUNE2005
!     RB: add new input arguments to jaw icoll,iturn,ipart for writeout
            call jaw(s, nabs, icoll, iturn, name(j), dowrite_impact)

!DEBUG
!            write(*,*) 'abs?',nabs
!DEBUG
!JUNE2005
!JUNE2005 ...WITHOUT FORGETTING TO GO BACK TO THE "ORIGINAL" FRAME AFTER THE
!JUNE2005 ROUTINES, SO AS TO AVOID RIDICULOUS VALUES FOR KICKS IN EITHER PLANE
            if(event.eq.100.or.event.eq.400) then
!GRD first go back into normal frame...
               x = (x + n_aperture/two) + mirror*c_offset                !hr09
               z = (z - c_aperture/two) - mirror*c_offset                !hr09
               x = -one*z
               xp = -one*zp
               z = x
               zp = xp
!GRD ...then go back to face the horizontal jaw at 180 degrees
               x = -one*x
               xp = -one*xp
               z = -one*z
               zp = -one*zp
               x  = (x - c_aperture/two) - mirror*c_offset               !hr09
               z  = (z + n_aperture/two) + mirror*c_offset               !hr09
            endif
!JUNE2005
            lhit_pos(j)  = ie
            lhit_turn(j) = iturn
!
!++  If particle is absorbed then set x and y to 99.99 mm
!
            if (nabs.eq.1) then
!APRIL2005
!TO WRITE FLUKA INPUT CORRECTLY, WE HAVE TO GO BACK IN THE MACHINE FRAME
            if (tiltangle.gt.zero) then                                  !hr09
              x  = x  + tiltangle*c_length
              xp = xp + tiltangle
            elseif (tiltangle.lt.zero) then                              !hr09
              x  = x + tiltangle*c_length
              xp = xp + tiltangle
              x  = x - sin_mb(tiltangle) * c_length
            endif
!
!++  Transform back to particle coordinates with opening and offset
!
            x = (x + c_aperture/two) + mirror*c_offset                   !hr09
!GRD
!JUNE2005  OF COURSE WE ADAPT ALSO THE PREVIOUS CHANGE WHEN SHIFTING BACK
!JUNE2005  TO  THE ACCELERATOR FRAME...
!            z = z - c_aperture/2 - mirror*c_offset
            z = (z - n_aperture/two) - mirror*c_offset                   !hr09
!JUNE2005
!
!++   Last do rotation into collimator frame
!
                  x_flk  = -one*x
                  y_flk  = -one*z
                  xp_flk = -one*xp
                  yp_flk = -one*zp
!NOW WE CAN WRITE THE COORDINATES OF THE LOST PARTICLES
              if(dowrite_impact) then
      write(FLUKA_impacts_unit,'(i4,(2x,f5.3),(2x,f8.6),4(1x,e16.7),2x,i2,2x,i5)')      &
     &icoll,c_rotation,s+sp,                                            &
     &x_flk*c1e3, xp_flk*c1e3, y_flk*c1e3, yp_flk*c1e3,                 &
     &nabs,name(j)
              endif
!APRIL2005
              fracab = fracab + 1
!              x = 99.99*1e-3
!              z = 99.99*1e-3
              x = 99.99_fPrec*c1m3
              z = 99.99_fPrec*c1m3
              part_abs_pos_local(j) = ie
              part_abs_turn_local(j) = iturn
              lint(j) = zlm
            endif
          endif
!
!++  Do the rest drift, if particle left collimator early
!
          if (nabs.ne.1 .and. zlm.gt.zero) then                          !hr09
            drift_length = (length-(s+sp))
            if (drift_length.gt.1.0e-15_fPrec) then
!              WRITE(*,*) J, DRIFT_LENGTH
              x  = x + xp * drift_length
              z  = z + zp * drift_length
              sp = sp + drift_length
            endif
            lint(j) = zlm - drift_length
          endif
!
!++  Transform back to particle coordinates with opening and offset
!
!          if (x.lt.99.0*1e-3 .and. z.lt.99.0*1e-3) then
          if (x.lt.99.0_fPrec*c1m3 .and. z.lt.99.0_fPrec*c1m3) then
!
!++  Include collimator tilt
!
            if (tiltangle.gt.zero) then                                  !hr09
              x  = x  + tiltangle*c_length
              xp = xp + tiltangle
            elseif (tiltangle.lt.zero) then                              !hr09
              x  = x + tiltangle*c_length
              xp = xp + tiltangle
!
              x  = x - sin_mb(tiltangle) * c_length
            endif
!
!++  Transform back to particle coordinates with opening and offset
!
            z00 = z
            x00 = x + mirror*c_offset
            x = (x + c_aperture/two) + mirror*c_offset                   !hr09
!GRD
!JUNE2005  OF COURSE WE ADAPT ALSO THE PREVIOUS CHANGE WHEN SHIFTING BACK
!JUNE2005  TO  THE ACCELERATOR FRAME...
!            z = z - c_aperture/2 - mirror*c_offset
            z = (z - n_aperture/two) - mirror*c_offset                   !hr09
!JUNE2005
!
!++  Now mirror at the horizontal axis for negative X offset
!
            x    = mirror * x
            xp   = mirror * xp
!
!++  Last do rotation into collimator frame
!
!JUNE2005
!+if crlibm
!            x_in(j)  = x  *cos_mb(-1.*c_rotation) +                     &
!+ei
!+if .not.crlibm
!            x_in(j)  = x  *cos_mb(-1.*c_rotation) +                        &
!+ei
!+if crlibm
!     &z  *sin_mb(-1.*c_rotation)
!+ei
!+if .not.crlibm
!     &z  *sin_mb(-1.*c_rotation)
!+ei
!+if crlibm
!            y_in(j)  = z  *cos_mb(-1.*c_rotation) -                     &
!+ei
!+if .not.crlibm
!            y_in(j)  = z  *cos_mb(-1.*c_rotation) -                        &
!+ei
!+if crlibm
!     &x  *sin_mb(-1.*c_rotation)
!+ei
!+if .not.crlibm
!     &x  *sin_mb(-1.*c_rotation)
!+ei
!+if crlibm
!            xp_in(j) = xp *cos_mb(-1.*c_rotation) +                     &
!+ei
!+if .not.crlibm
!            xp_in(j) = xp *cos_mb(-1.*c_rotation) +                        &
!+ei
!+if crlibm
!     &zp *sin_mb(-1.*c_rotation)
!+ei
!+if .not.crlibm
!     &zp *sin_mb(-1.*c_rotation)
!+ei
!+if crlibm
!            yp_in(j) = zp *cos_mb(-1.*c_rotation) -                     &
!+ei
!+if .not.crlibm
!            yp_in(j) = zp *cos_mb(-1.*c_rotation) -                        &
!+ei
!+if crlibm
!     &xp *sin_mb(-1.*c_rotation)
!+ei
!+if .not.crlibm
!     &xp *sin_mb(-1.*c_rotation)
!+ei
            x_in(j) = -one*x
            y_in(j) = -one*z
            xp_in(j) = -one*xp
            yp_in(j) = -one*zp
!JUNE2005
!
            if ( (icoll.eq.ipencil                                      &
     &.and. iturn.eq.1)   .or.                                          &
     &(iturn.eq.1 .and. ipencil.eq.999 .and.                            &
     &icoll.le.nprim .and.                                              &
     &(j.ge.(icoll-1)*nev/nprim) .and.                                  &
     &(j.le.(icoll)*nev/nprim)                                          &
     &)  ) then
!
               x00  = mirror * x00
               x_in(j)  = x00  *cos_mb(-one*c_rotation) +                 &!hr09
     &z00  *sin_mb(-one*c_rotation)                                        !hr09
               y_in(j)  = z00  *cos_mb(-one*c_rotation) -                 &!hr09
     &x00  *sin_mb(-one*c_rotation)                                        !hr09

               xp_in(j) = xp_in(j) + mirror*xp_pencil0
               yp_in(j) = yp_in(j) + mirror*yp_pencil0
               x_in(j) = x_in(j) + mirror*x_pencil(icoll)
               y_in(j) = y_in(j) + mirror*y_pencil(icoll)
            endif

            p_in(j) = (one + dpop) * p0                                  !hr09
            s_in(j) = s_in(j) + sp

          else
            x_in(j)  = x
            y_in(j)  = z
          endif
!
!++  End of check for particles not being lost before
!
        endif
!
!        IF (X.GT.99.00) WRITE(*,*) 'After : ', X, X_IN(J)
!
!++  End of loop over all particles
!
 777  continue
      end do
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!
!      WRITE(*,*) 'Number of particles:            ', Nev
!      WRITE(*,*) 'Number of particle hits:        ', Nhit
!      WRITE(*,*) 'Number of absorped particles:   ', fracab
!      WRITE(*,*) 'Number of escaped particles:    ', Nhit-fracab
!      WRITE(*,*) 'Fraction of absorped particles: ', 100.*fracab/Nhit
!
end subroutine collimaterhic
!
!-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----GRD-----
!! END collimaterhic()

!>
!! ichoix(ma)
!! Select a scattering type (elastic, sd, inelastic, ...)
!<
function ichoix(ma)
  implicit none
!+ca interac
  integer ma,i,ichoix
  real(kind=fPrec) aran
  aran=real(rndm4(),fPrec)
  i=1
10  if( aran.gt.cprob(i,ma) ) then
      i=i+1
      goto 10
    end if

    ichoix=i
    return
end function ichoix

!>
!! gettran(inter,xmat,p)
!! This function determines: GETTRAN - rms transverse momentum transfer
!! Note: For single-diffractive scattering the vector p of momentum
!! is modified (energy loss is applied)
!<
function gettran(inter,xmat,p)

  implicit none

!+ca interac

  integer inter,length,xmat
  real(kind=fPrec) p,gettran,t,xm2,bsd
  real(kind=fPrec) truth,xran(1)

! inter=2: Nuclear Elastic, 3: pp Elastic, 4: Single Diffractive, 5:Coulomb
#ifndef MERLINSCATTER
  if( inter.eq.2 ) then
    gettran = (-one*log_mb(real(rndm4(),fPrec)))/bn(xmat)                  !hr09

  else if( inter .eq. 3 ) then
    gettran = (-one*log_mb(real(rndm4(),fPrec)))/bpp                       !hr09

  else if( inter .eq. 4 ) then
    xm2 = exp_mb( real(rndm4(),fPrec) * xln15s )
    p = p  * (one - xm2/ecmsq)
    if( xm2 .lt. two ) then
      bsd = two * bpp
    else if (( xm2 .ge. two ).and. ( xm2 .le. five )) then
      bsd = ((106.0_fPrec-17.0_fPrec*xm2) *  bpp )/ 36.0_fPrec             !hr09
    else if ( xm2 .gt. five ) then
      bsd = (seven * bpp) / 12.d0                                          !hr09
    end if
      gettran = (-one*log_mb(real(rndm4(),fPrec)))/bsd                     !hr09

  else if( inter.eq.5 ) then
    length=1
    call funlux( cgen(1,mat), xran, length)
    truth=xran(1)
    t=real(truth,fPrec)                                                    !hr09
    gettran = t
  end if
#endif
#ifdef MERLINSCATTER

  if( inter.eq.2 ) then
    gettran = (-one*log_mb(real(rndm4(),fPrec)))/bn(xmat)                  !hr09

  else if( inter .eq. 3 ) then
    call merlinscatter_get_elastic_t(gettran)

  else if( inter .eq. 4 ) then
    call merlinscatter_get_sd_xi(xm2)
    call merlinscatter_get_sd_t(gettran)
    p = p  * (one - (xm2/ecmsq))

  else if ( inter.eq.5 ) then
    length=1
    call funlux( cgen(1,mat) , xran, length)
    truth=xran(1)
    t=real(truth,fPrec)                                                 !hr09
    gettran = t
  end if

#endif
  return
end function gettran

!>
!! tetat(t,p,tx,tz)
!! ???
!!
!<
subroutine tetat(t,p,tx,tz)

  implicit none

  real(kind=fPrec) t,p,tx,tz,va,vb,va2,vb2,r2,teta
  teta = sqrt(t)/p

! Generate sine and cosine of an angle uniform in [0,2pi](see RPP)
10 va  =(2d0*real(rndm4(),fPrec))-1d0                                       !hr09
  vb = real(rndm4(),fPrec)
  va2 = va**2
  vb2 = vb**2
  r2 = va2 + vb2
  if ( r2.gt.1.d0) go to 10
  tx = teta * ((2.d0*va)*vb) / r2                                    !hr09
  tz = teta * (va2 - vb2) / r2
  return
end subroutine tetat

!>
!! ruth(t)
!! Calculate the rutherford scattering cross section
!<
function ruth(t)

  implicit none

!+ca interac

  real(kind=fPrec) ruth,t
  real(kind=fPrec) cnorm,cnform
  parameter(cnorm=2.607e-5_fPrec,cnform=0.8561e3_fPrec) ! DM: changed 2.607d-4 to 2.607d-5 to fix Rutherford bug

  ruth=(cnorm*exp_mb(((-one*real(t,fPrec))*cnform)*emr(mcurr)**2))*(zatom(mcurr)/real(t,fPrec))**2
end function ruth


!>
!! scatin(plab)
!! Configure the K2 scattering routine cross sections
!!
!<
subroutine scatin(plab)
  use physical_constants

  implicit none

!#ifdef MERLINSCATTER
!+ca database
!#endif

!+ca interac

  integer ma,i
  real(kind=fPrec) plab
  real(kind=fPrec) tlow,thigh

  ecmsq = (two * pmap) * plab                                   !hr09
#ifndef MERLINSCATTER
  xln15s=log_mb(0.15_fPrec*ecmsq)                                           !hr09

!Claudia Fit from COMPETE collaboration points "arXiv:hep-ph/0206172v1 19Jun2002"
  pptot=0.041084_fPrec-0.0023302_fPrec*log_mb(ecmsq)+0.00031514_fPrec*log_mb(ecmsq)**2

!Claudia used the fit from TOTEM for ppel (in barn)
  ppel=(11.7_fPrec-1.59_fPrec*log_mb(ecmsq)+0.134_fPrec*log_mb(ecmsq)**2)/c1e3

!Claudia updated SD cross that cointains renormalized pomeron flux (in barn)
  ppsd=(4.3_fPrec+0.3_fPrec*log_mb(ecmsq))/c1e3
#endif

#ifdef MERLINSCATTER
!No crlibm...
  call merlinscatter_setup(plab,rnd_seed)
  call merlinscatter_setdata(pptot,ppel,ppsd)
#endif

!Claudia new fit for the slope parameter with new data at sqrt(s)=7 TeV from TOTEM
  bpp=7.156_fPrec+1.439_fPrec*log_mb(sqrt(ecmsq))

! unmeasured tungsten data,computed with lead data and power laws
  bnref(4) = bnref(5)*(anuc(4) / anuc(5))**(two/three)
  emr(4) = emr(5) * (anuc(4)/anuc(5))**(one/three)
10 format(/' ppRef TOT El     ',4f12.6//)
11 format(/' pp    TOT El Sd b',4f12.6//)

! Compute cross-sections (CS) and probabilities + Interaction length
! Last two material treated below statement number 100

  tlow=real(tlcut)                                                   !hr09
  do 100 ma=1,nrmat
    mcurr=ma
! prepare for Rutherford differential distribution
    thigh=real(hcut(ma))                                             !hr09
    call funlxp ( ruth , cgen(1,ma) ,tlow, thigh )

! freep: number of nucleons involved in single scattering
    freep(ma) = freeco * anuc(ma)**(one/three)

! compute pp and pn el+single diff contributions to cross-section
! (both added : quasi-elastic or qel later)
    csect(3,ma) = freep(ma) * ppel
    csect(4,ma) = freep(ma) * ppsd

! correct TOT-CSec for energy dependence of qel
! TOT CS is here without a Coulomb contribution
    csect(0,ma) = csref(0,ma) + freep(ma) * (pptot - pptref)
    bn(ma) = (bnref(ma) * csect(0,ma)) / csref(0,ma)                    !hr09
! also correct inel-CS
    csect(1,ma) = (csref(1,ma) * csect(0,ma)) / csref(0,ma)                !hr09
!
! Nuclear Elastic is TOT-inel-qel ( see definition in RPP)
    csect(2,ma) = ((csect(0,ma) - csect(1,ma)) - csect(3,ma)) - csect(4,ma)         !hr09
    csect(5,ma) = csref(5,ma)
! Now add Coulomb
    csect(0,ma) = csect(0,ma) + csect(5,ma)
! Interaction length in meter
  xintl(ma) = (c1m2*anuc(ma))/(((fnavo * rho(ma))*csect(0,ma))*1d-24) !hr09

20   format(/1x,a4,' Int.Len. ',f10.6,' CsTot',2f12.4/)

21   format('  bN freep',2 f12.6,'   emR ',f7.4/)

! Filling CProb with cumulated normalised Cross-sections
    do 50 i=1,4
      cprob(i,ma)=cprob(i-1,ma)+csect(i,ma)/csect(0,ma)

50     continue

22   format(i4,' prob CS CsRref',3(f12.5,2x))
100 continue

! Last two materials for 'vaccum' (nmat-1) and 'full black' (nmat)
  cprob(1,nmat-1) = one
  cprob(1,nmat)   = one
  xintl(nmat-1)   = c1e12
  xintl(nmat)     = zero
120 format(/1x,a4,' Int.Len. ',e10.3/)
  return
end subroutine scatin

!>
!! jaw(s,nabs,icoll,iturn,ipart,dowrite_impact)
!! ???
!!     RB: adding as input arguments to jaw variables icoll,iturn,ipart
!!         these are only used for the writeout of particle histories
!!
!!++  Input:   ZLM is interaction length
!!++           MAT is choice of material
!!
!!++  Output:  nabs = 1   Particle is absorped
!!++           nabs = 4   Single-diffractive scattering
!!++           dpop       Adjusted for momentum loss (dE/dx)
!!++           s          Exit longitudinal position
!!
!!++  Physics:  If monte carlo interaction length greater than input
!!++            interaction length, then use input interaction length
!!++            Is that justified???
!!
!!     nabs=1....absorption
!!
!<
subroutine jaw(s,nabs,icoll,iturn,ipart,dowrite_impact)

  implicit none

!+ca interac
!+ca flukavars
  integer nabs,inter,iturn,icoll,ipart,nabs_tmp ! RB: added variables icoll,iturn,ipart for writeout
  logical dowrite_impact
  real(kind=fPrec) m_dpodx, mc_int_l,s_in,I,c_material     !CT, RB, DM
  real(kind=fPrec) p,rlen,s,t,dxp,dzp,p1,zpBef,xpBef,pBef
  real(kind=fPrec) get_dpodx
!...cne=1/(sqrt(b))
!...dpodx=dE/(dx*c)

!++  Note that the input parameter is dpop. Here the momentum p is
!++  constructed out of this input.

  p=p0*(one+dpop)
  nabs=0
  nabs_tmp=nabs

  if(mat.eq.nmat) then
!++  Collimator treated as black absorber
    nabs=1
    nabs_tmp=nabs
    s=zero

    if(dowrite_impact) then
      ! write coll_scatter.dat for complete scattering histories
#ifdef HDF5
      if(h5_useForCOLL) then
        call coll_hdf5_writeCollScatter(icoll, iturn, ipart, nabs_tmp, -one, zero, zero)
      else
#endif
      write(coll_scatter_unit,'(1x,i2,2x,i4,2x,i5,2x,i1,3(2x,e14.6))') icoll, iturn, ipart, nabs_tmp, -one, zero, zero
#ifdef HDF5
      endif
#endif
    end if
    return
  else if(mat.eq.nmat-1) then
!++  Collimator treated as drift
    s=zlm
    x=x+s*xp
    z=z+s*zp

    if(dowrite_impact) then
      ! write coll_scatter.dat for complete scattering histories
#ifdef HDF5
      if(h5_useForCOLL) then
        call coll_hdf5_writeCollScatter(icoll, iturn, ipart, nabs_tmp, -one, zero, zero)
      else
#endif
      write(coll_scatter_unit,'(1x,i2,2x,i4,2x,i5,2x,i1,3(2x,e14.6))') icoll, iturn, ipart, nabs_tmp, -one, zero, zero
#ifdef HDF5
      endif
#endif
    end if

    return
  end if

!++  Initialize the interaction length to input interaction length
  rlen=zlm

!++  Do a step for a point-like interaction. This is a loop with
!++  label 10!!!
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!++  Get monte-carlo interaction length.

10  zlm1=(-one*xintl(mat))*log_mb(real(rndm4(),fPrec))                          !hr09
  nabs_tmp=0 !! type of interaction reset before following scattering process
  xpBef=xp ! save angles and momentum before scattering
  zpBef=zp
  pBef=p

!++  If the monte-carlo interaction length is longer than the
!++  remaining collimator length, then put it to the remaining
!++  length, do multiple coulomb scattering and return.
!++  LAST STEP IN ITERATION LOOP
  if(zlm1.gt.rlen) then
    zlm1=rlen
    call mcs(s)
    s=(zlm-rlen)+s                                                    !hr09
#ifndef MERLINSCATTER
    call calc_ion_loss(mat,p,rlen,m_dpodx)  ! DM routine to include tail
    p=p-m_dpodx*s
#endif
#ifdef MERLINSCATTER
!void calc_ion_loss_merlin_(double* p, double* ElectronDensity, double* PlasmaEnergy, double* MeanIonisationEnergy, double* result)
    call merlinscatter_calc_ion_loss(p,edens(mat), pleng(mat),exenergy(mat),s,m_dpodx)
    p=p-m_dpodx
#endif

    dpop=(p-p0)/p0
    if(dowrite_impact) then
      ! write coll_scatter.dat for complete scattering histories
#ifdef HDF5
      if(h5_useForCOLL) then
        call coll_hdf5_writeCollScatter(icoll,iturn,ipart,nabs_tmp,(p-pBef)/pBef,xp-xpBef,zp-zpBef)
      else
#endif
      write(coll_scatter_unit,'(1x,i2,2x,i4,2x,i5,2x,i1,3(2x,e18.10))') icoll,iturn,ipart,nabs_tmp,(p-pBef)/pBef,xp-xpBef,zp-zpBef
#ifdef HDF5
      endif
#endif
    end if
    return
  end if

!++  Otherwise do multi-coulomb scattering.
!++  REGULAR STEP IN ITERATION LOOP
  call mcs(s)

!++  Check if particle is outside of collimator (X.LT.0) after
!++  MCS. If yes, calculate output longitudinal position (s),
!++  reduce momentum (output as dpop) and return.
!++  PARTICLE LEFT COLLIMATOR BEFORE ITS END.
  if(x.le.zero) then
    s=(zlm-rlen)+s                                                    !hr09

#ifndef MERLINSCATTER
    call calc_ion_loss(mat,p,rlen,m_dpodx)
    p=p-m_dpodx*s
#endif
#ifdef MERLINSCATTER
    call merlinscatter_calc_ion_loss(p,edens(mat),pleng(mat),exenergy(mat),s,m_dpodx)
    p=p-m_dpodx
#endif
    dpop=(p-p0)/p0

    if(dowrite_impact) then
      ! write coll_scatter.dat for complete scattering histories
#ifdef HDF5
      if(h5_useForCOLL) then
        call coll_hdf5_writeCollScatter(icoll,iturn,ipart,nabs_tmp,(p-pBef)/pBef,xp-xpBef,zp-zpBef)
      else
#endif
      write(coll_scatter_unit,'(1x,i2,2x,i4,2x,i5,2x,i1,3(2x,e18.10))') icoll,iturn,ipart,nabs_tmp,(p-pBef)/pBef,xp-xpBef,zp-zpBef
#ifdef HDF5
      endif
#endif
    end if

    return
  end if

!++  Check whether particle is absorbed. If yes, calculate output
!++  longitudinal position (s), reduce momentum (output as dpop)
!++  and return.
!++  PARTICLE WAS ABSORPED INSIDE COLLIMATOR DURING MCS.

  inter=ichoix(mat)
  nabs=inter
  nabs_tmp=nabs

! RB, DM: save coordinates before interaction for writeout to FLUKA_impacts.dat
  xInt=x
  xpInt=xp
  yInt=z
  ypInt=zp
  sInt=(zlm-rlen)+zlm1                                                 !hr09

  if(inter.eq.1) then
    s=(zlm-rlen)+zlm1                                                 !hr09

#ifndef MERLINSCATTER
    call calc_ion_loss(mat,p,rlen,m_dpodx)
    p=p-m_dpodx*s
#endif
#ifdef MERLINSCATTER
    call merlinscatter_calc_ion_loss(p,edens(mat),pleng(mat),exenergy(mat),s,m_dpodx)
    p=p-m_dpodx
#endif

    dpop=(p-p0)/p0

    ! write coll_scatter.dat for complete scattering histories
#ifdef HDF5
    if(h5_useForCOLL) then
      call coll_hdf5_writeCollScatter(icoll,iturn,ipart,nabs_tmp,-one,zero,zero)
    else
#endif
    write(coll_scatter_unit,'(1x,i2,2x,i4,2x,i5,2x,i1,3(2x,e14.6))') icoll,iturn,ipart,nabs_tmp,-one,zero,zero
#ifdef HDF5
    endif
#endif
    return
  end if

!++  Now treat the other types of interaction, as determined by ICHOIX:

!++      Nuclear-Elastic:          inter = 2
!++      pp Elastic:               inter = 3
!++      Single-Diffractive:       inter = 4    (changes momentum p)
!++      Coulomb:                  inter = 5

!++  As the single-diffractive interaction changes the momentum, save
!++  input momentum in p1.
  p1 = p

!++  Gettran returns some monte carlo number, that, as I believe, gives
!++  the rms transverse momentum transfer.
  t = gettran(inter,mat,p)

!++  Tetat calculates from the rms transverse momentum transfer in
!++  monte-carlo fashion the angle changes for x and z planes. The
!++  angle change is proportional to SQRT(t) and 1/p, as expected.
  call tetat(t,p,dxp,dzp)

!++  Apply angle changes
  xp=xp+dxp
  zp=zp+dzp

!++  Treat single-diffractive scattering.
  if(inter.eq.4) then

!++ added update for s
    s=(zlm-rlen)+zlm1                                                !hr09
    xpsd=dxp
    zpsd=dzp
    psd=p1
!
!++  Add this code to get the momentum transfer also in the calling
!++  routine...
    dpop=(p-p0)/p0
  end if

  if(dowrite_impact) then
    ! write coll_scatter.dat for complete scattering histories.
    ! Includes changes in angle from both
#ifdef HDF5
    if(h5_useForCOLL) then
      call coll_hdf5_writeCollScatter(icoll,iturn,ipart,nabs_tmp,(p-pBef)/pBef,xp-xpBef,zp-zpBef)
    else
#endif
    write(coll_scatter_unit,'(1x,i2,2x,i4,2x,i5,2x,i1,3(2x,e18.10))') icoll,iturn,ipart,nabs_tmp,(p-pBef)/pBef,xp-xpBef,zp-zpBef
#ifdef HDF5
    endif
#endif
  end if

!++  Calculate the remaining interaction length and close the iteration
!++  loop.
  rlen=rlen-zlm1
  goto 10

end subroutine jaw

#ifdef HDF5
subroutine coll_hdf5_writeCollScatter(icoll,iturn,ipart,nabs,dp,dx,dy)

  integer,          intent(in) :: icoll,iturn,ipart,nabs
  real(kind=fPrec), intent(in) :: dp,dx,dy

  call h5_prepareWrite(coll_hdf5_collScatter, 1)
  call h5_writeData(coll_hdf5_collScatter, 1, 1, ipart)
  call h5_writeData(coll_hdf5_collScatter, 2, 1, iturn)
  call h5_writeData(coll_hdf5_collScatter, 3, 1, icoll)
  call h5_writeData(coll_hdf5_collScatter, 4, 1, nabs)
  call h5_writeData(coll_hdf5_collScatter, 5, 1, dp)
  call h5_writeData(coll_hdf5_collScatter, 6, 1, dx)
  call h5_writeData(coll_hdf5_collScatter, 7, 1, dy)
  call h5_finaliseWrite(coll_hdf5_collScatter)

end subroutine coll_hdf5_writeCollScatter
#endif
!>
!! jaw0(s,nabs)
!! ???
!!
!!++  Input:   ZLM is interaction length
!!++           MAT is choice of material
!!
!!++  Output:  nabs = 1   Particle is absorped
!!++           nabs = 4   Single-diffractive scattering
!!++           dpop       Adjusted for momentum loss (dE/dx)
!!++           s          Exit longitudinal position
!!
!!++  Physics:  If monte carlo interaction length greater than input
!!++            interaction length, then use input interaction length
!!++            Is that justified???
!!
!!     nabs=1....absorption
!!
!<
subroutine jaw0(s,nabs)

      implicit none

!+ca interac
      integer nabs,inter,icoll,iturn,ipart
      real(kind=fPrec) p,rlen,s,t,dxp,dzp,p1
!...cne=1/(sqrt(b))
!...dpodx=dE/(dx*c)
      p=p0/(one-dpop)
      nabs=0
      if(mat.eq.nmat) then
!
!++  Collimator treated as black absorber
!
        nabs=1
        s=zero
        return
      else if(mat.eq.nmat-1) then
!
!++  Collimator treated as drift
        s=zlm
        x=x+s*xp
        z=z+s*zp
        return
      end if
!
!++  Initialize the interaction length to input interaction length
      rlen=zlm
!
!++  Do a step for a point-like interaction. This is a loop with
!++  label 10!!!
!
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!++  Get monte-carlo interaction length.
10    zlm1=(-one*xintl(mat))*log_mb(real(rndm4(),fPrec))

      if(zlm1.gt.rlen) then

!++  If the monte-carlo interaction length is shorter than the
!++  remaining collimator length, then put it to the remaining
!++  length, do multiple coulomb scattering and return.
!++  LAST STEP IN ITERATION LOOP
       zlm1=rlen
       call mcs(s)
       s=(zlm-rlen)+s                                                    !hr09
       p=p-dpodx(mat)*s
       dpop=one-p0/p
       return
      end if
!
!++  Otherwise do multi-coulomb scattering.
!++  REGULAR STEP IN ITERATION LOOP
!
      call mcs(s)
!
!++  Check if particle is outside of collimator (X.LT.0) after
!++  MCS. If yes, calculate output longitudinal position (s),
!++  reduce momentum (output as dpop) and return.
!++  PARTICLE LEFT COLLIMATOR BEFORE ITS END.
!
      if(x.le.0.d0) then
       s=(zlm-rlen)+s                                                    !hr09
       p=p-dpodx(mat)*s
       dpop=1.d0-p0/p
       return
      end if
!
!++  Check whether particle is absorbed. If yes, calculate output
!++  longitudinal position (s), reduce momentum (output as dpop)
!++  and return.
!++  PARTICLE WAS ABSORPED INSIDE COLLIMATOR DURING MCS.
!
      inter=ichoix(mat)
      if(inter.eq.1) then
        nabs=1
        s=(zlm-rlen)+zlm1                                                 !hr09
        p=p-dpodx(mat)*s
        dpop=1.d0-p0/p
        ! write coll_scatter.dat for complete scattering histories
#ifdef HDF5
        if(h5_useForCOLL) then
          call coll_hdf5_writeCollScatter(icoll,iturn,ipart,nabs,-one,zero,zero)
        else
#endif
        write(coll_scatter_unit,'(1x,i2,2x,i4,2x,i5,2x,i1,3(2x,e14.6))') icoll,iturn,ipart,nabs,-one,zero,zero
#ifdef HDF5
        end if
#endif
        return
      end if
!
!++  Now treat the other types of interaction, as determined by ICHOIX:
!
!++      Nuclear-Elastic:          inter = 2
!++      pp Elastic:               inter = 3
!++      Single-Diffractive:       inter = 4    (changes momentum p)
!++      Coulomb:                  inter = 5
!
!++  As the single-diffractive interaction changes the momentum, save
!++  input momentum in p1.
!
      p1 = p
!
!++  Gettran returns some monte carlo number, that, as I believe, gives
!++  the rms transverse momentum transfer.
!
      t = gettran(inter,mat,p)
!
!++  Tetat calculates from the rms transverse momentum transfer in
!++  monte-carlo fashion the angle changes for x and z planes. The
!++  angle change is proportional to SQRT(t) and 1/p, as expected.
!
      call tetat(t,p,dxp,dzp)
!
!++  Apply angle changes
!
      xp=xp+dxp
      zp=zp+dzp
!
!++  Treat single-diffractive scattering.
!
      if(inter.eq.4) then
        nabs=4
        xpsd=dxp
        zpsd=dzp
        psd=p1
      end if
!
!++  Calculate the remaining interaction length and close the iteration
!++  loop.
!
      rlen=rlen-zlm1
      goto 10

end subroutine jaw0

!>
!! mcs(s)
!!++  Input:   zlm1   Monte-carlo interaction length
!!
!!++  Output:  s      Longitudinal position
!!++           p0     Reference momentum
!!++           dpop   Relative momentum offset
!!
!!     collimator: x>0 and y<zlm1
!<
subroutine mcs(s)
      implicit none
!      save h,dh,bn
!+ca interac
      real(kind=fPrec) h,dh,theta,rlen0,rlen,ae,be,bn0,s
      real(kind=fPrec) radl_mat,rad_len ! Claudia 2013 added variables


!   bn=sqrt(3)/(number of sigmas for s-determination(=4))
      data h/.001d0/dh/.0001d0/bn0/.4330127019d0/

      radl_mat=radl(mat)
      theta=13.6d-3/(p0*(1.d0+dpop))      !Claudia added log part
      rad_len=radl(mat)                    !Claudia

      x=(x/theta)/radl(mat)                                              !hr09
      xp=xp/theta
      z=(z/theta)/radl(mat)                                              !hr09
      zp=zp/theta
      rlen0=zlm1/radl(mat)
      rlen=rlen0
10    ae=bn0*x
      be=bn0*xp
      call soln3(ae,be,dh,rlen,s)
      if(s.lt.h) s=h
      call scamcs(x,xp,s,radl_mat)
      if(x.le.0.d0) then
       s=(rlen0-rlen)+s                                                  !hr09
       goto 20
      end if
      if(s+dh.ge.rlen) then
       s=rlen0
       goto 20
      end if
      rlen=rlen-s
      goto 10
20    call scamcs(z,zp,s,radl_mat)
      s=s*radl(mat)
      x=(x*theta)*radl(mat)                                              !hr09
      xp=xp*theta
      z=(z*theta)*radl(mat)                                              !hr09
      zp=zp*theta
end subroutine mcs

!>
!! scamcs(xx,xxp,s,radl_mat)
!! ???
!<
subroutine scamcs(xx,xxp,s,radl_mat)

  implicit none

  real(kind=fPrec) v1,v2,r2,a,z1,z2,ss,s,xx,xxp,x0,xp0
  real(kind=fPrec) radl_mat

  x0=xx
  xp0=xxp

5 v1=2d0*real(rndm4(),fPrec)-1d0
  v2=2d0*real(rndm4(),fPrec)-1d0
  r2=v1**2+v2**2                                                     !hr09
  if(r2.ge.1.d0) goto 5

  a=sqrt((-2.d0*log_mb(r2))/r2)                                         !hr09
  z1=v1*a
  z2=v2*a
  ss=sqrt(s)
  xx=x0+s*(xp0+(half*ss)*(one+0.038_fPrec*log_mb(s))*(z2+z1*0.577350269_fPrec)) !Claudia: added logarithmic part in mcs formula
  xxp=xp0+ss*z2*(one+0.038_fPrec*log_mb(s))
end subroutine scamcs

!>
!! soln3(a,b,dh,smax,s)
!! ???
!<
subroutine soln3(a,b,dh,smax,s)

  implicit none

  real(kind=fPrec) b,a,s,smax,c,dh
  if(b.eq.zero) then
    s=a**0.6666666666666667_fPrec
!      s=a**(two/three)
    if(s.gt.smax) s=smax
    return
  end if

  if(a.eq.zero) then
    if(b.gt.zero) then
      s=b**2
    else
      s=zero
    end if
    if(s.gt.smax) s=smax
    return
  end if

  if(b.gt.zero) then
    if(smax**3.le.(a+b*smax)**2) then
      s=smax
      return
    else
      s=smax*half
      call iterat(a,b,dh,s)
    end if
  else
    c=(-one*a)/b
    if(smax.lt.c) then
      if(smax**3.le.(a+b*smax)**2) then
        s=smax
        return
      else
        s=smax*half
        call iterat(a,b,dh,s)
      end if
    else
      s=c*half
      call iterat(a,b,dh,s)
    end if
  end if

end subroutine soln3

subroutine iterat(a,b,dh,s)

  implicit none

  real(kind=fPrec) ds,s,a,b,dh

  ds=s
10 ds=ds*half

  if(s**3.lt.(a+b*s)**2) then
    s=s+ds
  else
    s=s-ds
  end if

  if(ds.lt.dh) then
    return
  else
    goto 10
  end if

end subroutine iterat

!>
!! get_dpodx(p,mat_i)
!! calculate mean ionization energy loss according to Bethe-Bloch
!<
function get_dpodx(p,mat_i)          !Claudia
  use physical_constants

  implicit none

  integer mat
!+ca collMatNum
  common/materia/mat
  real(kind=fPrec) anuc,zatom,rho,emr
  real(kind=fPrec) PE,K,gamma_p
!  real(kind=fPrec) PE,me,mp,K,gamma_p
  common/mater/anuc(nmat),zatom(nmat),rho(nmat),emr(nmat)
!  real(kind=fPrec) anuc,zatom,rho,emr,exenergy
!  common/meanexen/exenergy(nmat)
  real(kind=fPrec) beta_p,gamma_s,beta_s,me2,mp2,T,part_1,part_2,I_s,delta
  parameter(K=0.307075)
!  parameter(me=0.510998910e-3,mp=938.272013e-3,K=0.307075)
  real(kind=fPrec) p
  integer mat_i
  real(kind=fPrec) dpodx,get_dpodx

  mp2       = pmap**2
  me2       = pmae**2
  beta_p    = one
  gamma_p   = p/pmap
  beta_s    = beta_p**2
  gamma_s   = gamma_p**2
  T         = (2*pmae*beta_s*gamma_s)/(1+(2*gamma_p*pmae/pmap)+me2/mp2)
  PE        = sqrt(rho(mat_i)*zatom(mat_i)/anuc(mat_i))*28.816e-9_fPrec
  I_s       = exenergy(mat_i)**2
  part_1    = K*zatom(mat_i)/(anuc(mat_i)*beta_s)
  delta     = log_mb(PE/exenergy(mat_i))+log_mb(beta_p*gamma_p)-half
  part_2    = half*log_mb((two*pmae*beta_s*gamma_s*T)/I_s)
  get_dpodx = part_1*(part_2-beta_s-delta)*rho(mat_i)*c1m1
  return
end function get_dpodx

!>
!! CalcElectronDensity(AtomicNumber, Density, AtomicMass)
!! Function to calculate the electron density in a material
!! Should give the number per cubic meter
!<
function CalcElectronDensity(AtomicNumber, Density, AtomicMass)
  implicit none

  real(kind=fPrec) AtomicNumber, Density, AtomicMass
  real(kind=fPrec) Avogadro
  real(kind=fPrec) CalcElectronDensity
  real(kind=fPrec) PartA, PartB
  parameter (Avogadro = 6.022140857e23_fPrec)
  PartA = AtomicNumber * Avogadro * Density
  !1e-6 factor converts to n/m^-3
  PartB = AtomicMass * c1m6
  CalcElectronDensity = PartA/PartB
  return
end function CalcElectronDensity

!>
!! CalcPlasmaEnergy(ElectronDensity)
!! Function to calculate the plasma energy in a material
!! CalculatePlasmaEnergy = (PlanckConstantBar * sqrt((ElectronDensity *(ElectronCharge**2)) / &
!!& (ElectronMass * FreeSpacePermittivity)))/ElectronCharge*eV;
!<
function CalcPlasmaEnergy(ElectronDensity)

  implicit none

  real(kind=fPrec) ElectronDensity
  real(kind=fPrec) CalcPlasmaEnergy
  real(kind=fPrec) sqrtAB,PartA,PartB,FSPC2

  !Values from the 2016 PDG
  real(kind=fPrec) PlanckConstantBar,ElectronCharge,ElectronMass
  real(kind=fPrec) ElectronCharge2
  real(kind=fPrec) FreeSpacePermittivity,FreeSpacePermeability
  real(kind=fPrec) SpeedOfLight,SpeedOfLight2

  parameter (PlanckConstantBar = 1.054571800e-34_fPrec)
  parameter (ElectronCharge = 1.6021766208e-19_fPrec)
  parameter (ElectronCharge2 = ElectronCharge*ElectronCharge)
  parameter (ElectronMass = 9.10938356e-31_fPrec)
  parameter (SpeedOfLight = 299792458.0_fPrec)
  parameter (SpeedOfLight2 = SpeedOfLight*SpeedOfLight)

  parameter (FreeSpacePermeability = 16.0e-7_fPrec*atan(one)) ! Henry per meter
  parameter (FSPC2 = FreeSpacePermeability*SpeedOfLight2)
  parameter (FreeSpacePermittivity = one/FSPC2)
  parameter (PartB = ElectronMass * FreeSpacePermittivity)

  PartA = ElectronDensity * ElectronCharge2

  sqrtAB = sqrt(PartA/PartB)
  CalcPlasmaEnergy=PlanckConstantBar*sqrtAB/ElectronCharge*c1m9
  return
end function CalcPlasmaEnergy

!>
!! calc_ion_loss(IS,PC,DZ,EnLo)
!! subroutine for the calculazion of the energy loss by ionization
!! Either mean energy loss from Bethe-Bloch, or higher energy loss, according to finite probability from cross section
!! written by DM for crystals, introduced in main code by RB
!<
subroutine calc_ion_loss(IS, PC, DZ, EnLo)

! IS material ID
! PC momentum in GeV
! DZ length traversed in material (meters)
! EnLo energy loss in GeV/meter

  use physical_constants

  implicit none

  integer IS

!+ca collMatNum

  real(kind=fPrec) PC,DZ,EnLo,exEn
  real(kind=fPrec) k !Daniele: parameters for dE/dX calculation (const,electron radius,el. mass, prot.mass)
!  real(kind=fPrec) k,re,me,mp !Daniele: parameters for dE/dX calculation (const,electron radius,el. mass, prot.mass)
  real(kind=fPrec) enr,mom,betar,gammar,bgr !Daniele: energy,momentum,beta relativistic, gamma relativistic
  real(kind=fPrec) Tmax,plen !Daniele: maximum energy tranfer in single collision, plasma energy (see pdg)
  real(kind=fPrec) thl,Tt,cs_tail,prob_tail
  real(kind=fPrec) ranc
  real(kind=fPrec) anuc,zatom,rho,emr

!  real(kind=fPrec) PC,DZ,EnLo,exenergy,exEn
!  common/meanexen/exenergy(nmat)

  common/mater/anuc(nmat),zatom(nmat),rho(nmat),emr(nmat)

  data k/0.307075_fPrec/      !constant in front bethe-bloch [MeV g^-1 cm^2]
! The following values are now taken from physical_constants
!  data re/2.818d-15/    !electron radius [m]
!  data me/0.510998910/  !electron mass [MeV/c^2]
!  data mp/938.272013/   !proton mass [MeV/c^2]

  mom    = PC*c1e3                    ! [GeV/c] -> [MeV/c]
  enr    = (mom*mom+pmap*pmap)**half  ! [MeV]
  gammar = enr/pmap
  betar  = mom/enr
  bgr    = betar*gammar

! mean excitation energy - convert to MeV
  exEn=exenergy(IS)*c1e3

! Tmax is max energy loss from kinematics
  Tmax=(two*pmae*bgr**2)/(one+two*gammar*pmae/pmap+(pmae/pmap)**2) ![MeV]

! plasma energy - see PDG 2010 table 27.1
  plen = ((rho(IS)*zatom(IS)/anuc(IS))**half)*28.816e-6_fPrec ![MeV]

! calculate threshold energy
! Above this threshold, the cross section for high energy loss is calculated and then
! a random number is generated to determine if tail energy loss should be applied, or only mean from Bethe-Bloch
! below threshold, only the standard bethe-bloch is used (all particles get average energy loss)

! thl is 2* width of landau distribution (as in fig 27.7 in PDG 2010). See Alfredo's presentation for derivation
  thl = four*k*zatom(IS)*DZ*c1e2*rho(IS)/(anuc(IS)*betar**2) ![MeV]
!     write(3456,*) thl     ! should typically be >0.06MeV for approximations to be valid - check!

! Bethe Bloch mean energy loss
  EnLo = ((k*zatom(IS))/(anuc(IS)*betar**2))*(half*log_mb((two*pmae*bgr*bgr*Tmax)/(exEn*exEn))-betar**two-&
& log_mb(plen/exEn)-log_mb(bgr)+half)

  EnLo = EnLo*rho(IS)*c1m1*DZ  ![GeV]

! threshold Tt is bethe bloch + 2*width of Landau distribution
  Tt = EnLo*c1e3+thl      ![MeV]

! cross section - see Alfredo's presentation for derivation
  cs_tail = ((k*zatom(IS))/(anuc(IS)*betar**2))*((half*((one/Tt)-(one/Tmax)))-(log_mb(Tmax/Tt)*(betar**2) &
 &        /(two*Tmax))+((Tmax-Tt)/(four*(gammar**2)*(pmap**2))))

! probability of being in tail: cross section * density * path length
  prob_tail = cs_tail*rho(IS)*DZ*c1e2;

  ranc = real(rndm4(),fPrec)

! determine based on random number if tail energy loss occurs.
  if(ranc.lt.prob_tail) then
    EnLo = ((k*zatom(IS))/(anuc(IS)*betar**2))*(half*log_mb((two*pmae*bgr*bgr*Tmax)/(exEn*exEn))-betar**two- &
 &       log_mb(plen/exEn)-log_mb(bgr)+half+(TMax**2)/(eight*(gammar**2)*(pmap**2)))

    EnLo = EnLo*rho(IS)*c1m1 ![GeV/m]
  else
    ! if tial energy loss does not occur, just use the standard Bethe Bloch
    EnLo = EnLo/DZ  ![GeV/m]
  endif

  RETURN

end subroutine calc_ion_loss

subroutine makedis(mynp, myalphax, myalphay, mybetax, mybetay,    &
     &myemitx0, myemity0, myenom, mynex, mdex, myney, mdey,             &
     &myx, myxp, myy, myyp, myp, mys)

!  Generate distribution

  use crcoall
  implicit none


!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy

  real(kind=fPrec) pi

  save
!-----------------------------------------------------------------------
!++  Generate particle distribution
!
!
!++  Generate random distribution, assuming optical parameters at IP1
!
!
!++  Calculate the gammas
!
  pi=four*atan_mb(one)
  mygammax = (one+myalphax**2)/mybetax
  mygammay = (one+myalphay**2)/mybetay
!++TW 11/07 reset j, helps if subroutine is called twice
! was done during try to reset distribution, still needed
! will this subroutine ever called twice?
  j = 0
!
!++  Number of points and generate distribution
  write(lout,*)
  write(lout,*) 'Generation of particle distribution Version 1'
  write(lout,*)
  write(lout,*) 'This routine generates particles in phase space'
  write(lout,*) 'X/XP and Y/YP ellipses, as defined in the input'
  write(lout,*) 'parameters. Distribution is flat in the band.'
  write(lout,*) 'X and Y are fully uncorrelated.'
  write(lout,*)

  write(outlun,*)
  write(outlun,*) 'Generation of particle distribution Version 1'
  write(outlun,*)
  write(outlun,*) 'This routine generates particles in phase space'
  write(outlun,*) 'X/XP and Y/YP ellipses, as defined in the input'
  write(outlun,*) 'parameters. Distribution is flat in the band.'
  write(outlun,*) 'X and Y are fully uncorrelated.'
  write(outlun,*)
  write(outlun,*) 'INFO>  Number of particles   = ', mynp
  write(outlun,*) 'INFO>  Av number of x sigmas = ', mynex
  write(outlun,*) 'INFO>  +- spread in x sigmas = ', mdex
  write(outlun,*) 'INFO>  Av number of y sigmas = ', myney
  write(outlun,*) 'INFO>  +- spread in y sigmas = ', mdey
  write(outlun,*) 'INFO>  Nominal beam energy   = ', myenom
  write(outlun,*) 'INFO>  Sigma_x0 = ', sqrt(mybetax*myemitx0)
  write(outlun,*) 'INFO>  Sigma_y0 = ', sqrt(mybetay*myemity0)
  write(outlun,*) 'INFO>  Beta x   = ', mybetax
  write(outlun,*) 'INFO>  Beta y   = ', mybetay
  write(outlun,*) 'INFO>  Alpha x  = ', myalphax
  write(outlun,*) 'INFO>  Alpha y  = ', myalphay
  write(outlun,*)

  do while (j.lt.mynp)
    j = j + 1
    myemitx = myemitx0*(mynex + ((two*dble(rndm4()-half))*mdex) )**2
    xsigmax = sqrt(mybetax*myemitx)
    myx(j)  = xsigmax * sin_mb((two*pi)*real(rndm4(),fPrec))
    if(rndm4().gt.half) then
      myxp(j) = sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
    else
      myxp(j) = -one*sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
    end if

    myemity = myemity0*(myney + ((two*dble(rndm4()-half))*mdey) )**2
    ysigmay = sqrt(mybetay*myemity)
    myy(j)  = ysigmay * sin_mb((two*pi)*real(rndm4(),fPrec))
    if(rndm4().gt.half) then
      myyp(j) = sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
    else
      myyp(j) = -one*sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
    end if

    myp(j) = myenom
    mys(j) = zero

!++  Dangerous stuff, just for the moment
    if (cut_input) then
      !0.1d-3 -> c1m4
      if((.not. (myy(j).lt.-0.008e-3_fPrec .and. myyp(j).lt. c1m4 .and.myyp(j).gt.zero) ) .and. &
&        (.not. (myy(j).gt. 0.008e-3_fPrec .and. myyp(j).gt.-c1m4 .and.myyp(j).lt.zero) ) ) then
        j = j - 1
      end if
    end if
  end do
  return
end subroutine makedis

!========================================================================
! SR, 08-05-2005: Add the finite beam size in the othe dimension
subroutine makedis_st(mynp, myalphax, myalphay, mybetax, mybetay, &
     &     myemitx0, myemity0, myenom, mynex, mdex, myney, mdey,  &
     &     myx, myxp, myy, myyp, myp, mys)

!     Uses the old routine 'MAKEDIS' for the halo plane and adds the
!     transverse beam size in the other plane (matched distrubutions
!     are generated starting from thetwiss functions).
!     If 'mynex' and 'myney' are BOTH set to zero, nominal bunches
!     centred in the aperture centre are generated. (SR, 08-05-2005)

  use crcoall
  implicit none

!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy

  real(kind=fPrec) pi
  real(kind=fPrec) iix, iiy, phix, phiy
  save

!-----------------------------------------------------------------------
!++  Generate particle distribution
!++  Generate random distribution, assuming optical parameters at IP1
!++  Calculate the gammas
  write(lout,*) '  New routine to add the finite beam size in the'
  write(lout,*) '  other dimension (SR, 08-06-2005).'

  pi=four*atan_mb(one)
  mygammax = (one+myalphax**2)/mybetax
  mygammay = (one+myalphay**2)/mybetay
  do j=1, mynp
    if((mynex.gt.zero).and.(myney.eq.zero)) then
      myemitx = myemitx0*(mynex+((two*dble(rndm4()-half))*mdex))**2
      xsigmax = sqrt(mybetax*myemitx)
      myx(j)  = xsigmax * sin_mb((two*pi)*real(rndm4(),fPrec))

      if (rndm4().gt.half) then
        myxp(j) =     sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
      else
       myxp(j) = -one*sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
      end if

      phiy = (two*pi)*real(rndm4(),fPrec)
      iiy = (-one*myemity0) * log_mb( real(rndm4(),fPrec) )
      myy(j) = sqrt((two*iiy)*mybetay) * cos_mb(phiy)
      myyp(j) = (-one*sqrt((two*iiy)/mybetay)) * (sin_mb(phiy) + myalphay * cos_mb(phiy))

    else if ( mynex.eq.zero.and.myney.gt.zero ) then
      myemity = myemity0*(myney+((two*dble(rndm4()-half))*mdey))**2
      ysigmay = sqrt(mybetay*myemity)
      myy(j)  = ysigmay * sin_mb((two*pi)*real(rndm4(),fPrec))

      if (rndm4().gt.half) then
        myyp(j) =      sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
      else
        myyp(j) = -one*sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
      end if

      phix = (two*pi)*real(rndm4(),fPrec)
      iix = (-one* myemitx0) * log_mb( real(rndm4(),fPrec) )
      myx(j) = sqrt((two*iix)*mybetax) * cos_mb(phix)
      myxp(j) = (-one*sqrt((two*iix)/mybetax)) * (sin_mb(phix) +myalphax * cos_mb(phix))

    else if( mynex.eq.zero.and.myney.eq.zero ) then
      phix = (two*pi)*real(rndm4(),fPrec)
      iix = (-one*myemitx0) * log_mb( real(rndm4(),fPrec) )
      myx(j) = sqrt((two*iix)*mybetax) * cos_mb(phix)
      myxp(j) = (-one*sqrt((two*iix)/mybetax)) * (sin_mb(phix) +myalphax * cos_mb(phix))
      phiy = (two*pi)*real(rndm4(),fPrec)
      iiy = (-one*myemity0) * log_mb( real(rndm4(),fPrec) )
      myy(j) = sqrt((two*iiy)*mybetay) * cos_mb(phiy)
      myyp(j) = (-one*sqrt((two*iiy)/mybetay)) * (sin_mb(phiy) + myalphay * cos_mb(phiy))
    else
      write(lout,*) "Error - beam parameters not correctly set!"
    end if
    myp(j) = myenom
    mys(j) = zero
  end do
  return
end subroutine makedis_st

!========================================================================
!
!     RB: new routine to sample part of matched phase ellipse which is outside
!     the cut of the jaws
!     Assuming cut of the jaw at mynex for hor plane.
!     largest amplitude outside of jaw is mynex + mdex.  Analog for vertical plane.

!     same routine as makedis_st, but rejection sampling to get
!     only particles hitting the collimator on the same turn.

!     Treat as a pencil beam in main routine.

subroutine makedis_coll(mynp,myalphax, myalphay, mybetax, mybetay,  myemitx0, myemity0, &
 &                        myenom, mynex, mdex, myney, mdey, myx, myxp, myy, myyp, myp, mys)

  use crcoall
  implicit none

!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy

  real(kind=fPrec) pi, iix, iiy, phix,phiy,cutoff

      save
!
!-----------------------------------------------------------------------
!++  Generate particle distribution
!
!++  Calculate the gammas

  write(lout,*) '  RB 2013: new pencil beam routine'
  pi=four*atan_mb(one)

  mygammax = (one+myalphax**2)/mybetax
  mygammay = (one+myalphay**2)/mybetay

! calculate cutoff in x or y from the collimator jaws.
  if((mynex.gt.zero).and.(myney.eq.zero)) then
    cutoff=mynex*sqrt(mybetax*myemitx0)
  else
    cutoff=myney*sqrt(mybetay*myemity0)
  end if

      do j=1, mynp
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         if((mynex.gt.zero).and.(myney.eq.zero)) then  ! halo in x
 887        continue
            myemitx = myemitx0*(mynex+(real(rndm4(),fPrec)*mdex))**2
            xsigmax = sqrt(mybetax*myemitx)
            myx(j)  = xsigmax * sin_mb((two*pi)*real(rndm4(),fPrec))
            if(abs(myx(j)).lt.cutoff) goto 887

            if(rndm4().gt.half) then
              myxp(j) = sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
            else
              myxp(j) = -one*sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
            end if

            phiy = (two*pi)*real(rndm4(),fPrec)
            iiy = (-one*myemity0) * log_mb( real(rndm4(),fPrec) )
            myy(j) = sqrt((two*iiy)*mybetay) * cos_mb(phiy)
            myyp(j) = (-one*sqrt((two*iiy)/mybetay)) * (sin_mb(phiy) + myalphay * cos_mb(phiy))
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         else if( mynex.eq.zero.and.myney.gt.zero ) then  ! halo in y
 886        continue
            myemity = myemity0*(myney+(real(rndm4(),fPrec)*mdey))**2
            ysigmay = sqrt(mybetay*myemity)
            myy(j)   = ysigmay * sin_mb((two*pi)*real(rndm4(),fPrec))
            if(abs(myy(j)).lt.cutoff) goto 886

            if(rndm4().gt.half) then
              myyp(j) = sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
            else
              myyp(j) = -one*sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
            end if

            phix = (two*pi)*real(rndm4(),fPrec)
            iix = (-one* myemitx0) * log_mb( real(rndm4(),fPrec) )
            myx(j) = sqrt((two*iix)*mybetax) * cos_mb(phix)
            myxp(j) = (-one*sqrt((two*iix)/mybetax)) * (sin_mb(phix) + myalphax * cos_mb(phix))

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! nominal bunches centered in the aperture - can't apply rejection sampling. return with error
         else if( mynex.eq.zero.and.myney.eq.zero ) then
           write(lout,*) "Stop in makedis_coll. attempting to use halo type 3 with Gaussian dist. "
           call prror(-1)
         else
           write(lout,*) "Error - beam parameters not correctly set!"
         end if

         myp(j) = myenom
         mys(j) = zero

      end do

      return
end subroutine makedis_coll

!========================================================================
!
! SR, 09-05-2005: Add the energy spread and the finite bunch length.
!                 Gaussian distributions assumed
subroutine makedis_de(mynp, myalphax, myalphay, mybetax, mybetay, &
     &     myemitx0, myemity0, myenom, mynex, mdex, myney, mdey,        &
     &     myx, myxp, myy, myyp, myp, mys,                              &
     &     enerror,bunchlength)

!     Uses the old routine 'MAKEDIS' for the halo plane and adds the
!     transverse beam size in the other plane (matched distrubutions
!     are generated starting from thetwiss functions).
!     If 'mynex' and 'myney' are BOTH set to zero, nominal bunches
!     centred in the aperture centre are generated. (SR, 08-05-2005)

  use crcoall
  implicit none

!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy

  real(kind=fPrec) pi
  real(kind=fPrec) iix, iiy, phix, phiy
  real(kind=fPrec) enerror, bunchlength
  real(kind=fPrec) en_error, bunch_length
  real(kind=fPrec) long_cut
  real(kind=fPrec) a_st, b_st
  save
!-----------------------------------------------------------------------
!++  Generate particle distribution
!
!++  Generate random distribution, assuming optical parameters at IP1
!
!++  Calculate the gammas
  pi=four*atan_mb(one)

  mygammax = (one+myalphax**2)/mybetax
  mygammay = (one+myalphay**2)/mybetay

!     Assign bunch length and dp/p depending on the energy
!     Check if the units in metres are correct!
!GRD      if ( myenom.eq.7e6 ) then
!GRD         en_error     = 1.129e-4
!GRD         bunch_length = 7.55e-2
!GRD      elseif ( myenom.eq.4.5e5 ) then
!GRD         en_error     = 3.06e-4
!GRD         bunch_length = 11.24e-2
!GRD      else
  en_error = enerror
  bunch_length = bunchlength

!GRD         write(lout,*)"Warning-Energy different from LHC inj or top!"
!GRD         write(lout,*)"  => 7TeV values of dp/p and bunch length used!"
!GRD      endif

  write(lout,*) "Generation of bunch with dp/p and length:"
  write(lout,*) "  RMS bunch length  = ", bunch_length
  write(lout,*) "  RMS energy spread = ", en_error

  do j=1, mynp
    if((mynex.gt.zero).and.(myney.eq.zero)) then
      myemitx = myemitx0*(mynex+((two*dble(rndm4()-half))*mdex))**2
      xsigmax = sqrt(mybetax*myemitx)
      myx(j)  = xsigmax * sin_mb((two*pi)*real(rndm4(),fPrec))

      if (rndm4().gt.half) then
        myxp(j) = sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
      else
        myxp(j) = -one*sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax
      end if

      phiy = (two*pi)*real(rndm4(),fPrec)
      iiy = (-one*myemity0) * log_mb( real(rndm4(),fPrec) )
      myy(j) = sqrt((two*iiy)*mybetay) * cos_mb(phiy)
      myyp(j) = (-one*sqrt((two*iiy)/mybetay)) * (sin_mb(phiy) + myalphay * cos_mb(phiy))

    else if( mynex.eq.zero.and.myney.gt.zero ) then
      myemity = myemity0*(myney+((two*dble(rndm4()-half))*mdey))**2
      ysigmay = sqrt(mybetay*myemity)
      myy(j)   = ysigmay * sin_mb((two*pi)*real(rndm4(),fPrec))

      if(rndm4().gt.half) then
        myyp(j) = sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
      else
        myyp(j) = -one*sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay
      end if

      phix = (two*pi)*real(rndm4(),fPrec)
      iix = (-one*myemitx0) * log_mb( real(rndm4(),fPrec) )
      myx(j) = sqrt((two*iix)*mybetax) * cos_mb(phix)
      myxp(j) = (-one*sqrt((two*iix)/mybetax)) * (sin_mb(phix) + myalphax * cos_mb(phix))

    else if( mynex.eq.zero.and.myney.eq.zero ) then
      phix = (two*pi)*real(rndm4(),fPrec)
      iix = (-one*myemitx0) * log_mb( real(rndm4(),fPrec) )
      myx(j) = sqrt((two*iix)*mybetax) * cos_mb(phix)
      myxp(j) = (-one*sqrt((two*iix)/mybetax)) * (sin_mb(phix) + myalphax * cos_mb(phix))
      phiy = (two*pi)*real(rndm4(),fPrec)
      iiy = (-one*myemity0) * log_mb( real(rndm4(),fPrec) )
      myy(j) = sqrt((two*iiy)*mybetay) * cos_mb(phiy)
      myyp(j) = (-one*sqrt((two*iiy)/mybetay)) * (sin_mb(phiy) + myalphay * cos_mb(phiy))
    else
      write(lout,*) "Error - beam parameters not correctly set!"
    end if
  end do

! SR, 11-08-2005 For longitudinal phase-space, add a cut at 2 sigma
!++   1st: generate mynpnumbers within the chose cut
  long_cut = 2
  j = 1
  do while (j.le.mynp)
    a_st = ran_gauss(five)
    b_st = ran_gauss(five)

    do while ((a_st**2+b_st**2).gt.long_cut**2)
      a_st = ran_gauss(five)
      b_st = ran_gauss(five)
    end do

    mys(j) = a_st
    myp(j) = b_st
    j = j + 1
  end do

!++   2nd: give the correct values
  do j=1,mynp
    myp(j) = myenom * (one + myp(j) * en_error)
    mys(j) = bunch_length * mys(j)
  end do

  return
end subroutine makedis_de


!========================================================================
subroutine readdis(filename_dis,mynp,myx,myxp,myy,myyp,myp,mys)
!
!     SR, 09-08-2005
!     Format for the input file:
!               x, y   -> [ m ]
!               xp, yp -> [ rad ]
!               s      -> [ mm ]
!               DE     -> [ MeV ]

  use crcoall
  implicit none

!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy

  character(len=80)   filename_dis

  logical lopen
  integer stat

  save

  write(lout,*) "Reading input bunch from file ", filename_dis

!  inquire( unit=53, opened=lopen )
!  if(lopen) then
!    write(lout,*) "ERROR in subroutine readdis: FORTRAN Unit 53 was already open!"
!    goto 20
!  end if

  call funit_requestUnit(filename_dis, filename_dis_unit)
  open(unit=filename_dis_unit, file=filename_dis, iostat=stat,status="OLD",action="read") !was 53
  if(stat.ne.0)then
    write(lout,*) "Error in subroutine readdis: Could not open the file."
    write(lout,*) "Got iostat=",stat
    goto 20
  end if

  do j=1,mynp
    read(filename_dis_unit,*,end=10,err=20) myx(j), myxp(j), myy(j), myyp(j), mys(j), myp(j)
  end do

 10   mynp = j - 1
  write(lout,*) "Number of particles read from the file = ",mynp

  close(filename_dis_unit)

  return

 20   continue

  write(lout,*) "I/O Error on Unit 53 in subroutine readdis"
  call prror(-1)

end subroutine readdis

!========================================================================
!
subroutine readdis_norm(filename_dis, mynp, myalphax, myalphay, mybetax, mybetay, &
 &           myemitx, myemity, myenom, myx, myxp, myy, myyp, myp, mys, enerror, bunchlength)
!     Format for the input file:
!               x, y   -> [ sigma ]
!               xp, yp -> [ sigma ]
!               s      -> [ sigma ]
!               DE     -> [ sigma ]

  use crcoall
  use parpro
  use mod_common
  use mod_commonmn
  implicit none

!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy


  character(len=80)   filename_dis
  real(kind=fPrec) enerror, bunchlength

  logical lopen
  integer stat

  real(kind=fPrec) normx, normy, normxp, normyp, normp, norms
  real(kind=fPrec) myemitz

  write(lout,*) "Reading input bunch from file ", filename_dis

  if (iclo6.eq.0) then
    write(lout,*) "ERROR DETECTED: Incompatible flag           "
    write(lout,*) "in line 2 of the TRACKING block             "
    write(lout,*) "of fort.3 for calculating the closed orbit  "
    write(lout,*) "(iclo6 must not be =0). When using an input "
    write(lout,*) "distribution in normalized coordinates for  "
    write(lout,*) "collimation the closed orbit is needed for a"
    write(lout,*) "correct TAS matrix for coordinate transform."
    call prror(-1)
  endif

!  inquire( unit=53, opened=lopen )
!  if(lopen) then
!    write(lout,*) "ERROR in subroutine readdis: FORTRAN Unit 53 was already open!"
!    goto 20
!  end if

  call funit_requestUnit(filename_dis, filename_dis_unit)
  open(unit=filename_dis_unit, file=filename_dis, iostat=stat, status="OLD",action="read") !was 53
  if(stat.ne.0)then
    write(lout,*) "Error in subroutine readdis: Could not open the file."
    write(lout,*) "Got iostat=",stat
    goto 20
  end if

  do j=1,mynp
    read(filename_dis_unit,*,end=10,err=20) normx, normxp, normy, normyp, norms, normp
! A normalized distribution with x,xp,y,yp,z,zp is read and
! transformed with the TAS matrix T , which is the transformation matrix
! from normalized to physical coordinates it is scaled with the geometric
! emittances in diag matrix S. x = T*S*normx
! units of TAS matrix # m,rad,m,rad,m,1
! The collimation coordinates/units are
! x[m], x'[rad], y[m], y'[rad]$, sig[mm], dE [MeV].

!         write(lout,*) " myenom [MeV]= ",myenom
!         write(lout,*) " myemitx [m]= ",myemitx
!         write(lout,*) " myemity [m]= ",myemity
!         write(lout,*) " bunchlength [mm]= ",bunchlength
!         write(lout,*) " enerror = ",enerror

         !convert bunchlength from [mm] to [m]
         ! enerror is the energy spread
    myemitz  = bunchlength * c1m3 * enerror


! scaling the TAS matrix entries of the longitudinal coordinate. tas(ia,j,k)  ia=the particle for which the tas was written

    myx(j)   =                            &
     &     normx  * sqrt(myemitx)*tas(1,1,1) + &
     &     normxp * sqrt(myemitx)*tas(1,1,2) + &
     &     normy  * sqrt(myemity)*tas(1,1,3) + &
     &     normyp * sqrt(myemity)*tas(1,1,4) + &
     &     norms  * sqrt(myemitz)*tas(1,1,5) + &
     &     normp  * sqrt(myemitz)*c1m3*tas(1,1,6)

    myxp(j)  =                            &
     &     normx  * sqrt(myemitx)*tas(1,2,1) + &
     &     normxp * sqrt(myemitx)*tas(1,2,2) + &
     &     normy  * sqrt(myemity)*tas(1,2,3) + &
     &     normyp * sqrt(myemity)*tas(1,2,4) + &
     &     norms  * sqrt(myemitz)*tas(1,2,5) + &
     &     normp  * sqrt(myemitz)*c1m3*tas(1,2,6)

    myy(j)   =                            &
     &     normx  * sqrt(myemitx)*tas(1,3,1) + &
     &     normxp * sqrt(myemitx)*tas(1,3,2) + &
     &     normy  * sqrt(myemity)*tas(1,3,3) + &
     &     normyp * sqrt(myemity)*tas(1,3,4) + &
     &     norms  * sqrt(myemitz)*tas(1,3,5) + &
     &     normp  * sqrt(myemitz)*c1m3*tas(1,3,6)

    myyp(j)  =                            &
     &     normx  * sqrt(myemitx)*tas(1,4,1) + &
     &     normxp * sqrt(myemitx)*tas(1,4,2) + &
     &     normy  * sqrt(myemity)*tas(1,4,3) + &
     &     normyp * sqrt(myemity)*tas(1,4,4) + &
     &     norms  * sqrt(myemitz)*tas(1,4,5) + &
     &     normp  * sqrt(myemitz)*c1m3*tas(1,4,6)

    mys(j)   =                            &
     &     normx  * sqrt(myemitx)*tas(1,5,1) + &
     &     normxp * sqrt(myemitx)*tas(1,5,2) + &
     &     normy  * sqrt(myemity)*tas(1,5,3) + &
     &     normyp * sqrt(myemity)*tas(1,5,4) + &
     &     norms  * sqrt(myemitz)*tas(1,5,5) + &
     &     normp  * sqrt(myemitz)*c1m3*tas(1,5,6)

    myp(j)   =                                    &
     &     normx  * sqrt(myemitx)*c1e3*tas(1,6,1) + &
     &     normxp * sqrt(myemitx)*c1e3*tas(1,6,2) + &
     &     normy  * sqrt(myemity)*c1e3*tas(1,6,3) + &
     &     normyp * sqrt(myemity)*c1e3*tas(1,6,4) + &
     &     norms  * sqrt(myemitz)*c1e3*tas(1,6,5) + &
     &     normp  * sqrt(myemitz)*tas(1,6,6)

! add the momentum
! convert to canonical variables
! dE/E with unit [1] from the closed orbit is added
!For the 4D coordinates the closed orbit
! will be added by SixTrack itself later on.
     myxp(j)  = myxp(j)*(one+myp(j)+clop6v(3,1))
     myyp(j)  = myyp(j)*(one+myp(j)+clop6v(3,1))
! unit conversion for collimation [m] to [mm]
     mys(j)   = mys(j)*c1e3
     myp(j)   = myenom*(one+myp(j))

  end do

10   mynp = j - 1
  write(lout,*) "Number of particles read from the file = ",mynp

  close(filename_dis_unit)
  return

20 continue
   write(lout,*) "I/O Error on Unit 53 in subroutine readdis"
   call prror(-1)

end subroutine readdis_norm


!========================================================================
!
subroutine makedis_radial(mynp, myalphax, myalphay, mybetax,      &
     &mybetay, myemitx0, myemity0, myenom, nr, ndr, myx, myxp, myy, myyp, myp, mys)

  use crcoall
  implicit none

!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy

  real(kind=fPrec) pi

  save
!-----------------------------------------------------------------------
!++  Generate particle distribution
!
!
!++  Generate random distribution, assuming optical parameters at IP1
!
!++  Calculate the gammas

  pi=four*atan_mb(one)

  mygammax = (one+myalphax**2)/mybetax
  mygammay = (one+myalphay**2)/mybetay

!++  Number of points and generate distribution

  mynex = nr/sqrt(two)
  mdex = ndr/sqrt(two)
  myney = nr/sqrt(two)
  mdey = ndr/sqrt(two)

  write(lout,*)
  write(lout,*) 'Generation of particle distribution Version 2'
  write(lout,*)
  write(lout,*) 'This routine generates particles in that are fully'
  write(lout,*) 'correlated between X and Y.'
  write(lout,*)

  write(outlun,*)
  write(outlun,*) 'Generation of particle distribution Version 2'
  write(outlun,*)
  write(outlun,*) 'This routine generates particles in that are fully'
  write(outlun,*) 'correlated between X and Y.'
  write(outlun,*)
  write(outlun,*)
  write(outlun,*) 'INFO>  Number of particles   = ', mynp
  write(outlun,*) 'INFO>  Av number of x sigmas = ', mynex
  write(outlun,*) 'INFO>  +- spread in x sigmas = ', mdex
  write(outlun,*) 'INFO>  Av number of y sigmas = ', myney
  write(outlun,*) 'INFO>  +- spread in y sigmas = ', mdey
  write(outlun,*) 'INFO>  Nominal beam energy   = ', myenom
  write(outlun,*) 'INFO>  Sigma_x0 = ', sqrt(mybetax*myemitx0)
  write(outlun,*) 'INFO>  Sigma_y0 = ', sqrt(mybetay*myemity0)
  write(outlun,*)

  do while (j.lt.mynp)

    j = j + 1
    myemitx = myemitx0*(mynex + ((two*dble(rndm4()-half))*mdex) )**2  !hr09
    xsigmax = sqrt(mybetax*myemitx)
    myx(j)  = xsigmax * sin_mb((two*pi)*real(rndm4(),fPrec))              !hr09

    if (rndm4().gt.half) then
      myxp(j) =      sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax !hr09
    else
      myxp(j) = -one*sqrt(myemitx/mybetax-myx(j)**2/mybetax**2)-(myalphax*myx(j))/mybetax !hr09
    endif

    myemity = myemity0*(myney + ((two*dble(rndm4()-half))*mdey) )**2  !hr09
    ysigmay = sqrt(mybetay*myemity)
    myy(j)  = ysigmay * sin_mb((two*pi)*real(rndm4(),fPrec))          !hr09

    if (rndm4().gt.half) then
      myyp(j)  = sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay      !hr09
    else
      myyp(j)  = -one*sqrt(myemity/mybetay-myy(j)**2/mybetay**2)-(myalphay*myy(j))/mybetay !hr09
    endif

!APRIL2005
    myp(j)   = myenom
!        if(j.eq.1) then
!          myp(j)   = myenom*(1-0.05)
!!       do j=2,mynp
!        else
!          myp(j) = myp(1) + (j-1)*2d0*0.05*myenom/(mynp-1)
!        endif
!APRIL2005
    mys(j)   = zero

!++  Dangerous stuff, just for the moment
!
!        IF ( (.NOT. (Y(j).LT.-.008e-3 .AND. YP(j).LT.0.1e-3 .AND.
!     1               YP(j).GT.0.0) ) .AND.
!     2       (.NOT. (Y(j).GT..008e-3 .AND. YP(j).GT.-0.1e-3 .AND.
!     3               YP(j).LT.0.0) ) ) THEN
!          J = J - 1
!        ENDIF
!
  end do

  return
end subroutine makedis_radial

!>
!! \brief The routine makes an initial Gaussian distribution
!!
!!     Uses the old routine 'MAKEDIS' for the halo plane and adds the\n
!!     transverse beam size in the other plane (matched distrubutions\n
!!     are generated starting from the twiss functions).\n
!!     If 'mynex' and 'myney' are BOTH set to zero, nominal bunches\n
!!     centred in the aperture centre are generated. (SR, 08-05-2005)
!!
!!     YIL EDIT 2010: particle 0 is always on orbit...
!!
!! @author Javier Barranco <jbarranc@cern.ch>
!! @param mynp
!! @param myalphax
!! @param myalphay
!! @param mybetax
!! @param mybetay
!! @param myemitx0
!! @param myemity0
!! @param myenom
!! @param mynex
!! @param mdex
!! @param myney
!! @param mdey
!! @param myx
!! @param myxp
!! @param myy
!! @param myyp
!! @param myp
!! @param mys
!! @param enerror
!! @param bunchlength
!!
!! @date Last modified: 06. August 2009
!! @see ran_gauss
!!
!<
subroutine makedis_ga( mynp, myalphax, myalphay, mybetax, mybetay, myemitx0, myemity0, myenom, mynex, mdex, myney, mdey, &
 &  myx, myxp, myy, myyp, myp, mys, enerror, bunchlength )

  use crcoall
  use parpro
  use mod_commont

  implicit none

!+ca dbmkdist
  integer :: i,j,mynp,nloop
  real(kind=fPrec), allocatable :: myx(:) !(maxn)
  real(kind=fPrec), allocatable :: myxp(:) !(maxn)
  real(kind=fPrec), allocatable :: myy(:) !(maxn)
  real(kind=fPrec), allocatable :: myyp(:) !(maxn)
  real(kind=fPrec), allocatable :: myp(:) !(maxn)
  real(kind=fPrec), allocatable :: mys(:) !(maxn)

  real(kind=fPrec) myalphax,mybetax,myemitx0,myemitx,mynex,mdex, &
  &mygammax,myalphay,mybetay,myemity0,myemity,myney,mdey,mygammay,   &
  &xsigmax,ysigmay,myenom,nr,ndr

  character(len=80) :: dummy


  real(kind=fPrec) pi
!YIL march2010 edit: was missing enerror, bunchlength etc...
! no common block for these parameters?

  real(kind=fPrec) gauss_rand
  real(kind=fPrec) iix, iiy, phix, phiy
  real(kind=fPrec) enerror, bunchlength
  real(kind=fPrec) en_error, bunch_length

  real(kind=fPrec) long_cut
  real(kind=fPrec) a_st, b_st
  integer startpar

  save

!-----------------------------------------------------------------------
!++  Generate particle distribution
!
!++  Generate random distribution, assuming optical parameters at IP1
!
!++  Calculate the gammas
  pi=four*atan_mb(one)

  mygammax = (one+myalphax**2)/mybetax
  mygammay = (one+myalphay**2)/mybetay
  en_error = enerror
  bunch_length = bunchlength

  write (lout,*) "Generation of bunch with dp/p and length:"
  write (lout,*) "  RMS bunch length  = ", bunch_length
  write (lout,*) "  RMS energy spread = ", en_error
! JBG August 2007
  write (lout,*)
  write (lout,*) "   ***STEP 1 for Gaussian Beam***"
  write (lout,*)
  write (lout,*) "   Beam generated with 5 sigma cut"
  write (lout,*)
  write (lout,*) "  Parameters used for Distribution Generation"
  write (lout,*) "  BetaX =", mybetax
  write (lout,*) "  BetaY =", mybetay
  write (lout,*) "  EmittanceX =", myemitx0
  write (lout,*) "  EmittanceY =", myemity0
  write (lout,*)

  startpar=1

#ifdef BEAMGAS
! YIL July 2010 first particle on orbit
!  initial xangle (if any) is not
!  yet applied at this point...
!  so we can set all to 0.
  startpar=2
  myx(1)  = zero     !hr13
  myy(1)  = zero     !hr13
  myxp(1) = zero     !hr13
  myyp(1) = zero     !hr13
  myp(1)  = myenom
  mys(1)  = zero
!YIL end edit July 2010
#endif

  do j=startpar, mynp
! JBG July 2007
! Option added for septum studies

    myemitx = myemitx0
    xsigmax = sqrt(mybetax*myemitx)
    myx(j)  = xsigmax * ran_gauss(mynex)
    myxp(j) = ran_gauss(mynex)*sqrt(myemitx/mybetax)-((myalphax*myx(j))/mybetax)  !hr13
    myemity = myemity0
    ysigmay = sqrt(mybetay*myemity)
    myy(j)  = ysigmay * ran_gauss(myney)
    myyp(j) = ran_gauss(myney)*sqrt(myemity/mybetay)-((myalphay*myy(j))/mybetay)  !hr13
  end do

! SR, 11-08-2005 For longitudinal phase-space, add a cut at 2 sigma
!++   1st: generate mynpnumbers within the chosen cut

  long_cut = 2
  j = startpar

  do while (j.le.mynp)
    a_st = ran_gauss(five)
    b_st = ran_gauss(five)

    do while ((a_st*a_st+b_st*b_st).gt.long_cut*long_cut)
      a_st = ran_gauss(five)
      b_st = ran_gauss(five)
    end do

    mys(j) = a_st
    myp(j) = b_st
    j = j + 1
  end do

!++   2nd: give the correct values
  do j=startpar,mynp
    myp(j) = myenom * (one + myp(j) * en_error)
    mys(j) = bunch_length * mys(j)
  end do

  return
end subroutine makedis_ga

function rndm4()

  implicit none

  integer len, in
  real(kind=fPrec) rndm4, a
  save IN,a
  parameter ( len =  30000 )
  dimension a(len)
  data in/1/

  if( in.eq.1 ) then
    call ranlux(a,len)
!    call ranecu(a,len,-1)
    rndm4=a(1)
    in=2
  else
    rndm4=a(in)
    in=in+1
    if(in.eq.len+1)in=1
  endif

  return

end function rndm4


!ccccccccccccccccccccccccccccccccccccccc
!-TW-01/2007
! function rndm5(irnd) , irnd = 1 will reset
! inn counter => enables reproducible set of
! random unmbers
!cccccccccccccccccccccccccccccccccc
!
function rndm5(irnd)

  implicit none

  integer len, inn, irnd
  real(kind=fPrec) rndm5,a
  save

  parameter( len =  30000 )
  dimension a(len)
  data inn/1/
!
! reset inn to 1 enable reproducible random numbers
  if( irnd .eq. 1) inn = 1

  if( inn.eq.1 ) then
    call ranlux(a,len)
!     call ranecu(a,len,-1)
    rndm5=a(1)
    inn=2
  else
    rndm5=a(inn)
    inn=inn+1
    if(inn.eq.len+1)inn=1
  end if

  return
end function rndm5

!ccccccccccccccccccccccccccccccccccccccc
real(kind=fPrec) function myran_gauss(cut)
!*********************************************************************
!
! myran_gauss - will generate a normal distribution from a uniform
!     distribution between [0,1].
!     See "Communications of the ACM", V. 15 (1972), p. 873.
!
!     cut - real(kind=fPrec) - cut for distribution in units of sigma
!     the cut must be greater than 0.5
!
!     changed rndm4 to rndm5(irnd) and defined flag as true
!
!*********************************************************************

  implicit none

  logical flag
  real(kind=fPrec) x, u1, u2, twopi, r,cut
  save

  flag = .true. !Does this initialize only once, or is it executed every pass?
                !See ran_gauss(cut)

  twopi=eight*atan_mb(one)
1 if (flag) then
    r = dble(rndm5(0))
    r = max(r, half**32)
    r = min(r, one-half**32)
    u1 = sqrt(-two*log_mb( r ))
    u2 = real(rndm5(0),fPrec)
    x = u1 * cos_mb(twopi*u2)
  else
     x = u1 * sin_mb(twopi*u2)
  endif

  flag = .not. flag

!     cut the distribution if cut > 0.5
  if (cut .gt. half .and. abs(x) .gt. cut) goto 1

  myran_gauss = x
  return
end function myran_gauss


!cccccccccccccccccccccccccccccccccccccccccccccccccc
subroutine funlxp (func,xfcum,x2low,x2high)
!         F. JAMES,   Sept, 1994
!
!         Prepares the user function FUNC for FUNLUX
!         Inspired by and mostly copied from FUNPRE and FUNRAN
!         except that
!    1. FUNLUX uses RANLUX underneath,
!    2. FUNLXP expands the first and last bins to cater for
!              functions with long tails on left and/or right,
!    3. FUNLXP calls FUNPCT to do the actual finding of percentiles.
!    4. both FUNLXP and FUNPCT use RADAPT for Gaussian integration.
!
      use crcoall
      implicit none
      external func
      integer ifunc,ierr
      real(kind=fPrec) x2high,x2low,xfcum,rteps,xhigh,xlow,xrange,uncert,x2,tftot1,x3,tftot2,func
!+ca funint
      dimension xfcum(200)
      parameter (rteps=0.0002)
      save ifunc
      data ifunc/0/
      ifunc = ifunc + 1
!         FIND RANGE WHERE FUNCTION IS NON-ZERO.
      call funlz(func,x2low,x2high,xlow,xhigh)
      xrange = xhigh-xlow
      if(xrange .le. 0.)  then
        write(lout,'(A,2G15.5)') ' FUNLXP finds function range .LE.0',xlow,xhigh
        go to 900
      endif
      call radapt(func,xlow,xhigh,1,rteps,zero,tftot ,uncert)
!      WRITE(6,1003) IFUNC,XLOW,XHIGH,TFTOT
 1003 format(' FUNLXP: integral of USER FUNCTION', i3,' from ',e12.5,' to ',e12.5,' is ',e14.6)
!
!      WRITE (6,'(A,A)') ' FUNLXP preparing ',
!     + 'first the whole range, then left tail, then right tail.'
      call funpct(func,ifunc,xlow,xhigh,xfcum,1,99,tftot,ierr)
      if (ierr .gt. 0)  go to 900
      x2 = xfcum(3)
      call radapt(func,xlow,x2,1,rteps,zero,tftot1 ,uncert)
      call funpct(func,ifunc,xlow,x2 ,xfcum,101,49,tftot1,ierr)
      if (ierr .gt. 0)  go to 900
      x3 = xfcum(98)
      call radapt(func,x3,xhigh,1,rteps,zero,tftot2 ,uncert)
      call funpct(func,ifunc,x3,xhigh,xfcum,151,49,tftot2,ierr)
      if (ierr .gt. 0)  go to 900
!      WRITE(6,1001) IFUNC,XLOW,XHIGH
 1001 format(' FUNLXP has prepared USER FUNCTION', i3, ' between',g12.3,' and',g12.3,' for FUNLUX')
      return
  900 continue
      write(lout,*) ' Fatal error in FUNLXP. FUNLUX will not work.'
end subroutine funlxp

subroutine funpct(func,ifunc,xlow,xhigh,xfcum,nlo,nbins,tftot,ierr)
!        Array XFCUM is filled from NLO to NLO+NBINS, which makes
!        the number of values NBINS+1, or the number of bins NBINS
      use crcoall
      implicit none
      external func
      integer ierr,nbins,nlo,ifunc,nz,ibin,maxz,iz,nitmax,ihome
      real(kind=fPrec) tftot,xhigh,xlow,func,xfcum,rteps,tpctil,tz,tzmax,x,f,tcum,  &
     &x1,f1,dxmax,fmin,fminz,xincr,tincr,xbest,dtbest,tpart,x2,precis,  &
     &refx,uncert,tpart2,dtpar2,dtabs,aberr
      dimension xfcum(*)
      parameter (rteps=0.005, nz=10, maxz=20, nitmax=6,precis=1e-6)
!      DOUBLE PRECISION TPCTIL, TZ, TCUM, XINCR, DTABS,
!     &  TINCR, TZMAX, XBEST, DTBEST, DTPAR2
!
      ierr = 0
      if (tftot .le. 0.) go to 900
      tpctil = tftot/real(nbins)                                         !hr09
      tz = tpctil/real(nz)
      tzmax = tz * 2.
      xfcum(nlo) = xlow
      xfcum(nlo+nbins) = xhigh
      x = xlow
      f = func(x)
      if (f .lt. 0.) go to 900
!         Loop over percentile bins
      do 600 ibin = nlo, nlo+nbins-2
      tcum = 0.
      x1 = x
      f1 = f
      dxmax = (xhigh -x) / nz
      fmin = tz/dxmax
      fminz = fmin
!         Loop over trapezoids within a supposed percentil
      do 500 iz= 1, maxz
      xincr = tz/max(f1,fmin,fminz)
  350 x = x1 + xincr
      f = func(x)
      if (f .lt. 0.) go to 900
      tincr = ((x-x1) * 0.5) * (f+f1)                                    !hr09
      if (tincr .lt. tzmax) go to 370
      xincr = xincr * 0.5
      go to 350
  370 continue
      tcum = tcum + tincr
      if (tcum .ge. tpctil*0.99) go to 520
      fminz = (tz*f)/ (tpctil-tcum)                                      !hr09
      f1 = f
      x1 = x
  500 continue
      write(lout,*) ' FUNLUX:  WARNING. FUNPCT fails trapezoid.'
!         END OF TRAPEZOID LOOP
!         Adjust interval using Gaussian integration with
!             Newton corrections since F is the derivative
  520 continue
      x1 = xfcum(ibin)
      xbest = x
      dtbest = tpctil
      tpart = tpctil
!         Allow for maximum NITMAX more iterations on RADAPT
      do 550 ihome= 1, nitmax
  535 xincr = (tpctil-tpart) / max(f,fmin)
      x = xbest + xincr
      x2 = x
        if (ihome .gt. 1 .and. x2 .eq. xbest) then
        write(lout,'(A,G12.3)') ' FUNLUX: WARNING from FUNPCT: insufficient precision at X=',x
        go to 580
        endif
      refx = abs(x)+precis
      call radapt(func,x1,x2,1,rteps,zero,tpart2,uncert)
      dtpar2 = tpart2-tpctil
      dtabs = abs(dtpar2)
      if(abs(xincr)/refx .lt. precis) goto 545
      if(dtabs .lt. dtbest) goto 545
      xincr = xincr * 0.5
      goto 535
  545 dtbest = dtabs
      xbest = x
      tpart = tpart2
      f = func(x)
      if(f .lt. 0.) goto 900
      if(dtabs .lt. rteps*tpctil) goto 580
  550 continue
      write(lout,'(A,I4)') ' FUNLUX: WARNING from FUNPCT: cannot converge, bin',ibin

  580 continue
      xincr = (tpctil-tpart) / max(f,fmin)
      x = xbest + xincr
      xfcum(ibin+1) = x
      f = func(x)
      if(f .lt. 0.) goto 900
  600 continue
!         END OF LOOP OVER BINS
      x1 = xfcum((nlo+nbins)-1)                                          !hr09
      x2 = xhigh
      call radapt(func,x1,x2,1,rteps,zero,tpart ,uncert)
      aberr = abs(tpart-tpctil)/tftot
!      WRITE(6,1001) IFUNC,XLOW,XHIGH
      if(aberr .gt. rteps)  write(lout,1002) aberr
      return
  900 write(lout,1000) x,f
      ierr = 1
      return
 1000 format(/' FUNLUX fatal error in FUNPCT: function negative:'/      &
&,' at X=',e15.6,', F=',e15.6/)
! 1001 FORMAT(' FUNPCT has prepared USER FUNCTION',I3,
!     + ' between',G12.3,' and',G12.3,' for FUNLUX.')
 1002 format(' WARNING: Relative error in cumulative distribution may be as big as',f10.7)

end subroutine funpct

!cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

subroutine funlux(array,xran,len)
!         Generation of LEN random numbers in any given distribution,
!         by 4-point interpolation in the inverse cumulative distr.
!         which was previously generated by FUNLXP
      implicit none
!+ca funint
      integer len,ibuf,j,j1
      real(kind=fPrec) array,xran,gap,gapinv,tleft,bright,gaps,gapins,x,p,a,b
      dimension array(200)
      dimension xran(len)
!  Bin width for main sequence, and its inverse
      parameter (gap= 1./99.,  gapinv=99.)
!  Top of left tail, bottom of right tail (each tail replaces 2 bins)
      parameter (tleft= 2./99.,bright=97./99.)
!  Bin width for minor sequences (tails), and its inverse
      parameter (gaps=tleft/49.,  gapins=1./gaps)
!
!   The array ARRAY is assumed to have the following structure:
!        ARRAY(1-100) contains the 99 bins of the inverse cumulative
!                     distribution of the entire function.
!        ARRAY(101-150) contains the 49-bin blowup of main bins
!                       1 and 2 (left tail of distribution)
!        ARRAY(151-200) contains the 49-bin blowup of main bins
!                       98 and 99 (right tail of distribution)
!
      call ranlux(xran,len)
!      call ranecu(xran,len,-1)

      do 500 ibuf= 1, len
      x = xran(ibuf)
      j = int(  x    *gapinv) + 1
      if (j .lt. 3)  then
         j1 = int( x *gapins)
             j = j1 + 101
             j = max(j,102)
             j = min(j,148)
         p = (   x -gaps*real(j1-1)) * gapins                            !hr09
         a = (p+1.0) * array(j+2) - (p-2.0)*array(j-1)
         b = (p-1.0) * array(j) - p * array(j+1)
      xran(ibuf) = ((a*p)*(p-1.0))*0.16666667 + ((b*(p+1.))*(p-2.))*0.5  !hr09
      else if (j .gt. 97)  then
         j1 = int((x-bright)*gapins)
             j = j1 + 151
             j = max(j,152)
             j = min(j,198)
         p = ((x -bright) -gaps*(j1-1)) * gapins                         !hr09
         a = (p+1.0) * array(j+2) - (p-2.0)*array(j-1)
         b = (p-1.0) * array(j) - p * array(j+1)
      xran(ibuf) = ((a*p)*(p-1.0))*0.16666667 + ((b*(p+1.))*(p-2.))*0.5  !hr09
      else
!      J = MAX(J,2)
!      J = MIN(J,98)
         p = (   x -gap*real(j-1)) * gapinv                              !hr09
         a = (p+1.) * array(j+2) - (p-2.)*array(j-1)
         b = (p-1.) * array(j) - p * array(j+1)
      xran(ibuf) = ((a*p)*(p-1.))*0.16666667 + ((b*(p+1.))*(p-2.))*0.5   !hr09
      endif
  500 continue
      tftot = x
      return
end subroutine funlux

subroutine funlz(func,x2low,x2high,xlow,xhigh)
! FIND RANGE WHERE FUNC IS NON-ZERO.
! WRITTEN 1980, F. JAMES
! MODIFIED, NOV. 1985, TO FIX BUG AND GENERALIZE
! TO FIND SIMPLY-CONNECTED NON-ZERO REGION (XLOW,XHIGH)
! ANYWHERE WITHIN THE GIVEN REGION (X2LOW,H2HIGH).
!    WHERE 'ANYWHERE' MEANS EITHER AT THE LOWER OR UPPER
!    EDGE OF THE GIVEN REGION, OR, IF IN THE MIDDLE,
!    COVERING AT LEAST 1% OF THE GIVEN REGION.
! OTHERWISE IT IS NOT GUARANTEED TO FIND THE NON-ZERO REGION.
! IF FUNCTION EVERYWHERE ZERO, FUNLZ SETS XLOW=XHIGH=0.
      use crcoall
      implicit none
      external func
      integer logn,nslice,i,k
      real(kind=fPrec) xhigh,xlow,x2high,x2low,func,xmid,xh,xl,xnew
      xlow = x2low
      xhigh = x2high
!         FIND OUT IF FUNCTION IS ZERO AT ONE END OR BOTH
      xmid = xlow
      if (func(xlow) .gt. 0.) go to 120
      xmid = xhigh
      if (func(xhigh) .gt. 0.)  go to 50
!         FUNCTION IS ZERO AT BOTH ENDS,
!         LOOK FOR PLACE WHERE IT IS NON-ZERO.
      do 30 logn= 1, 7
      nslice = 2**logn
      do 20 i= 1, nslice, 2
      xmid = xlow + (real(i) * (xhigh-xlow)) / real(nslice)              !hr09
      if (func(xmid) .gt. 0.)  go to 50
   20 continue
   30 continue
!         FALLING THROUGH LOOP MEANS CANNOT FIND NON-ZERO VALUE
      write(lout,554)
      write(lout,555) xlow, xhigh
      xlow = 0.
      xhigh = 0.
      go to 220
!
   50 continue
!         DELETE 'LEADING' ZERO RANGE
      xh = xmid
      xl = xlow
      do 70 k= 1, 20
      xnew = 0.5*(xh+xl)
      if (func(xnew) .eq. 0.) go to 68
      xh = xnew
      go to 70
   68 xl = xnew
   70 continue
      xlow = xl
      write(lout,555) x2low,xlow
  120 continue
      if (func(xhigh) .gt. 0.) go to 220
!         DELETE 'TRAILING' RANGE OF ZEROES
      xl = xmid
      xh = xhigh
      do 170 k= 1, 20
      xnew = 0.5*(xh+xl)
      if (func(xnew) .eq. 0.) go to 168
      xl = xnew
      go to 170
  168 xh = xnew
  170 continue
      xhigh = xh
      write(lout,555) xhigh, x2high
!
  220 continue
      return
  554 format('0CANNOT FIND NON-ZERO FUNCTION VALUE')
  555 format(' FUNCTION IS ZERO FROM X=',e12.5,' TO ',e12.5)
end subroutine funlz

!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
subroutine radapt(f,a,b,nseg,reltol,abstol,res,err)

! RES = Estimated Integral of F from A to B,
! ERR = Estimated absolute error on RES.
! NSEG  specifies how the adaptation is to be done:
!    =0   means use previous binning,
!    =1   means fully automatic, adapt until tolerance attained.
!    =n>1 means first split interval into n equal segments,
!         then adapt as necessary to attain tolerance.
! The specified tolerances are:
!        relative: RELTOL ;  absolute: ABSTOL.
!    It stop s when one OR the other is satisfied, or number of
!    segments exceeds NDIM.  Either TOLA or TOLR (but not both!)
!    can be set to zero, in which case only the other is used.

      implicit none

      external f
      integer nseg,ndim,nter,nsegd,i,iter,ibig
      real(kind=fPrec) err,res,abstol,reltol,b,a,xlo,xhi,tval,ters,te,root,xhib,bin,xlob,bige,hf,xnew,r1,f
      real(kind=fPrec) tvals,terss

      parameter (ndim=100)
      parameter (r1 = 1., hf = r1/2.)

      dimension xlo(ndim),xhi(ndim),tval(ndim),ters(ndim)
      save xlo,xhi,tval,ters,nter
      data nter /0/

      if(nseg .le. 0)  then
       if(nter .eq. 0) then
        nsegd=1
        go to 2
       endif
       tvals=zero
       terss=zero
       do 1 i = 1,nter
       call rgs56p(f,xlo(i),xhi(i),tval(i),te)
       ters(i)=te**2
       tvals=tvals+tval(i)                                         !hr09
       terss=terss+ters(i)
    1  continue
       root= sqrt(two*terss)                                      !hr09
       go to 9
      endif
      nsegd=min(nseg,ndim)
    2 xhib=a
      bin=(b-a)/real(nsegd,fPrec)                                              !hr09
      do 3 i = 1,nsegd
      xlo(i)=xhib
      xlob=xlo(i)
      xhi(i)=xhib+bin
      if(i .eq. nsegd) xhi(i)=b
      xhib=xhi(i)
      call rgs56p(f,xlob,xhib,tval(i),te)
      ters(i)=te**2
    3 continue
      nter=nsegd
      do 4 iter = 1,ndim
      tvals=tval(1)                                                !hr09
      terss=ters(1)                                                !hr09
      do 5 i = 2,nter
      tvals=tvals+tval(i)                                          !hr09
      terss=terss+ters(i)                                          !hr09
    5 continue
      root=sqrt(two*terss)                                       !hr09

      if(root .le. abstol .or. root .le. reltol*abs(tvals)) then
        goto 9
      end if

      if(nter .eq. ndim) go to 9
      bige=ters(1)
      ibig=1
      do 6 i = 2,nter
      if(ters(i) .gt. bige) then
       bige=ters(i)
       ibig=i
      endif
    6 continue
      nter=nter+1
      xhi(nter)=xhi(ibig)
      xnew=hf*(xlo(ibig)+xhi(ibig))
      xhi(ibig)=xnew
      xlo(nter)=xnew
      call rgs56p(f,xlo(ibig),xhi(ibig),tval(ibig),te)
      ters(ibig)=te**2
      call rgs56p(f,xlo(nter),xhi(nter),tval(nter),te)
      ters(nter)=te**2
    4 continue
    9 res=tvals                                                    !hr09
      err=root
      return
end subroutine radapt

!cccccccccccccccccccccccccccccccccccccccccccccccccccccc
subroutine rgs56p(f,a,b,res,err)

  implicit none

  integer i
  real(kind=fPrec) err,res,b,a,f,w6,x6,w5,x5,rang,r1,hf
  real(kind=fPrec) e5,e6

  parameter (r1 = 1., hf = r1/2.)
  dimension x5(5),w5(5),x6(6),w6(6)

  data (x5(i),w5(i),i=1,5)                                          &
 &/4.6910077030668004e-02, 1.1846344252809454e-01,                  &
 &2.3076534494715846e-01, 2.3931433524968324e-01,                   &
 &5.0000000000000000e-01, 2.8444444444444444e-01,                   &
 &7.6923465505284154e-01, 2.3931433524968324e-01,                   &
 &9.5308992296933200e-01, 1.1846344252809454e-01/

  data (x6(i),w6(i),i=1,6)                                          &
 &/3.3765242898423989e-02, 8.5662246189585178e-02,                  &
 &1.6939530676686775e-01, 1.8038078652406930e-01,                   &
 &3.8069040695840155e-01, 2.3395696728634552e-01,                   &
 &6.1930959304159845e-01, 2.3395696728634552e-01,                   &
 &8.3060469323313225e-01, 1.8038078652406930e-01,                   &
 &9.6623475710157601e-01, 8.5662246189585178e-02/

  rang=b-a
  e5=zero
  e6=zero
  do i = 1,5
    e5=e5+dble(w5(i)*f(a+rang*x5(i)))                                  !hr09
    e6=e6+dble(w6(i)*f(a+rang*x6(i)))                                  !hr09
  end do

  e6=e6+dble(w6(6)*f(a+rang*x6(6)))
  res=real((dble(hf)*(e6+e5))*dble(rang))                            !hr09
  err=real(abs((e6-e5)*dble(rang)))                                  !hr09
  return
end subroutine rgs56p

!*********************************************************************
!
! Define INTEGER function MCLOCK that can differ from system to system
! For re-initializtion of random generator
!
!*********************************************************************
integer function mclock_liar( )
  use crcoall
  implicit none

  save

  integer    mclock
  integer    count_rate, count_max
  logical    clock_ok

!        MCLOCK_LIAR = MCLOCK()

  clock_ok = .true.

  if (clock_ok) then
    call system_clock( mclock, count_rate, count_max )
    if ( count_max .eq. 0 ) then
      clock_ok = .false.
      write(lout,*)'INFO>  System Clock not present or not Responding'
      write(lout,*)'INFO>  R.N.G. Reseed operation disabled.'
    endif
  endif

  mclock_liar = mclock

  return
end function mclock_liar


real(kind=fPrec) function ran_gauss(cut)
!*********************************************************************
!
! RAN_GAUSS - will generate a normal distribution from a uniform
!   distribution between [0,1].
!   See "Communications of the ACM", V. 15 (1972), p. 873.
!
! cut - real(kind=fPrec) - cut for distribution in units of sigma
!                the cut must be greater than 0.5
!
!*********************************************************************

  use crcoall
  use parpro
  implicit none

  logical flag
  DATA flag/.TRUE./
  real(kind=fPrec) x, u1, u2, twopi, r,cut

  save

  twopi=eight*atan_mb(one) !Why not 2*pi, where pi is in block "common"?
1 if (flag) then
    r = dble(rndm4( ))
    r = max(r, half**32)
    r = min(r, one-half**32)
    u1 = sqrt(-two*log_mb( r ))
    u2 = dble(rndm4( ))
    x = u1 * cos_mb(twopi*u2)
  else
    x = u1 * sin_mb(twopi*u2)
  endif

  flag = .not. flag

!  cut the distribution if cut > 0.5
  if (cut .gt. half .and. abs(x) .gt. cut) goto 1

  ran_gauss = x
  return
end function ran_gauss

!>
!! readcollimator()
!! This routine is called once at the start of the simulation and
!! is used to read the collimator settings input file
!<
subroutine readcollimator
  use crcoall
  use parpro

#ifdef ROOT
  use iso_c_binding
  use root_output
#endif

  implicit none

  integer I,J,K,ios

!+ca database
!+ca dbcommon

  logical lopen

#ifdef ROOT
! Temp variables to avoid fotran array -> C nightmares
  character(len=max_name_len+1) :: this_name = C_NULL_CHAR
  character(len=5) :: this_material = C_NULL_CHAR
#endif

  save
!--------------------------------------------------------------------
!++  Read collimator database
!
!      write(*,*) 'reading collimator database'
!  inquire( unit=53, opened=lopen )
!  if(lopen) then
!    write(lout,*) "ERROR in subroutine readcollimator: FORTRAN Unit 53 was already open!"
!    call prror(-1)
!  end if

  call funit_requestUnit(coll_db, coll_db_unit)
  open(unit=coll_db_unit,file=coll_db, iostat=ios, status="OLD",action="read") !was 53
  if(ios.ne.0)then
    write(lout,*) "Error in subroutine readcollimator: Could not open the file ",coll_db
    write(lout,*) "Got iostat=",ios
    call prror(-1)
  end if

  read(coll_db_unit,*)
  read(coll_db_unit,*,iostat=ios) db_ncoll
  write(lout,*) 'number of collimators = ',db_ncoll
!     write(*,*) 'ios = ',ios
  if(ios.ne.0) then
    write(outlun,*) 'ERR>  Problem reading collimator DB ',ios
    call prror(-1)
  end if

  if(db_ncoll.gt.max_ncoll) then
    write(lout,*) 'ERR> db_ncoll > max_ncoll '
    call prror(-1)
  end if

  do j=1,db_ncoll
    read(coll_db_unit,*)
!GRD ALLOW TO RECOGNIZE BOTH CAPITAL AND NORMAL LETTERS
    read(coll_db_unit,*,iostat=ios) db_name1(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if

    read(coll_db_unit,*,iostat=ios) db_name2(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if

    read(coll_db_unit,*,iostat=ios) db_nsig(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if
    !GRD
    read(coll_db_unit,*,iostat=ios) db_material(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if
    read(coll_db_unit,*,iostat=ios) db_length(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if
    read(coll_db_unit,*,iostat=ios) db_rotation(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if
    read(coll_db_unit,*,iostat=ios) db_offset(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if
    read(coll_db_unit,*,iostat=ios) db_bx(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if
    read(coll_db_unit,*,iostat=ios) db_by(j)
!        write(*,*) 'ios = ',ios
    if(ios.ne.0) then
      write(outlun,*) 'ERR>  Problem reading collimator DB ', j,ios
      call prror(-1)
    end if

#ifdef ROOT
    if(root_flag .and. root_CollimationDB.eq.1) then
      this_name = trim(adjustl(db_name1(j))) // C_NULL_CHAR
      this_material = trim(adjustl(db_material(j))) // C_NULL_CHAR
      call CollimatorDatabaseRootWrite(j, this_name, len_trim(this_name), this_material, len_trim(this_material), db_nsig(j), &
&     db_length(j), db_rotation(j), db_offset(j))
    end if
#endif

  end do

  close(coll_db_unit)

#ifdef ROOT
! flush the root file
!  call SixTrackRootWrite()
#endif

end subroutine readcollimator

subroutine collimation_comnul
  use parpro
  implicit none

!+ca database
!+ca dbcommon

  do_coll = .false.

  ! From common /grd/
  emitnx0_dist = zero
  emitny0_dist = zero
  emitnx0_collgap = zero
  emitny0_collgap = zero

  ! From common /ralph/
  myemitx0_dist = zero
  myemity0_dist = zero
  myemitx0_collgap = zero
  myemity0_collgap = zero
end subroutine collimation_comnul

end module collimation