#ifndef find_double_c
#define find_double_c

#include <stdio.h>
#include <string.h>
#include <iostream>
#include <assert.h>
#include "matrix.h"
#include "float.h"
#include "stdlib.h"
#include "limits.h"
#include "math.h"
#include "auxfun.h"
int find_double_preallocated(int *indices,const int framenumber,const double *inarray, const mwSize num_inarray, const int allocatedMemory)
{
//     int *indices;
// local variable intialisations 
    mwSize i,k,num_indices;
    
    i =0;
    for (k=0;k< num_inarray  ;k++) 
    {
        if(inarray[k] == framenumber) 
        {
            i++;
        }
        
    }
    num_indices = i;
// // // // //     indices = new int[num_indices +1]; // additional memory to store the number
//     if(allocatedMemory >= num_indices)
//     {
    assert(allocatedMemory >=num_indices);
    i=0;
    for (k=0;k<= num_inarray  ;k++) 
    {
        if(inarray[k] == framenumber) 
        {
             indices[i] = k+1;
             i++;
        }   
    }
//     }
//     else
//     {
//         // throw something???
//     }
//     indices[0] = num_indices;
    return num_indices;
}

#endif


