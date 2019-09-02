/*
 * ===================================================================
 *
 *        Filename:  InstrCycleDef.v
 *
 *         Created:  2019-01-22 
 *   Last Modified:  2019-06-13 01:57:09 PM
 *          Author:  Weilu CHEN , weilu.chen@ia.ac.cn
 *    Organization:  National ASIC Design Engineering Center, IACAS
 *
 *     Description:  SystemVerilog Code
 *
 *
 * ===================================================================
 */


   `ifndef  CYCLE_DEFINE_H
   `define  CYCLE_DEFINE_H


   /////////////////////////// MReg ///////////////////////////
   // DP1
   `define  MRINDEX_AHEAD_CYCLE           2
   // 2 clock cycles in advance of EXE done
   `define  MWINDEX_AHEAD_CYCLE           2

   /////////////////////////// MReg ///////////////////////////
   // read MReg 
   `define   MR_IMA_CYCLE                 2
   `define   MR_SHU_CYCLE                 2
   `define   MR_BIU_CYCLE                 2
   // write config_MFetch       
   `define   MW_CONFIGMFETCH_CYCLE        2
   // write ConfigMRegLatch
   `define   MW_CONFIGMREGLATCH_CYCLE     2
   // write config_M_read       
   `define   MW_CONFIGMR_CYCLE            2
   // write config_M_write      
   `define   MW_CONFIGMW_CYCLE            2
   // read config_M_read        
   `define   MR_CONFIGMR_CYCLE            1
   // read config_M_write       
   `define   MR_CONFIGMW_CYCLE            1
   // release correspondence between read port and latch
   `define   M_CLRRLATCH_CYCLE            2
   // M set condition
   `define   M_SETCOND_CYCLE              1
   // R0.M SetCG
   `define   M_SETCG_CYCLE                1
   
  
   ////////////////////////// SHU //////////////////////////
   // shuffle instruction 0,1
   `define   SHUIND_BIU_CYCLE             2
   `define   SHUIND_M_CYCLE               3  
   `define   SHUIND_IMA_CYCLE             2
   `define   SHUIND_SHU_CYCLE             2
   `define   SHUIND_T7_CYCLE              1
   // add instruction 0,1
   `define   SHUADD_BIU_CYCLE             2
   `define   SHUADD_M_CYCLE               3  
   `define   SHUADD_IMA_CYCLE             2
   `define   SHUADD_SHU_CYCLE             1
   // shift
   `define   SHUSHIFT_BIU_CYCLE           2
   `define   SHUSHIFT_M_CYCLE             3  
   `define   SHUSHIFT_IMA_CYCLE           2
   `define   SHUSHIFT_SHU_CYCLE           1
   // logical operation
   `define   SHULOGIC_BIU_CYCLE           2
   `define   SHULOGIC_M_CYCLE             3
   `define   SHULOGIC_IMA_CYCLE           2
   `define   SHULOGIC_SHU_CYCLE           1
   // convert to bit
   `define   SHUBIT_BIU_CYCLE             2
   `define   SHUBIT_M_CYCLE               3
   `define   SHUBIT_IMA_CYCLE             2
   `define   SHUBIT_SHU_CYCLE             1
   // convert to byte
   `define   SHUBYTE_BIU_CYCLE            2
   `define   SHUBYTE_M_CYCLE              3
   `define   SHUBYTE_IMA_CYCLE            2
   `define   SHUBYTE_SHU_CYCLE            1
   // spacer step
   `define   SHUSTEP_BIU_CYCLE            2
   `define   SHUSTEP_M_CYCLE              3
   `define   SHUSTEP_IMA_CYCLE            2
   `define   SHUSTEP_SHU_CYCLE            1
   // anti-pacer step
   `define   SHUNOSTEP_BIU_CYCLE          2
   `define   SHUNOSTEP_M_CYCLE            3
   `define   SHUNOSTEP_IMA_CYCLE          2
   `define   SHUNOSTEP_SHU_CYCLE          1
   // SHU set condition
   `define   SHU_SETCOND_CYCLE            1
   // SHU SetCG
   `define  SHU_SETCG_CYCLE               1
   // Turbo
   `define   SHUTURBO_BIU_CYCLE           2
   `define   SHUTURBO_M_CYCLE             3  
   `define   SHUTURBO_IMA_CYCLE           2
   `define   SHUTURBO_SHU_CYCLE           1

   ////////////////////////// BIU //////////////////////////
   // BIU Load
   `define   BIULD_BIU_CYCLE              8
   `define   BIULD_M_CYCLE                9
   `define   BIULD_MC_CYCLE               8
   `define   BIULD_IMA_CYCLE              9
   `define   BIULD_SHU_CYCLE              8
   // BIU Store
   `define   BIUST_CYCLE                  4
   // BIU Move(BIUKG)
   `define   BIUKG_CYCLE                  3
   // BIU Move(BIUKG)
   `define   BIUKG_MC_CYCLE               2
   // BIU Add
   `define   BIUADD_CYCLE                 2
   // BIU Sub
   `define   BIUSUB_CYCLE                 2
   // BIU AddWR
   `define   BIUADDWR_CYCLE               2
   // BIU SubWR
   `define   BIUSUBWR_CYCLE               2
   // BIU logical operation: AND, OR, XOR, INV, COMPARE
   `define   BIULOGIC_CYCLE               2
   // BIU Mask generate
   `define   BIUMASKGEN_CYCLE             2
   // BIU Shift: BIULShiftImm, BIULShift, BIURShift
   `define   BIUSHIFT_CYCLE               2
   // BIU Imm
   `define   BIUIMM_CYCLE                 2
   // BIU Mov
   `define   BIUMOV_CYCLE                 2
   // BIU Movall
   `define   BIUMOVALL_CYCLE              1
   // BIUBitInvert
   `define   BIUINV_CYCLE                 2
   // BIU Set Condition
   `define   BIU_SETCOND_CYCLE            1
   // BIU SetCG
   `define   BIU_SETCG_CYCLE              1


   ////////////////////////// IMA //////////////////////////
   // flag update because of calculating
   `define   IMAALUFLAG_CYCLE             1
   `define   IMAMACFLAG_CYCLE             3
   // IMA Mul: mul, mul add, add
   `define   IMAMUL_BIU_CYCLE             5
   `define   IMAMUL_M_CYCLE               5
   `define   IMAMUL_SHU_CYCLE             4
   `define   IMAMUL_IMA_CYCLE             4   // does not include itself
   `define   IMAMUL_IMAT_CYCLE            4   // itself
   `define   IMAMUL_IMAMR_CYCLE           3   
   // IMA SetMR
   `define   IMASETMR_CYCLE               2
   // IMA ReadMR
   `define   IMARMR_BIU_CYCLE             5
   `define   IMARMR_M_CYCLE               5
   `define   IMARMR_SHU_CYCLE             4
   `define   IMARMR_IMA_CYCLE             4
   `define   IMARMR_IMAT_CYCLE            4
   // IMA SetShiftMode
   `define   IMASETSHMODE_CYCLE           2
   // IMA Read FLAG
   `define   IMARFLAG_BIU_CYCLE           5
   `define   IMARFLAG_M_CYCLE             5
   `define   IMARFLAG_SHU_CYCLE           4
   `define   IMARFLAG_IMA_CYCLE           4
   `define   IMARFLAG_IMAT_CYCLE          4
   `define   IMARFLAG_MFETCH_CYCLE        4
   // IMA Write FLAG
   `define   IMAWFLAG_CYCLE               2
   // IMA SetCmpMR
   `define   IMASETCMPMR_CYCLE            3
   // IMA CmpMR
   `define   IMACMPMR_M_CYCLE             5
   `define   IMACMPMR_IMA_CYCLE           4
   `define   IMACMPMR_IMAT_CYCLE          4
   `define   IMACMPMR_IMAMR_CYCLE         3
   // IMA RMax
   `define   IMARMAX_BIU_CYCLE            5
   `define   IMARMAX_M_CYCLE              5
   `define   IMARMAX_SHU_CYCLE            4
   `define   IMARMAX_IMA_CYCLE            4   
   `define   IMARMAX_IMAT_CYCLE           4   
   `define   IMARMAX_IMAMR_CYCLE          3   
   // IMA RMin
   `define   IMARMIN_BIU_CYCLE            5
   `define   IMARMIN_M_CYCLE              5
   `define   IMARMIN_SHU_CYCLE            4
   `define   IMARMIN_IMA_CYCLE            4   
   `define   IMARMIN_IMAT_CYCLE           4   
   `define   IMARMIN_IMAMR_CYCLE          3   
   // IMA Turbo
   `define   IMATURBO_BIU_CYCLE           5
   `define   IMATURBO_M_CYCLE             5
   `define   IMATURBO_SHU_CYCLE           4
   `define   IMATURBO_IMA_CYCLE           4
   `define   IMATURBO_IMAT_CYCLE          4
   // IMA SetTurboAB
   `define   IMASETTURBOAB_CYCLE          2
   // IMA Add, RAdd, ModAdd
   `define   IMAADD_BIU_CYCLE             3
   `define   IMAADD_M_CYCLE               3
   `define   IMAADD_SHU_CYCLE             2
   `define   IMAADD_IMA_CYCLE             2   
   `define   IMAADD_IMAT_CYCLE            2   
   // IMA Sub
   `define   IMASUB_BIU_CYCLE             3
   `define   IMASUB_M_CYCLE               3
   `define   IMASUB_SHU_CYCLE             2
   `define   IMASUB_IMA_CYCLE             2   
   `define   IMASUB_IMAT_CYCLE            1   
   // IMA Mov
   `define   IMAMOV_BIU_CYCLE             3
   `define   IMAMOV_M_CYCLE               3
   `define   IMAMOV_SHU_CYCLE             2
   `define   IMAMOV_IMA_CYCLE             2   
   `define   IMAMOV_IMAT_CYCLE            2   
   // IMA Conj
   `define   IMACONJ_BIU_CYCLE            3
   `define   IMACONJ_M_CYCLE              3
   `define   IMACONJ_SHU_CYCLE            2
   `define   IMACONJ_IMA_CYCLE            2   
   `define   IMACONJ_IMAT_CYCLE           2   
   // IMA ABS
   `define   IMAABS_BIU_CYCLE             3
   `define   IMAABS_M_CYCLE               3
   `define   IMAABS_SHU_CYCLE             2
   `define   IMAABS_IMA_CYCLE             2   
   `define   IMAABS_IMAT_CYCLE            2   
   // IMA Bor
   `define   IMABOR_BIU_CYCLE             3
   `define   IMABOR_M_CYCLE               3
   `define   IMABOR_SHU_CYCLE             2
   `define   IMABOR_IMA_CYCLE             2   
   `define   IMABOR_IMAT_CYCLE            2   
   // IMA Logic
   `define   IMALOGIC_BIU_CYCLE           3
   `define   IMALOGIC_M_CYCLE             3
   `define   IMALOGIC_SHU_CYCLE           2
   `define   IMALOGIC_IMA_CYCLE           2
   `define   IMALOGIC_IMAT_CYCLE          2
   // IMA CompSel
   `define   IMACOMPSEL_BIU_CYCLE         3
   `define   IMACOMPSEL_M_CYCLE           3
   `define   IMACOMPSEL_SHU_CYCLE         2
   `define   IMACOMPSEL_IMA_CYCLE         2   
   `define   IMACOMPSEL_IMAT_CYCLE        2 
   // IMA CompSelgd
   `define   IMACOMPSELGS_BIU_CYCLE       5
   `define   IMACOMPSELGS_M_CYCLE         5
   `define   IMACOMPSELGS_SHU_CYCLE       4
   `define   IMACOMPSELGS_IMA_CYCLE       4   
   `define   IMACOMPSELGS_IMAT_CYCLE      3
   // IMA Triple
   `define   IMATRIPLE_BIU_CYCLE          3
   `define   IMATRIPLE_M_CYCLE            3
   `define   IMATRIPLE_SHU_CYCLE          2
   `define   IMATRIPLE_IMA_CYCLE          2
   `define   IMATRIPLE_IMAT_CYCLE         2
   // IMA Cprs
   `define   IMACPRS_BIU_CYCLE            3
   `define   IMACPRS_M_CYCLE              3
   `define   IMACPRS_SHU_CYCLE            2
   `define   IMACPRS_IMA_CYCLE            2
   `define   IMACPRS_IMAT_CYCLE           2
   // IMA Expd
   `define   IMAEXPD_BIU_CYCLE            3
   `define   IMAEXPD_M_CYCLE              3
   `define   IMAEXPD_SHU_CYCLE            2
   `define   IMAEXPD_IMA_CYCLE            2
   `define   IMAEXPD_IMAT_CYCLE           2
   // IMA Index
   `define   IMAINDEX_BIU_CYCLE           3
   `define   IMAINDEX_M_CYCLE             3
   `define   IMAINDEX_SHU_CYCLE           2
   `define   IMAINDEX_IMA_CYCLE           2
   `define   IMAINDEX_IMAT_CYCLE          2
   // IMA Order
   `define   IMAORDER_BIU_CYCLE           3
   `define   IMAORDER_M_CYCLE             3
   `define   IMAORDER_SHU_CYCLE           2
   `define   IMAORDER_IMA_CYCLE           2
   `define   IMAORDER_IMAT_CYCLE          1
   // IMA DivStart
   `define   IMADIVSTART_CYCLE            2
   // IMA DivCont
   `define   IMADIVCONT_CYCLE             1
   // IMA ReadQ
   `define   IMAREADQ_BIU_CYCLE           3
   `define   IMAREADQ_M_CYCLE             3
   `define   IMAREADQ_SHU_CYCLE           2
   `define   IMAREADQ_IMA_CYCLE           2
   `define   IMAREADQ_IMAT_CYCLE          2
   // IMA ReadR
   `define   IMAREADR_BIU_CYCLE           3
   `define   IMAREADR_M_CYCLE             3
   `define   IMAREADR_SHU_CYCLE           2
   `define   IMAREADR_IMA_CYCLE           2
   `define   IMAREADR_IMAT_CYCLE          2
   // IMA Count
   `define   IMACOUNT_BIU_CYCLE           3
   `define   IMACOUNT_M_CYCLE             3
   `define   IMACOUNT_SHU_CYCLE           2
   `define   IMACOUNT_IMA_CYCLE           2
   `define   IMACOUNT_IMAT_CYCLE          2
   // IMA First
   `define   IMAFIRST_BIU_CYCLE           3
   `define   IMAFIRST_M_CYCLE             3
   `define   IMAFIRST_SHU_CYCLE           2
   `define   IMAFIRST_IMA_CYCLE           2
   `define   IMAFIRST_IMAT_CYCLE          2
   // IMA BR
   `define   IMABR_BIU_CYCLE              3
   `define   IMABR_M_CYCLE                3
   `define   IMABR_SHU_CYCLE              2
   `define   IMABR_IMA_CYCLE              2
   `define   IMABR_IMAT_CYCLE             2
   // IMA Shift: Lsh, Rsh, shift
   `define   IMASHIFT_BIU_CYCLE           3
   `define   IMASHIFT_M_CYCLE             3
   `define   IMASHIFT_SHU_CYCLE           2
   `define   IMASHIFT_IMAT_CYCLE          2
   // IMA BitFilter
   `define   IMABFILTER_BIU_CYCLE         3
   `define   IMABFILTER_M_CYCLE           3
   `define   IMABFILTER_SHU_CYCLE         2
   `define   IMABFILTER_IMA_CYCLE         2
   `define   IMABFILTER_IMAT_CYCLE        2
   // IMA BitExpd
   `define   IMABEXPD_BIU_CYCLE           3
   `define   IMABEXPD_M_CYCLE             3
   `define   IMABEXPD_SHU_CYCLE           2
   `define   IMABEXPD_IMA_CYCLE           2
   `define   IMABEXPD_IMAT_CYCLE          2
   // IMA GetSigned
   `define   IMAGETSIGN_BIU_CYCLE         3
   `define   IMAGETSIGN_M_CYCLE           3
   `define   IMAGETSIGN_SHU_CYCLE         2
   `define   IMAGETSIGN_IMA_CYCLE         2
   `define   IMAGETSIGN_IMAT_CYCLE        2
   // IMA Set Condition
   `define   IMA_SETCOND_CYCLE            1
   // IMA SetCG
   `define  IMA_SETCG_CYCLE               1


   ////////////////////// PROG-CONTRL //////////////////////
   // MFetch Add
   `define   MFETCHADD_CYCLE              1
   // MFetch Sub
   `define   MFETCHSUB_CYCLE              1
   // MFetch Compare
   `define   MFETCHCOMP_CYCLE             1
   // MFetch Shift
   `define   MFETCHSHIFT_CYCLE            1
   // Mfetch logical operation
   `define   MFETCHLOGIC_CYCLE            1
   // MFetch Move
   `define   MFETCHMOV_CYCLE              1
   // MFetch LpTo
   `define   MFETCHLPTO_CYCLE             1
   // MFetch Channel Read
   `define   MFETCHCHR_CYCLE              1
   // MFetch Channel Write
   `define   MFETCHCHW_CYCLE              1
   // MFetch Conditional Jump
   `define   MFETCHCONJMP_CYCLE           1
   // MFetch Definitely Jump
   `define   MFETCHJMP_CYCLE              1
   // MFetch KI Read TO M
   `define   MFETCHKI_M_CYCLE             5
   // MFetch MPU Stop
   `define   MFETCHMPUSTP_CYCLE           1

   // Description: Definitions of instruction cycle to SPU 

   /////////////////////////// SCU ///////////////////////////
   // SCU fix Add
   `define   SCUFIXADD_CYCLE              2
   // SCU fix Sub                           
   `define   SCUFIXSUB_CYCLE              2
   // SCU fix Mul                           
   `define   SCUFIXMUL_CYCLE              3
   // SCU float Sub                         
   `define  SCUFLOATSUB_CYCLE             3
   // SCU float Add                         
   `define  SCUFLOATADD_CYCLE             3
   // SCU float Mul                         
   `define   SCUFLOATMUL_CYCLE            3
   // SCU DivStart                          
   `define  SCUDIVSTART_CYCLE             1
   // SCU DivCont                           
   `define   SCUDIVCONT_CYCLE             32
   // SCU ReadQ                             
   `define   SCUREADQ_CYCLE               2
   // SCU ReadR                             
   `define   SCUREADR_CYCLE               2
   // SCU Int2Single Single2Int           
   `define   SCUINTSINGLE_CYCLE           3
   // SCU Single2Double Double2Single   
   `define   SCUSINGLEDOUBLE_CYCLE        2
   // SCU fixed absolute                   
   `define   SCUFIXABS_CYCLE              2
   // SCU float absolute                   
   `define   SCUFLOATABS_CYCLE            2
   // SCU write FLAG               
   `define   SCUWFLAG_CYCLE               1
   // SCU read write FLAG               
   `define   SCURFLAG_CYCLE               2
   // SCU logic                            
   `define   SCULOGIC_CYCLE               2
   // SCU compare                          
   `define   SCUCOMPARE_CYCLE             2
   // SCU shift                            
   `define   SCUSHIFT_CYCLE               2
   // SCU Imm valuation                    
   `define   SCUIMM_CYCLE                 2
   // SCU data process                     
   `define   SCUBITFILTER_CYCLE           3
   `define   SCUBITEXPD_CYCLE             4
   `define   SCUMERGSHI_CYCLE             2
   `define   SCUCOUNT_CYCLE               3
   `define   SCUFIRST_CYCLE               2
   `define   SCUBR_CYCLE                  2
   `define   SCUGETSIGN_CYCLE             2
   `define   SCUSEL_CYCLE                 2

   ///////////////////////////// AGU ///////////////////////////
   // AGU R Addr add sub
   `define   AGURADDSUB_CYCLE             2
   // AGU SVR Addr add sub
   `define   AGUSVRADDSUB_CYCLE           2
   // AGU Imm Addr add sub
   `define   AGUIMMADDSUB_CYCLE           2
   // AGU LoadR, SVR load, LoadV
   `define   AGULOAD_CYCLE                10
   // AGU StoreR, SVR store, StoreV
   `define   AGUSTORE_CYCLE               5
   // AGUMerge: Merge, MergeR
   `define   AGUMERGE_CYCLE               2

  //////////////////////////// SEQ //////////////////////
   // SEQ Jump: relative jump, absolute jump
   `define   SEQJUMP_CYCLE                2 
   //SEQ Jump:check pc value
   `define   SEQJUMP_DELAY                5
   `define   SEQJUMPNOT_DELAY             1
   // SEQ Call: relative call, absolute call
   `define   SEQCALL_CYCLE                2
   // SEQ SPU stop
   `define   SEQSPUSTOP_CYCLE             1
   // SEQ Debug Break
   `define   SEQDBGBRK_CYCLE              1
   // SEQ interrupt enable
   `define   SEQINTEN_CYCLE               1
   // SEQ Readcond
   `define   SEQREADCOND_CYCLE            1
   // SEQ interrupt address configure
   `define   SEQINTADDR_CYCLE             1
   // SEQ Setcond: SetcondReg, SetcondImm
   `define   SEQSETCOND_CYCLE             1
   // SEQ load
   `define   SEQLOADR_CYCLE               9
   `define   SEQLOADIM_CYCLE              7
   `define   SEQLOADDM_CYCLE              10
   // SEQ store
   `define   SEQSTORE_CYCLE               6
   // SEQ distribution: Seqword, Seqshort, Seqbyte
   `define   SEQDISDATA_CYCLE             2
   // SEQ SVR-R transmission
   `define   SEQSVRR_CYCLE                2

////////////////////////////  SYN ////////////////////////
   // SYN CallM: CallMImm16, CallM Rs
   `define   SYNCALLM_CYCLE               3 
   // SYN State R transmission
   `define   SYNSTATR_CYCLE               3
   // SYN FIFO read 
   `define   SYNFIFORD_CYCLE              4
   // SYN FIFO write
   `define   SYNFIFOWR_CYCLE              2
   // SYN transmission between SVR and MReg
   `define   SYNSVRM_CYCLE                5
   // SYN read and write MC
   `define   SYNMC_CYCLE                  5
   // SYN transmission of BIU configuration parameter
   `define   SYNBIUCONFIG_CYCLE           5
   // SYN KI transmission
   `define   SYNKI_CYCLE                  4
   // SYN set MPU interrupt address
   `define   SYNSETINTADDR_CYCLE          5
   // SYN MPU interrupt enable
   `define   SYNMPUINTEN                  3
   // SYN end MPU
   `define   SYNENDMPU_CYCLE              2
   // SYN read MPU interrupt address
   `define   SYNREADINTADDR_CYCLE         3
   // SYN add
   `define   SYNADD_CYCLE                 2
   // SYN sub
   `define   SYNSUB_CYCLE                 2
   // SYN multiplication
   `define   SYNMUL_CYCLE                 3
   // SYN division start
   `define   SYNDIVSTART_CYCLE            1
   // SYN division cycle
   `define   SYNDIVCONT_CYCLE             32
   // SYN division quotient read
   `define   SYNREADQ_CYCLE               2
   // SYN division remainder read
   `define   SYNREADR_CYCLE               2
   // SYN compare
   `define   SYNCOMP_CYCLE                2
   // SYN read FLAG
   `define   SYNRFLAG_CYCLE               2
   // SYN write FLAG
   `define   SYNWFLAG_CYCLE               1
   // SYN logical operation
   `define   SYNLOGIC_CYCLE               2
   // SYN shift
   `define   SYNSHIFT_CYCLE               2
   // SYN Imm valuation
   `define   SYNIMM_CYCLE                 2
   // SYN select
   `define   SYNSEL_CYCLE                 2

   `endif
