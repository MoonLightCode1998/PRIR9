#include <cuda_runtime.h>
#include <iostream> 
using namespace std;
#include <chrono>
#include <sys/time.h>

__global__ void computeMandelbrot1D(double X0, double Y0, double X1, double Y1, int POZ, int PION, int ITER,int *Mandel ){
    int indx = blockIdx.x * blockDim.x + threadIdx.x;
    double Xre,Xim,Yre,Yim,Tre,Tim;
    double dy = (Y1-Y0)/PION;
    double dx=(X1-X0)/POZ;
    int k;
    
    if(indx<PION*POZ){

    
    
        Xre=(indx/POZ)*dx+X0;
            
                k=0;
                Xim=(indx%POZ)*dy+Y0;
                Yre=0;
                Yim=0;
               do{
                   Tre = Yre*Yre-Yim*Yim;
                   Tim = 2*Yre*Yim;
                   Yre=Tre;
                   Yim=Tim;
                   Yre=Yre+Xre;
                   Yim=Yim+Xim;
                   k++;
               }while(k<ITER&&(Yre*Yre+ Yim*Yim)<4);
                Mandel[indx]=k;
            
    }
    
}


void makePicture(int *Mandel,int width, int height, int MAX){
    
    int red_value, green_value, blue_value;
    
    float scale = 256.0/MAX;
    
    int MyPalette[41][3]={
        {255,255,255}, //0
        {255,255,255}, //1 not used
        {255,255,255}, //2 not used
        {255,255,255}, //3 not used
        {255,255,255}, //4 not used
        {255,180,255}, //5
        {255,180,255}, //6 not used
        {255,180,255}, //7 not used
        {248,128,240}, //8
        {248,128,240}, //9 not used
        {240,64,224}, //10
        {240,64,224}, //11 not used
        {232,32,208}, //12
        {224,16,192}, //13
        {216,8,176}, //14
        {208,4,160}, //15
        {200,2,144}, //16
        {192,1,128}, //17
        {184,0,112}, //18
        {176,0,96}, //19
        {168,0,80}, //20
        {160,0,64}, //21
        {152,0,48}, //22
        {144,0,32}, //23
        {136,0,16}, //24
        {128,0,0}, //25
        {120,16,0}, //26
        {112,32,0}, //27
        {104,48,0}, //28
        {96,64,0}, //29
        {88,80,0}, //30
        {80,96,0}, //31
        {72,112,0}, //32
        {64,128,0}, //33
        {56,144,0}, //34
        {48,160,0}, //35
        {40,176,0}, //36
        {32,192,0}, //37
        {16,224,0}, //38
        {8,240,0}, //39
        {0,0,0} //40
    };
    
    FILE *f = fopen("Mandel.ppm", "wb");
    fprintf(f, "P6\n%i %i 255\n", width, height);
    for (int j=height-1; j>=0; j--) {
        for (int i=0; i<width; i++) {
            // compute index to the palette
            int indx= (int) floor(5.0*scale*log2f(1.0f*Mandel[j*height+i]+1));
            red_value=MyPalette[indx][0];
            green_value=MyPalette[indx][2];
            blue_value=MyPalette[indx][1];
            
            fputc(red_value, f);   // 0 .. 255
            fputc(green_value, f); // 0 .. 255
            fputc(blue_value, f);  // 0 .. 255
        }
    }
    fclose(f);
    
}


int main(int argc, char **argv) {
  

    double X0=-0.82;
     double Y0=0.1; 
     double X1=-0.7;
     double Y1=0.22;
      int width=1000;
       int height=1000;
       int ITER=256;
       int threads = 1024;
       int* Mandel;
        cudaMallocManaged(&Mandel,sizeof(int)*width*height);

  
    cudaEvent_t start, stop;
  float elapsedTime;

  cudaEventCreate(&start);
  cudaEventRecord(start,0);

    computeMandelbrot1D<<<(width*height)/threads,threads>>>( X0, Y0, X1,Y1, width,height,ITER,Mandel );
    cudaDeviceSynchronize();
   
 cudaEventCreate(&stop);
 cudaEventRecord(stop,0);
 cudaEventSynchronize(stop);

 cudaEventElapsedTime(&elapsedTime, start,stop);
 cudaDeviceSynchronize();
 cout<<elapsedTime<<endl;

  
makePicture(Mandel,width,height,256);
cudaFree(Mandel);
}
