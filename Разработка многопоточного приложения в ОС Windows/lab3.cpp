#include "lab3.h"
#include <windows.h> 
#define THREADCOUNT 13

using namespace std;

unsigned int lab3_thread_graph_id()
{
    return 19;
}

const char* lab3_unsynchronized_threads()
{
    return "dhikm";
}

const char* lab3_sequential_threads()
{
    return "bcdf";
}

HANDLE sem_f_finish_T1;
HANDLE sem_f_start_T2;

HANDLE sem_i_finish_T1;
HANDLE sem_i_start_T2;

HANDLE sem_k_finish_T1;
HANDLE sem_k_start_T2;
HANDLE sem_k_finish_T2;
HANDLE sem_k_start_T3;

HANDLE sem_m_finish_T1;
HANDLE sem_m_start_T2;

HANDLE sem_b;
HANDLE sem_c;
HANDLE sem_d;
HANDLE sem_f;

HANDLE critical_sem;

DWORD ThreadID;
HANDLE threads[THREADCOUNT];

DWORD WINAPI thread_a(LPVOID);
DWORD WINAPI thread_b(LPVOID);
DWORD WINAPI thread_c(LPVOID);
DWORD WINAPI thread_d(LPVOID);
DWORD WINAPI thread_e(LPVOID);
DWORD WINAPI thread_f(LPVOID);
DWORD WINAPI thread_g(LPVOID);
DWORD WINAPI thread_h(LPVOID);
DWORD WINAPI thread_i(LPVOID);
DWORD WINAPI thread_k(LPVOID);
DWORD WINAPI thread_m(LPVOID);
DWORD WINAPI thread_n(LPVOID);
DWORD WINAPI thread_p(LPVOID);


DWORD WINAPI thread_a(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'a' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_b(LPVOID) {
    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(sem_b, INFINITE);
        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'b' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
        ReleaseSemaphore(sem_c, 1, NULL);
    }

    return 0;
}

DWORD WINAPI thread_c(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(sem_c, INFINITE);
        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'c' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
        ReleaseSemaphore(sem_d, 1, NULL);
    }

    return 0;
}

DWORD WINAPI thread_d(LPVOID) {

    threads[1] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_b, NULL, 0, &ThreadID);  
    threads[2] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_c, NULL, 0, &ThreadID); 
    threads[3] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_f, NULL, 0, &ThreadID);  

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(sem_d, INFINITE);
        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'd' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
        ReleaseSemaphore(sem_f, 1, NULL);
    }

    WaitForSingleObject(threads[1], INFINITE);  
    WaitForSingleObject(threads[2], INFINITE);  
    WaitForSingleObject(sem_f_finish_T1, INFINITE);  

    threads[5] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_e, NULL, 0, &ThreadID);  
    threads[6] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_g, NULL, 0, &ThreadID);  
    threads[7] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_i, NULL, 0, &ThreadID);  
    threads[8] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_k, NULL, 0, &ThreadID);  

    ReleaseSemaphore(sem_f_start_T2, 1, NULL); 

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(sem_d, INFINITE);
        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'd' << std::flush;
        computation();
        ReleaseSemaphore(critical_sem, 1, NULL);
        ReleaseSemaphore(sem_f, 1, NULL);
    }

    WaitForSingleObject(threads[3], INFINITE);  
    WaitForSingleObject(threads[5], INFINITE);  
    WaitForSingleObject(threads[6], INFINITE);  
    WaitForSingleObject(sem_i_finish_T1, INFINITE);  
    WaitForSingleObject(sem_k_finish_T1, INFINITE);  

    threads[9] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_h, NULL, 0, &ThreadID);  
    threads[10] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_m, NULL, 0, &ThreadID);  
    ReleaseSemaphore(sem_i_start_T2, 1, NULL); 
    ReleaseSemaphore(sem_k_start_T2, 1, NULL);  

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'd' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    WaitForSingleObject(threads[7], INFINITE);  
    WaitForSingleObject(threads[9], INFINITE);  
    WaitForSingleObject(sem_k_finish_T2, INFINITE);  
    WaitForSingleObject(sem_m_finish_T1, INFINITE);  
    threads[11] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_n, NULL, 0, &ThreadID); 
    ReleaseSemaphore(sem_k_start_T3, 1, NULL);  
    ReleaseSemaphore(sem_m_start_T2, 1, NULL);  

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'd' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    WaitForSingleObject(threads[8], INFINITE); 
    WaitForSingleObject(threads[10], INFINITE);  
    WaitForSingleObject(threads[11], INFINITE);  

    return 0;
}

DWORD WINAPI thread_e(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'e' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_f(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(sem_f, INFINITE);
        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'f' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
        ReleaseSemaphore(sem_b, 1, NULL);
    }

    ReleaseSemaphore(sem_d, 1, NULL);
    ReleaseSemaphore(sem_f_finish_T1, 1, NULL);  
    WaitForSingleObject(sem_f_start_T2, INFINITE);  

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(sem_f, INFINITE);
        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'f' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
        ReleaseSemaphore(sem_d, 1, NULL);
    }

    return 0;
}

DWORD WINAPI thread_g(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'g' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_h(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'h' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_i(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'i' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    ReleaseSemaphore(sem_i_finish_T1, 1, NULL); 
    WaitForSingleObject(sem_i_start_T2, INFINITE); 

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'i' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_k(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'k' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    ReleaseSemaphore(sem_k_finish_T1, 1, NULL);  
    WaitForSingleObject(sem_k_start_T2, INFINITE);  

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'k' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    ReleaseSemaphore(sem_k_finish_T2, 1, NULL);  
    WaitForSingleObject(sem_k_start_T3, INFINITE); 

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'k' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_m(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'm' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    ReleaseSemaphore(sem_m_finish_T1, 1, NULL); 
    WaitForSingleObject(sem_m_start_T2, INFINITE);  

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'm' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_n(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'n' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

DWORD WINAPI thread_p(LPVOID) {

    for (int i = 0; i < 3; ++i) {

        WaitForSingleObject(critical_sem, INFINITE);
        std::cout << 'p' << std::flush;
        ReleaseSemaphore(critical_sem, 1, NULL);
        computation();
    }

    return 0;
}

int lab3_init()
{
    sem_f_finish_T1 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore çàâåðøåíèÿ ïåðâîé ÷àñòè ïîòîêà F
    if (sem_f_finish_T1 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_f_start_T2 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà F
    if (sem_f_start_T2 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_i_finish_T1 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore çàâåðøåíèÿ ïåðâîé ÷àñòè ïîòîêà F
    if (sem_i_finish_T1 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_k_finish_T1 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore çàâåðøåíèÿ ïåðâîé ÷àñòè ïîòîêà F
    if (sem_k_finish_T1 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_i_start_T2 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà I
    if (sem_i_start_T2 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_k_start_T2 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà K
    if (sem_k_start_T2 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_k_finish_T2 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore çàâåðøåíèÿ âòîðîé ÷àñòè ïîòîêà K
    if (sem_k_finish_T2 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_k_start_T3 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ òðåòüåé ÷àñòè ïîòîêà K
    if (sem_k_start_T3 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_m_finish_T1 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore çàâåðøåíèÿ ïåðâîé ÷àñòè ïîòîêà M
    if (sem_m_finish_T1 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_m_start_T2 = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà M
    if (sem_m_start_T2 == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }


    sem_b = CreateSemaphore(NULL, 1, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà M
    if (sem_b == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_c = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà M
    if (sem_c == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_d = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà M
    if (sem_d == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    sem_f = CreateSemaphore(NULL, 0, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà M
    if (sem_f == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }

    critical_sem = CreateSemaphore(NULL, 1, 1, NULL); // semaphore ðàçðåøåíèÿ âûïîëíåíèÿ âòîðîé ÷àñòè ïîòîêà M
    if (sem_f == NULL) {
        printf("CreateSemaphore a error : % d\n", GetLastError());
        return 1;
    }


    threads[0] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_a, NULL, 0, &ThreadID); // ñîçäàíèå ïîòîêà A
    WaitForSingleObject(threads[0], INFINITE); // îæèäàíèå çàâåðøåíèÿ ïîòîêà A

    threads[4] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_d, NULL, 0, &ThreadID); // ñîçäàíèå ïîòîêà D
    WaitForSingleObject(threads[4], INFINITE); // îæèäàíèå çàâåðøåíèÿ ïîòîêà D

    threads[12] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)thread_p, NULL, 0, &ThreadID); // ñîçäàíèå ïîòîêà P
    WaitForSingleObject(threads[12], INFINITE); // îæèäàíèå çàâåðøåíèÿ ïîòîêà P


    CloseHandle(sem_f_finish_T1);
    CloseHandle(sem_f_start_T2);

    CloseHandle(sem_i_finish_T1);
    CloseHandle(sem_i_start_T2);

    CloseHandle(sem_k_finish_T1);
    CloseHandle(sem_k_start_T2);
    CloseHandle(sem_k_finish_T2);
    CloseHandle(sem_k_start_T3);

    CloseHandle(sem_m_finish_T1);
    CloseHandle(sem_m_start_T2);

    for (int i = 0; i < THREADCOUNT; i++)
        CloseHandle(threads[i]);

    return 0;
}
