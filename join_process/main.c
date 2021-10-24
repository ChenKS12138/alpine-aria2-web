#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  char **children_argv, **argv_curr;
  int child_exit_code;
  uint argv_index, child_argc;

  if (argc < 2) {
    printf("Join Multi-Process\nusage: %s exectuale arg...[ :::: ...]",
           argv[0]);
    exit(EXIT_SUCCESS);
  }
  children_argv = malloc((argc + 1) * sizeof(char *));
  children_argv[0] = NULL;
  for (argv_index = 1; argv_index <= argc; ++argv_index) {
    argv_curr = argv + argv_index;
    if (argv_index == argc || strcmp(*argv_curr, "::::") == 0) {
      children_argv[argv_index] = NULL;
      child_argc = 0;
      while (*(children_argv + argv_index - 1 - child_argc) != NULL)
        child_argc += 1;
      switch (fork()) {
      case -1:
        fprintf(stderr, "fork[%s]\n", strerror(errno));
      case 0:
        if (execvp(*(children_argv + argv_index - child_argc),
                   children_argv + argv_index - child_argc) == -1) {
          fprintf(stderr, "execve[%s]\n", strerror(errno));
          _exit(EXIT_FAILURE);
        }
      default:
        continue;
      }
    } else {
      strcpy(children_argv[argv_index] =
                 malloc(sizeof(char *) * (strlen(*argv_curr) + 1)),
             *argv_curr);
    }
  }

  child_exit_code = 0;
  while (wait(&child_exit_code) >= 0) {
    if (child_exit_code < 0) {
      fprintf(stderr, "wait[%s]\n", strerror(errno));
      exit(EXIT_FAILURE);
    }
  }
  exit(EXIT_SUCCESS);
}