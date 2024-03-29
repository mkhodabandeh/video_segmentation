/* Mex impelmentation of STT using map
 * Usage :
 * mex -largeArrayDims STT_cppfriendly.cpp  -I. initarrytozero.cpp initbooltozero.cpp initintarrytozero.cpp Evolveregionsfastwithfilteredflows_cpp.cpp Measuresimilarity_cpp.cpp
 *
 * Command to execute while testing the program as a independant unit:
 * [syo,sxo,svo]=STT_cppfriendly(graphdepth,noFrames,labelledlevelvideo,multcount,maxnumberofsuperpixelsperframe,flows,mapped)
 *
 */

/* INCLUDES: */
#include "mex.h"
#include "matrix.h"
#include "auxfun.h"
#include "limits.h"
#include "math.h"
#include "Evolveregionsfastwithfilteredflows_cpp.h"
#include "Measuresimilarity_cpp.h"

#include "float.h"
#include "stdlib.h"
#include <iostream> //cout
#include "map" //map
#include <utility> //pair
using namespace std;

int linearindex_k( int rowindex, int colindex, int no_rows) // THIS FUNCTION IS USED BY FIRSTMEX
 {
    int linearind;
    linearind =0;
    linearind = ((colindex-1)* no_rows) + (rowindex-1);  
    return linearind;
 }

int linearindex_3d( int rowindex, int colindex, int frame_index, int no_rows, int no_cols)
 {
    int linearind;
    linearind =0;
    linearind = ((frame_index - 1)*(no_rows *no_cols))+((colindex-1)* no_rows) + (rowindex-1);  
    return linearind;
 }

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    /* DECLARATIONS: */
    double  *graphdepth ,*noframes, *labelledlevelvideo,*multcount, *maxsuperpixels, *flows, *mapped;
    double *test;  //output variable

    graphdepth                     = mxGetPr(prhs[0]);
    noframes                       = mxGetPr(prhs[1]);
    labelledlevelvideo             = mxGetPr(prhs[2]);
    multcount                      = mxGetPr(prhs[3]);
    maxsuperpixels                 = mxGetPr(prhs[4]);
    flows                          = mxGetPr(prhs[5]);
    mapped                         = mxGetPr(prhs[6]);
    
    
    
    //     local variables
    int i,frame,maxsuperpixelsperframe,firstframe,frameup;
    int nolabelsone,dimrow_labvideo,dimcol_labvideo,dimframe_labvideo;
    int start_index,globlabel,globil,lin_ind;
    int label,min,atdepth,aux1;
    int *labelsonone, *labelsontwo; 
    double importanceforprobability,similarity,*predicted_mask,*interestedlabels;
    bool *bool_masksonframe,*themask,*bool_interestedlabels,*bool_maskontwo;
    int num_lab,ii,il,intlab,label_max,max_var;  // max_var keeps track of the max label for every iteration so that there is no need to run through the entire bool array
    
   // pointers to extract a flow from the structure
    mxArray *tmp_flows_flows,*tmp_flows_flows_no,*tmp_flows_flows_no_Up,*tmp_flows_flows_no_Vp,*tmp_flows_flows_no_Um,*tmp_flows_flows_no_Vm; 
    int no_frames;
    double  *tmp_flows_flows_no_Up_matrix,*tmp_flows_flows_no_Vp_matrix,*tmp_flows_flows_no_Um_matrix,*tmp_flows_flows_no_Vm_matrix;
    int num_elements,num_fields;
    
    maxsuperpixelsperframe = (int) *maxsuperpixels;
    dimframe_labvideo      = (int) *noframes;
    dimrow_labvideo        = mxGetM(prhs[2]);
    dimcol_labvideo        = mxGetN(prhs[2])/dimframe_labvideo;
    num_elements           = mxGetNumberOfElements(prhs[5]);
    num_fields             = mxGetNumberOfFields(prhs[5]);
    label_max              = (int) maxsuperpixelsperframe;
    
    
    /* -------------------------Memory allocations-----------------------------------*/
    bool_interestedlabels       = new bool[label_max];                 
    bool_maskontwo              = new bool[(dimrow_labvideo*dimcol_labvideo)]; 
    themask                     = new bool[dimrow_labvideo*dimcol_labvideo];
    bool_masksonframe           = new bool[dimrow_labvideo*dimcol_labvideo*maxsuperpixelsperframe];
    labelsonone                 = new int[dimrow_labvideo*dimcol_labvideo]; // chang this too to double?
    labelsontwo                 = new int[dimrow_labvideo*dimcol_labvideo]; 
    predicted_mask              = new double[dimrow_labvideo*dimcol_labvideo];
    interestedlabels            = new double[label_max];
    
//     initbooltozero(themask,(dimrow_labvideo*dimcol_labvideo));
//     initbooltozero(bool_interestedlabels,label_max); 
//     initbooltozero(bool_maskontwo,(dimrow_labvideo*dimcol_labvideo));
    /*____________________________________________________________________________*/
    
//Similarity Matrix
    map < pair <int,int>, double> sttsimilarity ;
    pair<int,int> ins_pos;
    pair<int,int> ins_pos_trans;
     
    for(frame =1; frame < (int) *noframes; frame++)
    {
         //-----------GENERATING LABELSATONE------------
           start_index = linearindex_3d(1,1, frame,dimrow_labvideo,dimcol_labvideo);
           nolabelsone =0;
           for( i =0; i< (dimcol_labvideo*dimrow_labvideo); i++)
           {
               labelsonone[i] = (int) labelledlevelvideo[start_index];
               start_index++;
               if(nolabelsone <labelsonone[i])
               {
                   nolabelsone = labelsonone[i];   
               }
           }
        //--------gen labelsatone complete-----------------

        //-----------GENERATING BOOLEAN "MASKONFRAME"------------    

//            bool_masksonframe = new bool[dimrow_labvideo*dimcol_labvideo*nolabelsone];
//            initbooltozero(bool_masksonframe,(dimrow_labvideo*dimcol_labvideo*nolabelsone));
           for(label=0;label < nolabelsone; label++)
           {
               start_index = linearindex_3d(1,1, (label+1),dimrow_labvideo,dimcol_labvideo);
               for(i=0; i <  (dimcol_labvideo*dimrow_labvideo); i++)
               {
                   if(labelsonone[i] == (label+1))  
                   {
                        bool_masksonframe[start_index+i]= true;
                   }
                   else
                   {
                        bool_masksonframe[start_index+i]= false;
                   }
               }
           }
    //       ______________bool_maskonframe is generated_______________________________________

        /*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            *________CODE TO EXTRACT FLOWS FROM STRUCT "FLOWS"____________________*/
           /* Pointer to the first location of the mxArray */
           tmp_flows_flows = mxGetField(prhs[5], 0, "flows"); //extraction from struct
           no_frames = mxGetNumberOfElements(tmp_flows_flows);
           tmp_flows_flows_no = mxGetCell(tmp_flows_flows,(frame-1) ); //extraction from cell array
           // extraction from struct
           tmp_flows_flows_no_Up=mxGetField(tmp_flows_flows_no,0,"Up"); 
           tmp_flows_flows_no_Vp=mxGetField(tmp_flows_flows_no,0,"Vp"); 
           tmp_flows_flows_no_Um=mxGetField(tmp_flows_flows_no,0,"Um"); 
           tmp_flows_flows_no_Vm=mxGetField(tmp_flows_flows_no,0,"Vm"); 
         // typecasting for use     
           tmp_flows_flows_no_Up_matrix = mxGetPr(tmp_flows_flows_no_Up);
           tmp_flows_flows_no_Vp_matrix = mxGetPr(tmp_flows_flows_no_Vp);
           tmp_flows_flows_no_Um_matrix = mxGetPr(tmp_flows_flows_no_Um);
           tmp_flows_flows_no_Vm_matrix = mxGetPr(tmp_flows_flows_no_Vm);
/*^^^^^^^^^^^^^^^^^^^^^^^^FLOWS ARE EXTRACTED^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
           min = frame+(int) *graphdepth;
           if(min > (int) *noframes)
           {
               min = (int)*noframes;
           }
           importanceforprobability=1.0; 
           firstframe=true;
           for(frameup =(frame+1); frameup <= min; frameup++)
           {
               atdepth = frameup - frame;
//---------------------generate labelsontwo---------------
//                initintarrytozero(labelsontwo,(dimcol_labvideo*dimrow_labvideo)); 
               start_index = linearindex_3d(1,1, frameup,dimrow_labvideo,dimcol_labvideo);  
               for( i =0; i< (dimcol_labvideo*dimrow_labvideo); i++)
               {
                   labelsontwo[i] = labelledlevelvideo[start_index];
                   start_index++;
               }
//--------------------labelsattwo generated---------------------------- 
               if(firstframe)
               {
                   firstframe =false;
               }
               else
               {
                   importanceforprobability=importanceforprobability/ (*multcount);
               } 
               for(label =0;label< nolabelsone;label++)
               {
//                    initbooltozero(themask,(dimrow_labvideo*dimcol_labvideo));
                   aux1 = label+1;
                   start_index = linearindex_3d(1,1,aux1,dimrow_labvideo,dimcol_labvideo);//label+1 because maskonframe has matlab indices
                   for( i =0; i< (dimcol_labvideo*dimrow_labvideo); i++)
                   {
                       themask[i] = bool_masksonframe[start_index];
                       start_index++;
                   } 
                   initarrytozero(predicted_mask,(dimcol_labvideo*dimrow_labvideo));                    
                   Evolveregionsfastwithfilteredflows_cpp(predicted_mask,themask,tmp_flows_flows_no_Up_matrix,tmp_flows_flows_no_Vp_matrix,
                   tmp_flows_flows_no_Um_matrix,tmp_flows_flows_no_Vm_matrix,dimrow_labvideo,dimcol_labvideo);  
                   
                   if((int) *graphdepth >1)
                   {
                      start_index = linearindex_3d(1,1, aux1,dimrow_labvideo,dimcol_labvideo);
                         for(i=0;i<(dimcol_labvideo*dimrow_labvideo);i++)
                         {
                             if(predicted_mask[i] > 0.5)  
                             {
                                  bool_masksonframe[start_index+i]= true; //update masksonframe for next graph depth    
                             }
                             else
                             {
                                 bool_masksonframe[start_index+i] =false;
                             }
                         }
                   } 
                   initbooltozero(bool_interestedlabels,label_max); // test this might be needed
                   max_var=0;
                   
//-----------------------------Generating interested labels-----------------------------
                   num_lab=0; // for counting the number of interested labels
                   for(i=0; i<(dimcol_labvideo*dimrow_labvideo); i++)
                   {
                      if(predicted_mask[i] > 0)
                      {
                          bool_interestedlabels[labelsontwo[i] -1] =true; // labelsontwo in matlab indices, bool_interes... in "c" indices
                          if(max_var < labelsontwo[i])
                          {
                              max_var = labelsontwo[i]; //max_var will limit the range of the iteration below
                          }
                      }
                   } // end of for(i=0; i<dimcol_labvideo*dimrow_labvideo);i++)
// _______________Counting the number of interested labels________________
                   for(i=0; i< max_var; i++)
                     {
                         if( bool_interestedlabels[i] == true)
                         {
                            num_lab++;
                         }
                     }
//                    interestedlabels = new double[num_lab]; //allocated globally
                   
                   ii=0;
                   for(i=0;i < max_var;i++)  // max_var is helping to limit the range of the iteration
                   {
                       if(bool_interestedlabels[i])
                       {
                           interestedlabels[ii] = (i+1); // since labels must be in matlab indices
                           bool_interestedlabels[i] = false;  // this helps in that the bool array need not be init to zero for every iteration
                           ii++;
                       }
                   }
//-----------------------------Generating interested labels completed-----------------------------
                                     
                   for(il=0;il < num_lab; il++)
                   {
                       similarity =0;
                       intlab = interestedlabels[il];
//                        initbooltozero(bool_maskontwo,(dimrow_labvideo*dimcol_labvideo));  // since this is reused within the loop
                       for( i =0; i< (dimcol_labvideo*dimrow_labvideo); i++)
                       {
                           if(labelsontwo[i] == intlab)
                           {
                               bool_maskontwo[i] =true;
                           }
                           else
                           {
                                bool_maskontwo[i] =false;
                           }
                       }
                       similarity  = Measuresimilarity_cpp(bool_maskontwo,predicted_mask,dimrow_labvideo,dimcol_labvideo);
                       lin_ind = linearindex_k(frame,(label+1), (int) *noframes);// label in in c indices
                       globlabel = mapped[lin_ind];
                       lin_ind = linearindex_k(frameup,(intlab), (int) *noframes);// intlab is in matlab indices
                       globil = mapped[lin_ind];
                       pair<int,int> ins_pos(globlabel,globil);  //(vol label,neighlabel)
                       pair<int,int> ins_pos_trans(globil,globlabel);
// //                check to see if already claculated???
                       sttsimilarity[ins_pos]=similarity*importanceforprobability;
                       sttsimilarity[ins_pos_trans]=similarity*importanceforprobability;
                   }
               }//end of for(label =0;label< nolabelsone;label++)
           }//end of for(frameup =(frame+1); frameup <= min; frameup++)
    }// end of for(frame =1; frame < (int) *noframes; frame
    delete [] bool_interestedlabels;            
    delete [] bool_maskontwo; 
    delete [] labelsonone; 
    delete [] labelsontwo;
    delete [] themask;
    delete [] predicted_mask;
    delete [] interestedlabels;
    delete [] bool_masksonframe;
   
    int nnz= (int) sttsimilarity.size();
//     cout<<"Number of nonzero entries "<<nnz<<endl;
    plhs[0] = mxCreateDoubleMatrix(nnz,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nnz,1,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nnz,1,mxREAL);
    double* sxo_cpp = mxGetPr(plhs[0]); //sxo
    double* syo_cpp = mxGetPr(plhs[1]); //syo
    double* svo_cpp = mxGetPr(plhs[2]); //svo
    int ct = 0;
     for(map<pair<int,int>, double>::iterator ii=sttsimilarity.begin();ii!=sttsimilarity.end(); ii++)
    {
      pair<int,int> pos=(*ii).first;
      sxo_cpp[ct]=static_cast<double>(pos.first);
      syo_cpp[ct]=static_cast<double>(pos.second);
      svo_cpp[ct]=(*ii).second;
      ct++;
     }
    sttsimilarity.clear();
}// end of main
           
