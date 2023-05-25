#include <iostream>
#include <vector>
#include <omp.h>

using namespace std;

void bubble(vector<int>& arr, int n) {
    for (int i = 0; i < n; i++) {
        int first = i % 2;
        #pragma omp parallel for shared(arr, first)
        for (int j = first; j < n - 1; j += 2) {
            if (arr[j] > arr[j + 1]) {
                swap(arr[j], arr[j + 1]);
            }
        }
    }
}

void merge(vector<int>& arr, int left, int middle, int right) {
    int i, j, k;
    int n1 = middle - left + 1;
    int n2 = right - middle;

    vector<int> L(n1), R(n2);

    for (i = 0; i < n1; i++)
        L[i] = arr[left + i];
    for (j = 0; j < n2; j++)
        R[j] = arr[middle + 1 + j];

    i = 0;
    j = 0;
    k = left;
    while (i < n1 && j < n2) {
        if (L[i] <= R[j]) {
            arr[k] = L[i];
            i++;
        }
        else {
            arr[k] = R[j];
            j++;
        }
        k++;
    }

    while (i < n1) {
        arr[k] = L[i];
        i++;
        k++;
    }

    while (j < n2) {
        arr[k] = R[j];
        j++;
        k++;
    }
}

void mergeSort(vector<int>& arr, int left, int right) {
    if (left >= right) {
        return;
    }

    int middle = left + (right - left) / 2;

    #pragma omp parallel sections num_threads(2)
    {
        #pragma omp section
        {
            mergeSort(arr, left, middle);
        }

        #pragma omp section
        {
            mergeSort(arr, middle + 1, right);
        }
    }

    merge(arr, left, middle, right);
}

int main() {
    int n;
    cout << "Enter the total number of elements: ";
    cin >> n;

    vector<int> arr(n);
    cout << "Enter the elements: ";
    for (int i = 0; i < n; i++) {
        cin >> arr[i];
    }

    // Perform parallel bubble sort
    bubble(arr, n);

    cout << "\nArray after bubble sort: ";
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
    cout << endl;

    // Perform parallel merge sort
    mergeSort(arr, 0, n - 1);

    cout << "\nArray after merge sort: ";
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
    cout << endl;

    return 0;
}
