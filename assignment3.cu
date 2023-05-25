%%cuda --name omp_cuda.cu
#include <stdio.h>
#include <cuda.h>

#define row1 2 /* Number of rows of first matrix */
#define col1 3 /* Number of columns of first matrix */
#define row2 3 /* Number of rows of second matrix */
#define col2 2 /* Number of columns of second matrix */

__global__ void matproduct(int *l, int *m, int *n)
{
    int x = blockIdx.x;
    int y = blockIdx.y;
    int k;

    n[col2 * y + x] = 0;
    for (k = 0; k < col1; k++)
    {
        n[col2 * y + x] = n[col2 * y + x] + l[col1 * y + k] * m[col2 * k + x];
    }
}

__global__ void arradd(int *x, int *y, int *z)
{
    int id = blockIdx.x;
    z[id] = x[id] + y[id];
}

int main()
{
    int a[row1][col1];
    int b[row2][col2];
    int c[row1][col2];
    int *d, *e, *f;
    int i, j;

    printf("\n Enter elements of first matrix of size 2*3\n");
    for (i = 0; i < row1; i++)
    {
        for (j = 0; j < col1; j++)
        {
            scanf("%d", &a[i][j]);
        }
    }
    printf("\n Enter elements of second matrix of size 3*2\n");
    for (i = 0; i < row2; i++)
    {
        for (j = 0; j < col2; j++)
        {
            scanf("%d", &b[i][j]);
        }
    }

    cudaMalloc((void **)&d, row1 * col1 * sizeof(int));
    cudaMalloc((void **)&e, row2 * col2 * sizeof(int));
    cudaMalloc((void **)&f, row1 * col2 * sizeof(int));

    cudaMemcpy(d, a, row1 * col1 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(e, b, row2 * col2 * sizeof(int), cudaMemcpyHostToDevice);

    dim3 grid(col2, row1);

    matproduct<<<grid, 1>>>(d, e, f);

    cudaMemcpy(c, f, row1 * col2 * sizeof(int), cudaMemcpyDeviceToHost);
    printf("\nProduct of two matrices:\n ");
    for (i = 0; i < row1; i++)
    {
        for (j = 0; j < col2; j++)
        {
            printf("%d\t", c[i][j]);
        }
        printf("\n");
    }

    int arr[6];
    int arr2[6];
    int arr3[6];

    printf("\n Enter six elements of first array\n");
    for (i = 0; i < 6; i++)
    {
        scanf("%d", &arr[i]);
    }
    printf("\n Enter six elements of second array\n");
    for (i = 0; i < 6; i++)
    {
        scanf("%d", &arr2[i]);
    }

    cudaMemcpy(d, arr, 6 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(e, arr2, 6 * sizeof(int), cudaMemcpyHostToDevice);

    arradd<<<6, 1>>>(d, e, f);

    cudaMemcpy(arr3, f, 6 * sizeof(int), cudaMemcpyDeviceToHost);

    printf("\nSum of two arrays:\n ");
    for (i = 0; i < 6; i++)
    {
        printf("%d\t", arr3[i]);
    }

    cudaFree(d);
    cudaFree(e);
    cudaFree(f);

    return 0;
}
