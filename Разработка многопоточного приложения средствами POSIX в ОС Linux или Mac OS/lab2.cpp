#include "lab2.h"

#include <cstring>

#include <semaphore.h>

#define NUMBER_OF_THREADS 12

// thread identifiers
pthread_t tid[NUMBER_OF_THREADS];
// critical section lock
pthread_mutex_t lock;
// semaphores for sequential threads
sem_t semB, semC, semD, semMain;

int err;

unsigned int lab2_thread_graph_id() {
  return 3;
}

const char * lab2_unsynchronized_threads() {
  return "defh";
}

const char * lab2_sequential_threads() {
  return "bcd";
}

void * thread_a(void * ptr);
void * thread_b(void * ptr);
void * thread_c(void * ptr);
void * thread_d(void * ptr);
void * thread_e(void * ptr);
void * thread_f(void * ptr);
void * thread_g(void * ptr);
void * thread_h(void * ptr);
void * thread_k(void * ptr);
void * thread_i(void * ptr);
void * thread_m(void * ptr);

//поток a
void * thread_a(void * ptr) {
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "a" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  return ptr;
}

//поток b
void * thread_b(void * ptr) {
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "b" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  for (int i = 0; i < 3; ++i) {
    sem_wait(& semB);
    pthread_mutex_lock( & lock);
    std::cout << "b" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
    sem_post(& semC);
  }
  return ptr;
};

//поток c
void * thread_c(void * ptr) {
  for (int i = 0; i < 3; ++i) {
    sem_wait(& semC);
    pthread_mutex_lock( & lock);
    std::cout << "c" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
    sem_post(& semD);
  }
  
  return ptr;
};

//поток d
void * thread_d(void * ptr) {
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "d" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  pthread_join(tid[0], NULL);
    err = pthread_create( & tid[2], NULL, thread_c, NULL);
  if (err != 0) {
    std::cerr << "Can't create thread. Error: " << strerror(err) << std::endl;
    }
  sem_post(& semB);
  for (int i = 0; i < 3; ++i) {
    sem_wait(& semD);
    pthread_mutex_lock( & lock);
    std::cout << "d" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
    sem_post(& semB);
  }
  pthread_join(tid[1], NULL);
  pthread_join(tid[2], NULL);

  pthread_create( & tid[4], NULL, thread_e, NULL);
  pthread_create( & tid[5], NULL, thread_f, NULL);
  pthread_create( & tid[6], NULL, thread_h, NULL);
    for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "d" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }

  return ptr;
}

void * thread_e(void * ptr) {
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "e" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }  
  pthread_join(tid[3],NULL);
  return ptr;
};


void * thread_f(void * ptr) {

  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "f" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  
  sem_wait(& semD);

 
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "f" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
      
  return ptr;
};

void * thread_h(void * ptr) {

  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "h" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }

  pthread_join(tid[4],NULL);
 pthread_create( & tid[7], NULL, thread_g, NULL);
 sem_post(& semD);
 
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "h" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  pthread_join(tid[5],NULL); //f
  pthread_join(tid[7],NULL); //g    

  pthread_create( & tid[8], NULL, thread_i, NULL); //i
  pthread_create( & tid[9], NULL, thread_k, NULL); //k
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "h" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  return ptr;

};

void * thread_g(void * ptr) {
  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "g" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }

  return ptr;

};

void * thread_m(void * ptr) {

  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "m" << std::flush;
    pthread_mutex_unlock( & lock);
  }

  return ptr;
};

void * thread_i(void * ptr) {

  for (int i = 0; i < 3; ++i) {
    pthread_mutex_lock( & lock);
    std::cout << "i" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  return ptr;
};

void * thread_k(void * ptr) {

  for (int i = 0; i < 3; ++i) {

    pthread_mutex_lock( & lock);
    std::cout << "k" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }

  pthread_join(tid[6], NULL);   
  pthread_join(tid[8], NULL);   
  pthread_create( & tid[10], NULL, thread_m, NULL);
  for (int i = 0; i < 3; ++i) {

    pthread_mutex_lock( & lock);
    std::cout << "k" << std::flush;
    pthread_mutex_unlock( & lock);
    computation();
  }
  pthread_join(tid[10], NULL);   
  sem_post( & semMain);

  return ptr;
}

int lab2_init() {
  // initilize mutex
  if (pthread_mutex_init( & lock, NULL) != 0) {
    std::cerr << "Mutex init failed" << std::endl;
    return 1;
  }

  err = pthread_create( & tid[1], NULL, thread_b, NULL);
  if (err != 0)
    std::cerr << "Can't create thread. Error: " << strerror(err) << std::endl;

  // start the first thread
  err = pthread_create( & tid[0], NULL, thread_a, NULL);
  if (err != 0)
    std::cerr << "Can't create thread. Error: " << strerror(err) << std::endl;

  err = pthread_create( & tid[3], NULL, thread_d, NULL);
  if (err != 0) {
    std::cerr << "Can't create thread. Error: " << strerror(err) << std::endl;
    }
    
  // ... and wait for it to finish
  sem_wait( & semMain);

  if (sem_init( & semB, 0, 0) != 0) {
    std::cerr << "Semaphore #1 init failed" << std::endl;
    return 1;
  }
  if (sem_init( & semC, 0, 0) != 0) {
    std::cerr << "Semaphore #2 init failed" << std::endl;
    return 1;
  }
  if (sem_init( & semD, 0, 0) != 0) {
    std::cerr << "Semaphore #3 init failed" << std::endl;
    return 1;
  }

   pthread_mutex_destroy(&lock);
    sem_destroy(&semD);
    sem_destroy(&semC);
    sem_destroy(&semB);
    
    std::cout << std::endl;

  return 0;
}
