`ifndef DPI_H

`define DPI_H


import "DPI-C" function shortreal SingleAdd(input shortreal a,input shortreal b,input bit t);
import "DPI-C" function shortreal SingleSub(input shortreal a,input shortreal b,input bit t);
import "DPI-C" function shortreal SingleMul(input shortreal a,input shortreal b,input bit t);
import "DPI-C" function shortreal SingleRcpqrt(input shortreal a);//倒数平方根
import "DPI-C" function int       Single2Int(input shortreal a,input bit t );
import "DPI-C" function int       Single2Unsign(input shortreal a,input bit t);
import "DPI-C" function real      Single2Double(input shortreal a);


import "DPI-C" function real      DoubleAdd(input real a,input real b,input bit t);
import "DPI-C" function real      DoubleSub(input real a,input real b,input bit t);
import "DPI-C" function real      DoubleMul(input real a,input real b,input bit t);
import "DPI-C" function real      DoubleRcpqrt(input real a);//倒数平方根
import "DPI-C" function int       Double2Int(input real a,input bit t );
import "DPI-C" function int       Double2Unsign(input real a,input bit t);
import "DPI-C" function shortreal Double2Single(input real a,input bit t);

import "DPI-C" function shortreal Int2Single(input int a,input bit t);
import "DPI-C" function real      Int22Double(input int a,input bit t);

import "DPI-C" function shortreal Unsign2Single(input int a,input bit t);
import "DPI-C" function real      Unsign2Double(input int a,input bit t);



import "DPI-C" function shortreal SMul(input shortreal a,input shortreal b,input bit T);
import "DPI-C" function shortreal SMac(input shortreal a,input shortreal b,input shortreal c,input bit T);
import "DPI-C" function real DMul(input real a,input real b,input bit T);
import "DPI-C" function real DMac(input real a,input real b,input real c,input bit T);




`endif