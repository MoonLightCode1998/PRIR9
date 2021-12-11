#include <iostream> 
using namespace std;
#include <chrono>
#include <sys/time.h>

int main(){
int a[10000];
int b[10000];
int c[10000];
for(int x =0;x<10000;x++){
    a[x]=x;
    b[x]=x;
    c[x]=a[x]+b[x];
}



printf("%d",c[5000]);

return 0;
}
