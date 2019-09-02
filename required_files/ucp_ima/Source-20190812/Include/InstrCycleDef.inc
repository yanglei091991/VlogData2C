/*
 * ===================================================================
 *
 *        Filename:  InstrCycleDef.inc
 *
 *         Created:  2019-01-22 
 *   Last Modified:  2019-01-22
 *          Author:  Weilu CHEN , weilu.chen@ia.ac.cn
 *    Organization:  National ASIC Design Engineering Center, IACAS
 *
 *     Description:  SystemVerilog Code
 *
 *
 * ===================================================================
 */


   /////////////////////////// MReg ///////////////////////////
   // DP1
   MRINDEX_AHEAD_CYCLE          =   2
   // 2 clock cycles in advance of EXE done
   MWINDEX_AHEAD_CYCLE          =   2

   /////////////////////////// MReg ///////////////////////////
   // read MReg 
   MR_IMA_CYCLE                 =   2
   MR_SHU_CYCLE                 =   2
   MR_BIU_CYCLE                 =   2
   // write config_MFetch       =   
   MW_CONFIGMFETCH_CYCLE        =   2
   // write ConfigMRegLatch
   MW_CONFIGMREGLATCH_CYCLE     =   2
   // write config_M_read       =   
   MW_CONFIGMR_CYCLE            =   2
   // write config_M_write      =   
   MW_CONFIGMW_CYCLE            =   2
   // read config_M_read        =   
   MR_CONFIGMR_CYCLE            =   1
   // read config_M_write       =   
   MR_CONFIGMW_CYCLE            =   1
   // release correspondence between read port and latch
   M_CLRRLATCH_CYCLE            =   2
   // M set condition
   M_SETCOND_CYCLE              =   1
   // R0.M SetCG
   M_SETCG_CYCLE                =   1
   
  
   ////////////////////////// SHU //////////////////////////
   // shuffle instruction 0,1
   SHUIND_BIU_CYCLE             =   2
   SHUIND_M_CYCLE               =   3  
   SHUIND_IMA_CYCLE             =   2
   SHUIND_SHU_CYCLE             =   2
   SHUIND_T7_CYCLE              =   1
   // add instruction 0,1
   SHUADD_BIU_CYCLE             =   2
   SHUADD_M_CYCLE               =   3  
   SHUADD_IMA_CYCLE             =   2
   SHUADD_SHU_CYCLE             =   1
   // shift
   SHUSHIFT_BIU_CYCLE           =   2
   SHUSHIFT_M_CYCLE             =   3  
   SHUSHIFT_IMA_CYCLE           =   2
   SHUSHIFT_SHU_CYCLE           =   1
   // logical operation
   SHULOGIC_BIU_CYCLE           =   2
   SHULOGIC_M_CYCLE             =   3
   SHULOGIC_IMA_CYCLE           =   2
   SHULOGIC_SHU_CYCLE           =   1
   // convert to bit
   SHUBIT_BIU_CYCLE             =   2
   SHUBIT_M_CYCLE               =   3
   SHUBIT_IMA_CYCLE             =   2
   SHUBIT_SHU_CYCLE             =   1
   // convert to byte
   SHUBYTE_BIU_CYCLE            =   2
   SHUBYTE_M_CYCLE              =   3
   SHUBYTE_IMA_CYCLE            =   2
   SHUBYTE_SHU_CYCLE            =   1
   // spacer step
   SHUSTEP_BIU_CYCLE            =   2
   SHUSTEP_M_CYCLE              =   3
   SHUSTEP_IMA_CYCLE            =   2
   SHUSTEP_SHU_CYCLE            =   1
   // anti-pacer step
   SHUNOSTEP_BIU_CYCLE          =   2
   SHUNOSTEP_M_CYCLE            =   3
   SHUNOSTEP_IMA_CYCLE          =   2
   SHUNOSTEP_SHU_CYCLE          =   1
   // SHU set condition
   SHU_SETCOND_CYCLE            =   1
   // SHU SetCG
   SHU_SETCG_CYCLE              =   1
   // Turbo
   SHUTURBO_BIU_CYCLE           =   2
   SHUTURBO_M_CYCLE             =   3  
   SHUTURBO_IMA_CYCLE           =   2
   SHUTURBO_SHU_CYCLE           =   1


   ////////////////////////// BIU //////////////////////////
   // BIU Load
   BIULD_BIU_CYCLE              =   8
   BIULD_M_CYCLE                =   9
   BIULD_MC_CYCLE               =   8
   BIULD_IMA_CYCLE              =   9
   BIULD_SHU_CYCLE              =   8
   // BIU Store
   BIUST_CYCLE                  =   4
   // BIU Move(BIUKG)
   BIUKG_CYCLE                  =   3
   // BIU Move(BIUKG)
   BIUKG_MC_CYCLE               =   2
   // BIU Add
   BIUADD_CYCLE                 =   2
   // BIU Sub
   BIUSUB_CYCLE                 =   2
   // BIU AddWR
   BIUADDWR_CYCLE               =   2
   // BIU SubWR
   BIUSUBWR_CYCLE               =   2
   // BIU logical operation: AND, OR, XOR, INV, COMPARE
   BIULOGIC_CYCLE               =   2
   // BIU Mask generate
   BIUMASKGEN_CYCLE             =   2
   // BIU Shift: BIULShiftImm, BIULShift, BIURShift
   BIUSHIFT_CYCLE               =   2
   // BIU Imm
   BIUIMM_CYCLE                 =   2
   // BIU Mov
   BIUMOV_CYCLE                 =   2
   // BIU MovALL
   BIUMOVALL_CYCLE              =   1
   // BIUBitInvert
   BIUINV_CYCLE                 =   2
   // BIU Set Condition
   BIU_SETCOND_CYCLE            =   1
   // BIU SetCG
   BIU_SETCG_CYCLE              =   1


   ////////////////////////// IMA //////////////////////////
   // flag update because of calculating
   IMAALUFLAG_CYCLE             =   1
   IMAMACFLAG_CYCLE             =   3
   // IMA Mul: mul, mul add, add
   IMAMUL_BIU_CYCLE             =   5
   IMAMUL_M_CYCLE               =   5
   IMAMUL_SHU_CYCLE             =   4
   IMAMUL_IMA_CYCLE             =   4   // does not include itself
   IMAMUL_IMAT_CYCLE            =   4   // itself
   IMAMUL_IMAMR_CYCLE           =   3   
   // IMA SetMR
   IMASETMR_CYCLE               =   2
   // IMA ReadMR
   IMARMR_BIU_CYCLE             =   5
   IMARMR_M_CYCLE               =   5
   IMARMR_SHU_CYCLE             =   4
   IMARMR_IMA_CYCLE             =   4
   IMARMR_IMAT_CYCLE            =   4
   // IMA SetShiftMode
   IMASETSHMODE_CYCLE           =   2
   // IMA Read FLAG
   IMARFLAG_BIU_CYCLE           =   5
   IMARFLAG_M_CYCLE             =   5
   IMARFLAG_SHU_CYCLE           =   4
   IMARFLAG_IMA_CYCLE           =   4
   IMARFLAG_IMAT_CYCLE          =   4
   IMARFLAG_MFETCH_CYCLE        =   4
   // IMA Write FLAG
   IMAWFLAG_CYCLE               =   2
   // IMA SetCmpMR
   IMASETCMPMR_CYCLE            =   3
   // IMA CmpMR
   IMACMPMR_M_CYCLE             =   5
   IMACMPMR_IMA_CYCLE           =   4
   IMACMPMR_IMAT_CYCLE          =   4
   IMACMPMR_IMAMR_CYCLE         =   3
   // IMA RMax
   IMARMAX_BIU_CYCLE            =   5
   IMARMAX_M_CYCLE              =   5
   IMARMAX_SHU_CYCLE            =   4
   IMARMAX_IMA_CYCLE            =   4   
   IMARMAX_IMAT_CYCLE           =   4   
   IMARMAX_IMAMR_CYCLE          =   3   
   // IMA RMin
   IMARMIN_BIU_CYCLE            =   5
   IMARMIN_M_CYCLE              =   5
   IMARMIN_SHU_CYCLE            =   4
   IMARMIN_IMA_CYCLE            =   4   
   IMARMIN_IMAT_CYCLE           =   4   
   IMARMIN_IMAMR_CYCLE          =   3   
   // IMA Turbo
   IMATURBO_BIU_CYCLE           =   5
   IMATURBO_M_CYCLE             =   5
   IMATURBO_SHU_CYCLE           =   4
   IMATURBO_IMA_CYCLE           =   4
   IMATURBO_IMAT_CYCLE          =   4
   // IMA SetTurboAB
   IMASETTURBOAB_CYCLE          =   2
   // IMA Add, RAdd, ModAdd
   IMAADD_BIU_CYCLE             =   3
   IMAADD_M_CYCLE               =   3
   IMAADD_SHU_CYCLE             =   2
   IMAADD_IMA_CYCLE             =   2   
   IMAADD_IMAT_CYCLE            =   2   
   // IMA Sub
   IMASUB_BIU_CYCLE             =   3
   IMASUB_M_CYCLE               =   3
   IMASUB_SHU_CYCLE             =   2
   IMASUB_IMA_CYCLE             =   2   
   IMASUB_IMAT_CYCLE            =   1   
   // IMA Mov
   IMAMOV_BIU_CYCLE             =   3
   IMAMOV_M_CYCLE               =   3
   IMAMOV_SHU_CYCLE             =   2
   IMAMOV_IMA_CYCLE             =   2   
   IMAMOV_IMAT_CYCLE            =   2   
   // IMA Conj
   IMACONJ_BIU_CYCLE            =   3
   IMACONJ_M_CYCLE              =   3
   IMACONJ_SHU_CYCLE            =   2
   IMACONJ_IMA_CYCLE            =   2   
   IMACONJ_IMAT_CYCLE           =   2   
   // IMA ABS
   IMAABS_BIU_CYCLE             =   3
   IMAABS_M_CYCLE               =   3
   IMAABS_SHU_CYCLE             =   2
   IMAABS_IMA_CYCLE             =   2   
   IMAABS_IMAT_CYCLE            =   2   
   // IMA Bor
   IMABOR_BIU_CYCLE             =   3
   IMABOR_M_CYCLE               =   3
   IMABOR_SHU_CYCLE             =   2
   IMABOR_IMA_CYCLE             =   2   
   IMABOR_IMAT_CYCLE            =   2   
   // IMA Logic
   IMALOGIC_BIU_CYCLE           =   3
   IMALOGIC_M_CYCLE             =   3
   IMALOGIC_SHU_CYCLE           =   2
   IMALOGIC_IMA_CYCLE           =   2
   IMALOGIC_IMAT_CYCLE          =   2
   // IMA CompSel
   IMACOMPSEL_BIU_CYCLE         =   3
   IMACOMPSEL_M_CYCLE           =   3
   IMACOMPSEL_SHU_CYCLE         =   2
   IMACOMPSEL_IMA_CYCLE         =   2   
   IMACOMPSEL_IMAT_CYCLE        =   1
   // IMA CompSelgs
   IMACOMPSELGS_BIU_CYCLE       =   5
   IMACOMPSELGS_M_CYCLE         =   5
   IMACOMPSELGS_SHU_CYCLE       =   4
   IMACOMPSELGS_IMA_CYCLE       =   4   
   IMACOMPSELGS_IMAT_CYCLE      =   3
   // IMA Triple
   IMATRIPLE_BIU_CYCLE          =   3
   IMATRIPLE_M_CYCLE            =   3
   IMATRIPLE_SHU_CYCLE          =   2
   IMATRIPLE_IMA_CYCLE          =   2
   IMATRIPLE_IMAT_CYCLE         =   2
   // IMA Cprs
   IMACPRS_BIU_CYCLE            =   3
   IMACPRS_M_CYCLE              =   3
   IMACPRS_SHU_CYCLE            =   2
   IMACPRS_IMA_CYCLE            =   2
   IMACPRS_IMAT_CYCLE           =   2
   // IMA Expd
   IMAEXPD_BIU_CYCLE            =   3
   IMAEXPD_M_CYCLE              =   3
   IMAEXPD_SHU_CYCLE            =   2
   IMAEXPD_IMA_CYCLE            =   2
   IMAEXPD_IMAT_CYCLE           =   2
   // IMA Index
   IMAINDEX_BIU_CYCLE           =   3
   IMAINDEX_M_CYCLE             =   3
   IMAINDEX_SHU_CYCLE           =   2
   IMAINDEX_IMA_CYCLE           =   2
   IMAINDEX_IMAT_CYCLE          =   2
   // IMA Order
   IMAORDER_BIU_CYCLE           =   3
   IMAORDER_M_CYCLE             =   3
   IMAORDER_SHU_CYCLE           =   2
   IMAORDER_IMA_CYCLE           =   2
   IMAORDER_IMAT_CYCLE          =   1
   // IMA DivStart
   IMADIVSTART_CYCLE            =   2
   // IMA DivCont
   IMADIVCONT_CYCLE             =   1
   // IMA ReadQ
   IMAREADQ_BIU_CYCLE           =   3
   IMAREADQ_M_CYCLE             =   3
   IMAREADQ_SHU_CYCLE           =   2
   IMAREADQ_IMA_CYCLE           =   2
   IMAREADQ_IMAT_CYCLE          =   2
   // IMA ReadR
   IMAREADR_BIU_CYCLE           =   3
   IMAREADR_M_CYCLE             =   3
   IMAREADR_SHU_CYCLE           =   2
   IMAREADR_IMA_CYCLE           =   2
   IMAREADR_IMAT_CYCLE          =   2
   // IMA Count
   IMACOUNT_BIU_CYCLE           =   3
   IMACOUNT_M_CYCLE             =   3
   IMACOUNT_SHU_CYCLE           =   2
   IMACOUNT_IMA_CYCLE           =   2
   IMACOUNT_IMAT_CYCLE          =   2
   // IMA First
   IMAFIRST_BIU_CYCLE           =   3
   IMAFIRST_M_CYCLE             =   3
   IMAFIRST_SHU_CYCLE           =   2
   IMAFIRST_IMA_CYCLE           =   2
   IMAFIRST_IMAT_CYCLE          =   2
   // IMA BR
   IMABR_BIU_CYCLE              =   3
   IMABR_M_CYCLE                =   3
   IMABR_SHU_CYCLE              =   2
   IMABR_IMA_CYCLE              =   2
   IMABR_IMAT_CYCLE             =   2
   // IMA Shift: Lsh, Rsh, shift   
   IMASHIFT_BIU_CYCLE           =   3
   IMASHIFT_M_CYCLE             =   3
   IMASHIFT_SHU_CYCLE           =   2
   IMASHIFT_IMA_CYCLE           =   2
   IMASHIFT_IMAT_CYCLE          =   2
   // IMA BitFilter
   IMABFILTER_BIU_CYCLE         =   3
   IMABFILTER_M_CYCLE           =   3
   IMABFILTER_SHU_CYCLE         =   2
   IMABFILTER_IMA_CYCLE         =   2
   IMABFILTER_IMAT_CYCLE        =   2
   // IMA BitExpd
   IMABEXPD_BIU_CYCLE           =   3
   IMABEXPD_M_CYCLE             =   3
   IMABEXPD_SHU_CYCLE           =   2
   IMABEXPD_IMA_CYCLE           =   2
   IMABEXPD_IMAT_CYCLE          =   2
   // IMA GetSigned
   IMAGETSIGN_BIU_CYCLE         =   3
   IMAGETSIGN_M_CYCLE           =   3
   IMAGETSIGN_SHU_CYCLE         =   2
   IMAGETSIGN_IMA_CYCLE         =   2
   IMAGETSIGN_IMAT_CYCLE        =   2
   // IMA Set Condition
   IMA_SETCOND_CYCLE            =   1
   // IMA SetCG
   IMA_SETCG_CYCLE              =   1


   ////////////////////// PROG-CONTRL //////////////////////
   // MFetch Add
   MFETCHADD_CYCLE              =   1
   // MFetch Sub
   MFETCHSUB_CYCLE              =   1
   // MFetch Compare
   MFETCHCOMP_CYCLE             =   1
   // MFetch Shift
   MFETCHSHIFT_CYCLE            =   1
   // Mfetch logical operation
   MFETCHLOGIC_CYCLE            =   1
   // MFetch Move
   MFETCHMOV_CYCLE              =   1
   // MFetch LpTo
   MFETCHLPTO_CYCLE             =   1
   // MFetch Channel Read
   MFETCHCHR_CYCLE              =   1
   // MFetch Channel Write
   MFETCHCHW_CYCLE              =   1
   // MFetch Conditional Jump
   MFETCHCONJMP_CYCLE           =   1
   // MFetch Definitely Jump
   MFETCHJMP_CYCLE              =   1
   // MFetch KI Read TO M
   MFETCHKI_M_CYCLE             =   5
   // MFetch MPU Stop
   MFETCHMPUSTP_CYCLE           =   1

   // Description: Definitions of instruction cycle to SPU 

   /////////////////////////// SCU ///////////////////////////
   // SCU fix Add
   SCUFIXADD_CYCLE              =   2
   // SCU fix Sub                              
   SCUFIXSUB_CYCLE              =   2
   // SCU fix Mul                              
   SCUFIXMUL_CYCLE              =   3
   // SCU float Sub                            
   SCUFLOATSUB_CYCLE            =   3
   // SCU float Add                                    
   SCUFLOATADD_CYCLE            =   3
   // SCU float Mul                                    
   SCUFLOATMUL_CYCLE            =   3
   // SCU DivStart                                     
   SCUDIVSTART_CYCLE            =   1
   // SCU DivCont                              
   SCUDIVCONT_CYCLE             =   32
   // SCU ReadQ                                
   SCUREADQ_CYCLE               =   2
   // SCU ReadR                                
   SCUREADR_CYCLE               =   2
   // SCU Int2Single Single2Int              
   SCUINTSINGLE_CYCLE           =   3
   // SCU Single2Double Double2Single   
   SCUSINGLEDOUBLE_CYCLE        =   2
   // SCU fixed absolute                      
   SCUFIXABS_CYCLE              =   2
   // SCU float absolute                      
   SCUFLOATABS_CYCLE            =   2
   // SCU write FLAG                  
   SCUWFLAG_CYCLE               =   1
   // SCU read write FLAG                  
   SCURFLAG_CYCLE               =   2
   // SCU logic                               
   SCULOGIC_CYCLE               =   2
   // SCU compare                             
   SCUCOMPARE_CYCLE             =   2
   // SCU shift                               
   SCUSHIFT_CYCLE               =   2
   // SCU Imm valuation                       
   SCUIMM_CYCLE                 =   2
   // SCU data process                        
   SCUBITFILTER_CYCLE           =   3
   SCUBITEXPD_CYCLE             =   4
   SCUMERGSHI_CYCLE             =   2
   SCUCOUNT_CYCLE               =   3
   SCUFIRST_CYCLE               =   2
   SCUBR_CYCLE                  =   2
   SCUGETSIGN_CYCLE             =   2
   SCUSEL_CYCLE                 =   2

   ///////////////////////////// AGU ///////////////////////////
   // AGU R Addr add sub
   AGURADDSUB_CYCLE             =   2
   // AGU SVR Addr add sub
   AGUSVRADDSUB_CYCLE           =   2
   // AGU Imm Addr add sub
   AGUIMMADDSUB_CYCLE           =   2
   // AGU LoadR, SVR load, LoadV
   AGULOAD_CYCLE                =   10
   // AGU StoreR, SVR store, StoreV
   AGUSTORE_CYCLE               =   5
   // AGUMerge: Merge, MergeR
   AGUMERGE_CYCLE               =   2

  //////////////////////////// SEQ //////////////////////
   // SEQ Jump: relative jump, absolute jump
   SEQJUMP_CYCLE                =   2 
   //SEQ Jump:check pc value
   SEQJUMP_DELAY                =   5
   SEQJUMPNOT_DELAY             =  1
   // SEQ Call: relative call, absolute call
   SEQCALL_CYCLE                =   2
   // SEQ SPU stop
   SEQSPUSTOP_CYCLE             =   1
   // SEQ Debug Break
   SEQDBGBRK_CYCLE              =   1
   // SEQ interrupt enable
   SEQINTEN_CYCLE               =   1
   // SEQ Readcond
   SEQREADCOND_CYCLE            =   1
   // SEQ interrupt address configure
   SEQINTADDR_CYCLE             =   1
   // SEQ Setcond: SetcondReg, SetcondImm
   SEQSETCOND_CYCLE             =   1
   // SEQ load
   SEQLOADR_CYCLE               =   9
   SEQLOADIM_CYCLE              =   7
   SEQLOADDM_CYCLE              =   10
   // SEQ store
   SEQSTORE_CYCLE               =   6
   // SEQ distribution: Seqword, Seqshort, Seqbyte
   SEQDISDATA_CYCLE             =   2
   // SEQ SVR-R transmission
   SEQSVRR_CYCLE                =   2

////////////////////////////  SYN ////////////////////////
   // SYN CallM: CallMImm16, CallM Rs
   SYNCALLM_CYCLE               =   3 
   // SYN State R transmission
   SYNSTATR_CYCLE               =   3
   // SYN FIFO read 
   SYNFIFORD_CYCLE              =   4
   // SYN FIFO write
   SYNFIFOWR_CYCLE              =   2
   // SYN transmission between SVR and MReg
   SYNSVRM_CYCLE                =   5
   // SYN read and write MC
   SYNMC_CYCLE                  =   5
   // SYN transmission of BIU configuration parameter
   SYNBIUCONFIG_CYCLE           =   5
   // SYN KI transmission
   SYNKI_CYCLE                  =   4
   // SYN set MPU interrupt address
   SYNSETINTADDR_CYCLE          =   5
   // SYN MPU interrupt enable
   SYNMPUINTEN                  =   3
   // SYN end MPU
   SYNENDMPU_CYCLE              =   2
   // SYN read MPU interrupt address
   SYNREADINTADDR_CYCLE         =   3
   // SYN add
   SYNADD_CYCLE                 =   2
   // SYN sub
   SYNSUB_CYCLE                 =   2
   // SYN multiplication
   SYNMUL_CYCLE                 =   3
   // SYN division start
   SYNDIVSTART_CYCLE            =   1
   // SYN division cycle
   SYNDIVCONT_CYCLE             =   32
   // SYN division quotient read
   SYNREADQ_CYCLE               =   2
   // SYN division remainder read
   SYNREADR_CYCLE               =   2
   // SYN compare
   SYNCOMP_CYCLE                =   2
   // SYN read FLAG
   SYNRFLAG_CYCLE               =   2
   // SYN write FLAG
   SYNWFLAG_CYCLE               =   1
   // SYN logical operation
   SYNLOGIC_CYCLE               =   2
   // SYN shift
   SYNSHIFT_CYCLE               =   2
   // SYN Imm valuation
   SYNIMM_CYCLE                 =   2
   // SYN select
   SYNSEL_CYCLE                 =   2
