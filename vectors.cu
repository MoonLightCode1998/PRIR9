#include <cuda_runtime.h>
#include <iostream> 
using namespace std;
#include <chrono>
#include <sys/time.h>
__global__ void sumowanie(int* a, int*b, int* c){
    int idx = blockIdx.x*blockDim.x+threadIdx.x;
    if(idx<100)
    {
       c[idx]=a[idx]+b[idx];
    
    
    
    }
}

int main(){
    
  int* a_CPU=(int*)malloc(sizeof(int)*100);
  int* b_CPU=(int*)malloc(sizeof(int)*100);
  int* c_CPU=(int*)malloc(sizeof(int)*100);
  int* a_GPU;
  int* b_GPU;
  int* c_GPU;
  cudaMalloc((void**)&a_GPU,sizeof(int)*100);
  cudaMalloc((void**)&b_GPU,sizeof(int)*100);
  cudaMalloc((void**)&c_GPU,sizeof(int)*100);
  
  for(int x =0;x<100;x++){
      a_CPU[x]=x;
      b_CPU[x]=x;
  }
  //printf("%d",a_CPU[50]);
  cudaMemcpy(a_GPU,a_CPU,sizeof(int)*100,cudaMemcpyHostToDevice);
  cudaMemcpy(b_GPU,b_CPU,sizeof(int)*100,cudaMemcpyHostToDevice);


  sumowanie<<<10,1024>>>(a_GPU,b_GPU,c_GPU);
  cudaDeviceSynchronize();
  cudaMemcpy(c_CPU,c_GPU,sizeof(int)*100,cudaMemcpyDeviceToHost);

  printf("%d",c_CPU[1]);




  cudaFree(a_GPU);
    cudaFree(b_GPU);
      cudaFree(c_GPU);
      free(a_CPU);
      free(b_CPU);
      free(c_CPU);






    return 0;
}